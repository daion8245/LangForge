// The runner's fields are private but its parameters are not, so an
// initializing formal would leak underscores into every call site.
// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:logging/logging.dart';

import '../../domain/model/entry_status.dart';
import '../../domain/normalize/text_normalizer.dart';
import '../../domain/normalize/text_post_processor.dart';
import '../../domain/policy/exclusion_policy.dart';
import '../../domain/protection/multiset.dart';
import '../../domain/protection/token_protector.dart';
import '../../domain/provider/backoff.dart';
import '../../domain/provider/translation_error.dart';
import '../../domain/provider/translation_provider.dart';
import '../../infrastructure/db/app_database.dart';
import '../../infrastructure/normalize/unicode_text_normalizer.dart';

enum RunnerStatus { idle, running, paused, error }

class TranslationRunnerProgress {
  const TranslationRunnerProgress({
    required this.status,
    required this.totalCount,
    required this.completedCount,
    required this.failedCount,
    this.currentMessage,
  });

  final RunnerStatus status;
  final int totalCount;
  final int completedCount;
  final int failedCount;
  final String? currentMessage;

  double get percent => totalCount == 0 ? 0.0 : completedCount / totalCount;
}

/// The provider returned a different number of items than we asked for.
///
/// Kept distinct from retry exhaustion so that only this case triggers the
/// batch split of ROADMAP 3.9.
class _ItemCountMismatch implements Exception {
  const _ItemCountMismatch(this.expected, this.actual);

  final int expected;
  final int actual;

  @override
  String toString() => '응답 항목 개수 불일치 (요청 $expected · 응답 $actual)';
}

/// Drives the translation queue: batching, concurrency, retries, pause and
/// cancel. See TECHNICAL.md 6.4 and 6.5.
class TranslationRunner {
  TranslationRunner({
    required AppDatabase db,
    required TranslationProvider provider,
    TextNormalizer normalizer = const UnicodeTextNormalizer(),
    Duration Function(int attempt) backoffStrategy = backoff,
  }) : _db = db,
       _provider = provider,
       _normalizer = normalizer,
       _backoff = backoffStrategy;

  static final Logger _log = Logger('TranslationRunner');

  /// Progress is reported no more often than this (AGENTS.md 4.5).
  static const Duration progressInterval = Duration(milliseconds: 100);

  /// Rows written per database batch (AGENTS.md 5.6).
  static const int flushChunkSize = 1000;

  /// Consecutive network failures before the run pauses itself.
  static const int networkFailurePauseThreshold = 3;

  final AppDatabase _db;
  final TranslationProvider _provider;
  final TextNormalizer _normalizer;

  /// Injectable so tests do not have to sit through real backoff waits.
  final Duration Function(int attempt) _backoff;

  RunnerStatus _status = RunnerStatus.idle;
  CancellationToken _cancelToken = CancellationToken();

  /// Lives as long as the runner so callers can subscribe before starting a
  /// run. A per-run controller would drop the early events.
  final StreamController<TranslationRunnerProgress> _progressController =
      StreamController<TranslationRunnerProgress>.broadcast();

  /// Non-null while paused. Workers await it, so a paused run keeps its place
  /// in the queue instead of tearing down (ROADMAP Phase 3 완료 조건).
  Completer<void>? _pauseGate;

  int _totalCount = 0;
  int _completedCount = 0;
  int _failedCount = 0;
  int _consecutiveNetworkErrors = 0;
  DateTime _lastProgressAt = DateTime.fromMillisecondsSinceEpoch(0);

  RunnerStatus get status => _status;

  Stream<TranslationRunnerProgress> get progressStream =>
      _progressController.stream;

