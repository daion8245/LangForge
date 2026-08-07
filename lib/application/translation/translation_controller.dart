import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/cache/cache_hit_rate.dart';
import '../../domain/provider/translation_provider.dart';
import '../cache/cache_providers.dart';
import '../db_provider.dart';
import '../project/project_language_pair.dart';
import '../project/project_session.dart';
import 'translation_runner.dart';

/// What the shell needs to know about the run: enough to drive the status bar,
/// the primary button, and the locks of EXPERIENCE.md 6.4.
class TranslationUiState {
  const TranslationUiState({
    this.status = RunnerStatus.idle,
    this.totalCount = 0,
    this.completedCount = 0,
    this.failedCount = 0,
    this.cacheHitCount = 0,
    this.message,
  });

  final RunnerStatus status;
  final int totalCount;
  final int completedCount;
  final int failedCount;
  final int cacheHitCount;
  final String? message;

  bool get isRunning => status == RunnerStatus.running;
  bool get isPaused => status == RunnerStatus.paused;

  /// True whenever a run holds the UI, paused runs included — a paused run
  /// still owns the queue, so editing and file changes stay locked.
  bool get isActive => isRunning || isPaused;

  /// `null` rather than 0 when there is nothing to divide by, so no caller can
  /// render `NaN%` (DESIGN.md 14).
  double? get percent => totalCount == 0 ? null : completedCount / totalCount;

  String get cacheHitRateLabel =>
      CacheHitRate.format(hits: cacheHitCount, total: totalCount);
}

/// Owns the [TranslationRunner] for the session and exposes it to the UI.
class TranslationController extends Notifier<TranslationUiState> {
  TranslationRunner? _runner;
  StreamSubscription<TranslationRunnerProgress>? _subscription;

  @override
  TranslationUiState build() {
    ref.onDispose(() {
      unawaited(_subscription?.cancel());
      unawaited(_runner?.dispose());
    });
    return const TranslationUiState();
  }

  Future<void> start({
    required TranslationProvider provider,
    required AuthValues auth,
    required String model,
    bool retryFailed = false,
  }) async {
    if (state.isActive) return;

    final db = ref.read(appDatabaseProvider);
    final langs = await ProjectLanguagePair.fromDb(db);
    final glossary = ref.read(glossaryStoreProvider);
    glossary?.attachProject(db);

    final runner = TranslationRunner(
      db: db,
      provider: provider,
      cacheStore: ref.read(translationCacheStoreProvider),
      glossaryStore: glossary,
    );
    _runner = runner;

    _subscription = runner.progressStream.listen((progress) {
      state = TranslationUiState(
        status: progress.status,
        totalCount: progress.totalCount,
        completedCount: progress.completedCount,
        failedCount: progress.failedCount,
        cacheHitCount: progress.cacheHitCount,
        message: progress.currentMessage,
      );
    });

    try {
      await runner.startTranslation(
        auth: auth,
        model: model,
        sourceLang: langs.sourceLang,
        targetLang: langs.targetLang,
        retryFailed: retryFailed,
      );
    } finally {
      await _subscription?.cancel();
      _subscription = null;
      _runner = null;
      await runner.dispose();
      // The last streamed message is kept; only the run itself is over.
      state = TranslationUiState(
        totalCount: state.totalCount,
        completedCount: state.completedCount,
        failedCount: state.failedCount,
        cacheHitCount: state.cacheHitCount,
        message: state.message,
      );
      // Completion, error, and cancellation all land here — the save points of
      // TECHNICAL.md 6.4. Nothing is saved per batch.
      await _checkpoint();
    }
  }

  /// Re-runs only the entries that ended in 검증 실패 (AC-5.11).
  Future<void> retryFailed({
    required TranslationProvider provider,
    required AuthValues auth,
    required String model,
  }) {
    return start(
      provider: provider,
      auth: auth,
      model: model,
      retryFailed: true,
    );
  }

  void pause() {
    if (_runner == null) return;
    _runner!.pause();
    unawaited(_checkpoint());
  }

  void resume() => _runner?.resume();

  void cancel() => _runner?.cancel();

  Future<void> _checkpoint() =>
      ref.read(projectSessionProvider.notifier).saveTranslationCheckpoint();
}

final translationControllerProvider =
    NotifierProvider<TranslationController, TranslationUiState>(
      TranslationController.new,
    );