  /// Starts translating. [retryFailed] also picks up entries that previously
  /// ended in 검증 실패 (ROADMAP 3.11).
  Future<void> startTranslation({
    required AuthValues auth,
    String? model,
    String sourceLang = 'en_us',
    String targetLang = 'ko_kr',
    bool retryFailed = false,
  }) async {
    if (_status == RunnerStatus.running || _status == RunnerStatus.paused) {
      return;
    }

    _status = RunnerStatus.running;
    _cancelToken = CancellationToken();
    _pauseGate = null;
    _completedCount = 0;
    _failedCount = 0;
    _consecutiveNetworkErrors = 0;
    _lastProgressAt = DateTime.fromMillisecondsSinceEpoch(0);

    try {
      final eligible = await _selectEligibleEntries(retryFailed: retryFailed);
      _totalCount = eligible.length;

      if (eligible.isEmpty) {
        _status = RunnerStatus.idle;
        _emitProgress('번역 대기 항목이 없습니다.', force: true);
        return;
      }

      _log.info(
        'Translation started: ${eligible.length} entries, '
        'provider=${_provider.id}, model=${model ?? "default"}',
      );
      _emitProgress('번역 준비 중…', force: true);

      // Batches stay grouped by namespace so one request sees related strings.
      final batches = <List<Entry>>[];
      final byNamespace = <String, List<Entry>>{};
      for (final entry in eligible) {
        byNamespace.putIfAbsent(entry.namespaceId, () => []).add(entry);
      }
      for (final nsEntries in byNamespace.values) {
        batches.addAll(_createBatches(nsEntries, _provider.limits));
      }

      await _runBatches(
        batches: batches,
        auth: auth,
        model: model,
        sourceLang: sourceLang,
        targetLang: targetLang,
      );

      if (_status == RunnerStatus.running) {
        _status = RunnerStatus.idle;
        _emitProgress('번역이 완료되었습니다.', force: true);
        _log.info(
          'Translation finished: $_completedCount done, $_failedCount failed',
        );
      }
    } on Cancelled {
      _status = RunnerStatus.idle;
      _emitProgress('번역을 취소했습니다.', force: true);
      _log.info('Translation cancelled by user');
    } catch (error, stackTrace) {
      _status = RunnerStatus.error;
      _emitProgress('번역 실패: $error', force: true);
      _log.severe('Translation run failed', error, stackTrace);
    }
  }

  /// The 대기 entries that may actually be sent.
  ///
  /// A namespace that is excluded, deselected, has no source language file, or
  /// failed the JSON precheck never reaches the queue — its rows are isolated,
  /// not translated (AC-3.2 · AC-3.3 · AC-4.4 · AC-4.6 · AC-8.2).
  Future<List<Entry>> _selectEligibleEntries({
    required bool retryFailed,
  }) async {
    final statuses = <String>[
      EntryStatus.wait.wireName,
      if (retryFailed) EntryStatus.invalid.wireName,
    ];

    final translatableNamespaceIds =
        await (_db.select(_db.namespaces)..where(
              (tbl) =>
                  tbl.excluded.equals(false) &
                  tbl.selected.equals(true) &
                  tbl.state.isNotIn([
                    NamespaceState.jsonError.wireName,
                    NamespaceState.noSource.wireName,
                    NamespaceState.excluded.wireName,
                  ]),
            ))
            .get()
            .then((rows) => rows.map((ns) => ns.id).toList());

    if (translatableNamespaceIds.isEmpty) return const [];

    return (_db.select(_db.entries)..where(
          (tbl) =>
              tbl.status.isIn(statuses) &
              tbl.namespaceId.isIn(translatableNamespaceIds),
        ))
        .get();
  }

  /// Runs [batches] with at most `limits.maxConcurrentRequests` in flight.
  Future<void> _runBatches({
    required List<List<Entry>> batches,
    required AuthValues auth,
    String? model,
    required String sourceLang,
    required String targetLang,
  }) async {
    final queue = List<List<Entry>>.from(batches);
    final pending = <EntriesCompanion>[];
    var nextIndex = 0;
    var aborted = false;

    Future<void> worker() async {
      while (true) {
        if (aborted || _cancelToken.isCancelled) return;

        // Pausing is one of the save points of TECHNICAL.md 6.4, so whatever
        // finished before the pause reaches disk instead of waiting for a
        // resume that may never come.
        if (_pauseGate != null) await _flushDB(pending);

        // Waiting here rather than returning is what makes 일시정지 → 재개
        // continue the same queue instead of ending the run (AC-5.5).
        await _waitWhilePaused();
        if (aborted || _cancelToken.isCancelled) return;

        if (nextIndex >= queue.length) return;
        final batch = queue[nextIndex++];

        try {
          final companions = await _processBatch(
            batch: batch,
            auth: auth,
            model: model,
            sourceLang: sourceLang,
            targetLang: targetLang,
          );
          pending.addAll(companions);
          _completedCount += batch.length;
          _consecutiveNetworkErrors = 0;
        } on Cancelled {
          return;
        } on AuthError catch (error) {
          // A bad key fails every remaining request too (TECHNICAL.md 6.5).
          aborted = true;
          _status = RunnerStatus.error;
          _log.severe('Authentication rejected; stopping queue', error);
          _emitProgress('인증 오류: ${error.message}', force: true);
          return;
        } on QuotaExhausted catch (error) {
          aborted = true;
          _status = RunnerStatus.error;
          _log.severe('Quota exhausted; stopping queue', error);
          _emitProgress('할당량 소진: ${error.message}', force: true);
          return;
        } on NetworkError catch (error) {
          // The connection dropped, not the data. The batch keeps its 대기
          // status so that resuming re-queues it (AC-5.10); marking it 검증
          // 실패 would blame the entries for a network outage.
          _consecutiveNetworkErrors++;
          queue.add(batch);
          _log.warning('Network error on batch of ${batch.length}', error);

          if (_consecutiveNetworkErrors >= networkFailurePauseThreshold) {
            _pauseForNetworkOutage();
            continue;
          }
        } on TranslationError catch (error, stackTrace) {
          // Retries are exhausted or the error is permanent. Record it on the
          // entries so the failure is visible rather than silently dropped.
          pending.addAll(_markInvalid(batch, error.message));
          _failedCount += batch.length;
          _log.warning('Batch failed permanently', error, stackTrace);
        } catch (error, stackTrace) {
          pending.addAll(_markInvalid(batch, '알 수 없는 오류: $error'));
          _failedCount += batch.length;
          _log.severe('Unexpected batch failure', error, stackTrace);
        }

        _emitProgress('번역 진행 중… ($_completedCount/$_totalCount)');

        if (pending.length >= flushChunkSize) {
          await _flushDB(pending);
        }
      }
    }

    final workerCount = queue.isEmpty
        ? 1
        : _provider.limits.maxConcurrentRequests.clamp(1, queue.length);
    await Future.wait(List.generate(workerCount, (_) => worker()));

    await _flushDB(pending);
  }

  /// Blocks while the run is paused. Returns as soon as it resumes or is
  /// cancelled.
  Future<void> _waitWhilePaused() async {
    while (_pauseGate != null && !_cancelToken.isCancelled) {
      await _pauseGate!.future;
    }
  }

  /// Suspends the run. Work already in flight finishes; nothing new starts.
  void pause() {
    if (_status != RunnerStatus.running) return;
    _status = RunnerStatus.paused;
    _pauseGate ??= Completer<void>();
    _log.info('Translation paused');
    _emitProgress('일시정지했습니다.', force: true);
  }

  /// Stops the queue after repeated connection failures (EXPERIENCE.md 6.2).
  /// The batches that failed are back in the queue, so 재개 retries them.
  void _pauseForNetworkOutage() {
    _status = RunnerStatus.paused;
    _pauseGate ??= Completer<void>();
    _log.warning(
      'Paused: $_consecutiveNetworkErrors consecutive network errors',
    );
    _emitProgress('네트워크 연결이 끊겼습니다. 연결 후 재개하세요.', force: true);
  }

  /// Continues a paused run from where it stopped.
  void resume() {
    if (_status != RunnerStatus.paused) return;
    _status = RunnerStatus.running;
    // The outage that paused the run is over as far as the user is concerned;
    // a fresh streak has to build up before it pauses itself again.
    _consecutiveNetworkErrors = 0;
    final gate = _pauseGate;
    _pauseGate = null;
    if (gate != null && !gate.isCompleted) gate.complete();
    _log.info('Translation resumed');
    _emitProgress('번역을 재개했습니다.', force: true);
  }

  /// Abandons the run. Unlike [pause] this cannot be continued.
  void cancel() {
    if (_status == RunnerStatus.idle) return;
    _cancelToken.cancel();
    // Release anyone waiting on the pause gate so they observe the cancel.
    final gate = _pauseGate;
    _pauseGate = null;
    if (gate != null && !gate.isCompleted) gate.complete();
    _status = RunnerStatus.idle;
    _log.info('Translation cancel requested');
  }

  Future<void> dispose() async {
    cancel();
    await _progressController.close();
  }

  List<List<Entry>> _createBatches(List<Entry> entries, BatchLimits limits) {
    final batches = <List<Entry>>[];
    var current = <Entry>[];
    var currentChars = 0;

    for (final entry in entries) {
      // Excluded values never reach the provider, so they get their own batch
      // and are resolved locally.
      if (ExclusionPolicy.shouldExclude(entry.sourceText)) {
        batches.add([entry]);
        continue;
      }

      final length = entry.sourceText.length;
      final wouldOverflow =
          current.length >= limits.maxTextsPerRequest ||
          (currentChars + length) > limits.maxCharsPerRequest;

      if (wouldOverflow && current.isNotEmpty) {
        batches.add(current);
        current = <Entry>[];
        currentChars = 0;
      }

      current.add(entry);
      currentChars += length;
    }

    if (current.isNotEmpty) batches.add(current);
    return batches;
  }

  Future<List<EntriesCompanion>> _processBatch({
    required List<Entry> batch,
    required AuthValues auth,
    String? model,
    required String sourceLang,
    required String targetLang,
  }) async {
    if (_cancelToken.isCancelled) throw const Cancelled();

    if (batch.length == 1 &&
        ExclusionPolicy.shouldExclude(batch.first.sourceText)) {
      return [_resolveExcluded(batch.first)];
    }

    final protectedList = batch
        .map((e) => TokenProtector.protect(e.sourceText))
        .toList();

    List<String> translated;
    try {
      translated = await _requestWithRetries(
        texts: protectedList.map((p) => p.masked).toList(),
        auth: auth,
        model: model,
        sourceLang: sourceLang,
        targetLang: targetLang,
      );
    } on _ItemCountMismatch catch (mismatch) {
      // The provider ignored the item count. Halving the batch usually gets a
      // well-formed answer; a single item that still fails is a real failure.
      if (batch.length > 1) {
        return _splitAndRetry(
          batch: batch,
          auth: auth,
          model: model,
          sourceLang: sourceLang,
          targetLang: targetLang,
        );
      }
      _log.warning('Item count mismatch on a single entry: $mismatch');
      return _markInvalid(batch, mismatch.toString());
    } on PayloadTooLarge {
      if (batch.length > 1) {
        return _splitAndRetry(
          batch: batch,
          auth: auth,
          model: model,
          sourceLang: sourceLang,
          targetLang: targetLang,
        );
      }
      rethrow;
    }

    return _validateResults(batch, protectedList, translated);
  }

  /// Sends one request, retrying the retryable errors with exponential
  /// backoff. Gives up after [maxAttempts] rather than splitting the batch —
  /// splitting a rate-limited batch multiplies the requests that caused it.
  Future<List<String>> _requestWithRetries({
    required List<String> texts,
    required AuthValues auth,
    String? model,
    required String sourceLang,
    required String targetLang,
  }) async {
    var attempt = 0;

    while (true) {
      if (_cancelToken.isCancelled) throw const Cancelled();
      await _waitWhilePaused();
      if (_cancelToken.isCancelled) throw const Cancelled();

      try {
        final result = await _provider.translate(
          TranslationRequest(
            texts: texts,
            sourceCode: sourceLang,
            targetCode: targetLang,
            model: model,
            auth: auth,
            cancel: _cancelToken,
          ),
        );

        if (result.length != texts.length) {
          throw _ItemCountMismatch(texts.length, result.length);
        }
        return result;
      } on RateLimited catch (error) {
        attempt++;
        if (attempt >= maxAttempts) {
          _log.warning('Rate limited $maxAttempts times; giving up on batch');
          rethrow;
        }
        await _sleep(error.retryAfter ?? _backoff(attempt));
      } on ServerError catch (_) {
        attempt++;
        if (attempt >= maxAttempts) rethrow;
        await _sleep(_backoff(attempt));
      } on NetworkError catch (_) {
        // Retryable per TECHNICAL.md 6.5. Only after the attempt cap does this
        // surface to the caller as a connection outage.
        attempt++;
        if (attempt >= maxAttempts) rethrow;
        await _sleep(_backoff(attempt));
      } on TimeoutError catch (_) {
        attempt++;
        if (attempt >= maxAttempts) rethrow;
        await _sleep(_backoff(attempt));
      }
    }
  }

  Future<List<EntriesCompanion>> _splitAndRetry({
    required List<Entry> batch,
    required AuthValues auth,
    String? model,
    required String sourceLang,
    required String targetLang,
  }) async {
    final mid = batch.length ~/ 2;
    final left = await _processBatch(
      batch: batch.sublist(0, mid),
      auth: auth,
      model: model,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );
    final right = await _processBatch(
      batch: batch.sublist(mid),
      auth: auth,
      model: model,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );
    return [...left, ...right];
  }

  /// Restores tokens, post-processes, and refuses anything that fails the
  /// multiset check. A rejected value is never stored as a translation.
  List<EntriesCompanion> _validateResults(
    List<Entry> batch,
    List<ProtectedText> protectedList,
    List<String> translated,
  ) {
    final results = <EntriesCompanion>[];

    for (var i = 0; i < batch.length; i++) {
      final entry = batch[i];
      final restored = TokenProtector.restore(protectedList[i], translated[i]);

      if (restored == null) {
        results.add(
          EntriesCompanion(
            id: Value(entry.id),
            status: Value(EntryStatus.invalid.wireName),
            newTranslation: const Value<String?>(null),
            validationJson: Value(
              jsonEncode({
                'reason': 'placeholderLost',
                'rejected': translated[i],
              }),
            ),
            updatedAt: Value(DateTime.now()),
          ),
        );
        continue;
      }

      final cleaned = TextPostProcessor.process(
        entry.sourceText,
        restored,
        normalizer: _normalizer,
      );

      final verdict = MultisetValidator.validate(entry.sourceText, cleaned);

      if (!verdict.isMatch) {
        // A value that fails validation is never stored as a translation
        // (AGENTS.md 2.1, AC-6.7). Writing it to newTranslation would let
        // MergePolicy pick it up and ship it. The rejected text is kept in the
        // validation detail instead, so the row can still show what came back.
        results.add(
          EntriesCompanion(
            id: Value(entry.id),
            status: Value(EntryStatus.invalid.wireName),
            newTranslation: const Value<String?>(null),
            validationJson: Value(
              jsonEncode({'reason': 'tokenMismatch', 'rejected': cleaned}),
            ),
            updatedAt: Value(DateTime.now()),
          ),
        );
        continue;
      }

      results.add(
        EntriesCompanion(
          id: Value(entry.id),
          status: Value(EntryStatus.done.wireName),
          newTranslation: Value(cleaned),
          validationJson: const Value<String?>(null),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }

    return results;
  }

  EntriesCompanion _resolveExcluded(Entry entry) {
    final isEmptySource = entry.sourceText.isEmpty;
    return EntriesCompanion(
      id: Value(entry.id),
      status: Value(
        isEmptySource
            ? EntryStatus.empty.wireName
            : EntryStatus.fallback.wireName,
      ),
      newTranslation: isEmptySource
          ? const Value<String?>(null)
          : Value(entry.sourceText),
      updatedAt: Value(DateTime.now()),
    );
  }

  /// Marks a whole batch as 검증 실패 with [reason]. No translated value is
  /// written — a failed request has nothing trustworthy to store.
  List<EntriesCompanion> _markInvalid(List<Entry> batch, String reason) {
    final now = DateTime.now();
    final detail = jsonEncode({'reason': 'requestFailed', 'detail': reason});
    return [
      for (final entry in batch)
        EntriesCompanion(
          id: Value(entry.id),
          status: Value(EntryStatus.invalid.wireName),
          newTranslation: const Value<String?>(null),
          validationJson: Value(detail),
          updatedAt: Value(now),
        ),
    ];
  }

  Future<void> _sleep(Duration duration) async {
    // Wake early if the run is cancelled while backing off.
    final deadline = DateTime.now().add(duration);
    while (DateTime.now().isBefore(deadline)) {
      if (_cancelToken.isCancelled) throw const Cancelled();
      final remaining = deadline.difference(DateTime.now());
      final slice = remaining > const Duration(milliseconds: 200)
          ? const Duration(milliseconds: 200)
          : remaining;
      if (slice <= Duration.zero) break;
      await Future<void>.delayed(slice);
    }
  }

  Future<void> _flushDB(List<EntriesCompanion> companions) async {
    if (companions.isEmpty) return;

    final toFlush = List<EntriesCompanion>.from(companions);
    companions.clear();

    await _db.batch((b) {
      for (final companion in toFlush) {
        b.update(
          _db.entries,
          companion,
          where: (tbl) => tbl.id.equals(companion.id.value),
        );
      }
    });
  }

  /// Emits progress, throttled to [progressInterval] unless [force] is set for
  /// a state change the user must see immediately.
  void _emitProgress(String message, {bool force = false}) {
    if (_progressController.isClosed) return;

    final now = DateTime.now();
    if (!force && now.difference(_lastProgressAt) < progressInterval) return;
    _lastProgressAt = now;

    _progressController.add(
      TranslationRunnerProgress(
        status: _status,
        totalCount: _totalCount,
        completedCount: _completedCount,
        failedCount: _failedCount,
        currentMessage: message,
      ),
    );
  }
}
