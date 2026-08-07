import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/application/translation/translation_runner.dart';
import 'package:langforge/domain/cache/cache_kind.dart';
import 'package:langforge/domain/glossary/glossary_term.dart';
import 'package:langforge/domain/protection/token_protector.dart';
import 'package:langforge/domain/provider/translation_error.dart';
import 'package:langforge/domain/provider/translation_provider.dart';
import 'package:langforge/infrastructure/cache/cache_hashes.dart';
import 'package:langforge/infrastructure/cache/translation_cache_store.dart';
import 'package:langforge/infrastructure/db/app_database.dart';
import 'package:langforge/infrastructure/glossary/glossary_store.dart';

/// A provider whose behaviour each test dictates.
class ScriptedProvider implements TranslationProvider {
  ScriptedProvider({
    this.onTranslate,
    this.concurrency = 4,
    this.textsPerRequest = 10,
  });

  /// Called for every request. Throw to simulate an error.
  final Future<List<String>> Function(TranslationRequest request)? onTranslate;

  final int concurrency;
  final int textsPerRequest;

  int callCount = 0;
  int maxInFlight = 0;
  int _inFlight = 0;

  @override
  String get id => 'scripted';
  @override
  String get displayName => 'Scripted';
  @override
  List<AuthField> get authFields => const [];
  @override
  List<String> get models => const ['scripted-model'];
  @override
  BatchLimits get limits => BatchLimits(
    maxTextsPerRequest: textsPerRequest,
    maxConcurrentRequests: concurrency,
  );

  @override
  Future<void> verify(AuthValues auth) async {}

  @override
  Future<List<String>> translate(TranslationRequest request) async {
    callCount++;
    _inFlight++;
    maxInFlight = _inFlight > maxInFlight ? _inFlight : maxInFlight;
    try {
      if (onTranslate != null) return await onTranslate!(request);
      return request.texts.map((t) => '번역_$t').toList();
    } finally {
      _inFlight--;
    }
  }
}

late AppDatabase db;

Future<void> seedEntries(int count) async {
  final now = DateTime.now();
  await db
      .into(db.inputFiles)
      .insert(
        InputFilesCompanion.insert(
          id: 'f1',
          originalName: 'test.jar',
          absolutePath: '/test.jar',
          kind: 'jar',
          sizeBytes: 1,
          sha256: 'hash',
          addedAt: now,
          scanState: 'ok',
        ),
      );
  await db
      .into(db.namespaces)
      .insert(
        NamespacesCompanion.insert(
          id: 'ns1',
          inputFileId: 'f1',
          name: 'ns1',
          state: 'ok',
        ),
      );
  await db.batch((b) {
    b.insertAll(db.entries, [
      for (var i = 0; i < count; i++)
        EntriesCompanion.insert(
          id: 'e$i',
          namespaceId: 'ns1',
          key: 'item.k$i',
          keyOrder: i,
          sourceText: 'Item $i',
          status: 'wait',
          updatedAt: now,
        ),
    ]);
  });
}

Future<List<Entry>> allEntries() => db.select(db.entries).get();

const auth = AuthValues({'apiKey': 'TEST'});

void main() {
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  group('Pause and resume', () {
    test('A paused run stops taking new work and can continue', () async {
      await seedEntries(40);

      final gate = Completer<void>();
      var seen = 0;
      final provider = ScriptedProvider(
        concurrency: 1,
        textsPerRequest: 10,
        onTranslate: (request) async {
          seen++;
          if (seen == 1) await gate.future;
          return request.texts.map((t) => '번역_$t').toList();
        },
      );
      final runner = TranslationRunner(db: db, provider: provider);

      final run = runner.startTranslation(auth: auth);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      runner.pause();
      expect(runner.status, equals(RunnerStatus.paused));

      gate.complete();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Paused means paused: no further requests went out.
      final callsWhilePaused = provider.callCount;
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(provider.callCount, equals(callsWhilePaused));

      runner.resume();
      expect(runner.status, equals(RunnerStatus.running));

      await run;

      // The run continued from where it stopped rather than restarting.
      expect(runner.status, equals(RunnerStatus.idle));
      final entries = await allEntries();
      expect(entries.where((e) => e.status == 'done').length, equals(40));
    });

    test('resume on a run that is not paused does nothing', () async {
      await seedEntries(1);
      final runner = TranslationRunner(db: db, provider: ScriptedProvider());

      runner.resume();
      expect(runner.status, equals(RunnerStatus.idle));
    });
  });

  group('Cancellation', () {
    test('Cancelling stops the queue and leaves the rest untouched', () async {
      await seedEntries(60);

      final provider = ScriptedProvider(
        concurrency: 1,
        textsPerRequest: 10,
        onTranslate: (request) async {
          await Future<void>.delayed(const Duration(milliseconds: 15));
          return request.texts.map((t) => '번역_$t').toList();
        },
      );
      final runner = TranslationRunner(db: db, provider: provider);

      final run = runner.startTranslation(auth: auth);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      runner.cancel();
      await run;

      final entries = await allEntries();
      final untouched = entries.where((e) => e.status == 'wait').length;
      expect(untouched, greaterThan(0), reason: 'cancel must stop early');
      expect(runner.status, equals(RunnerStatus.idle));
    });
  });

  group('Retry policy', () {
    test('Rate limiting is retried, then the batch gives up', () async {
      await seedEntries(4);

      final provider = ScriptedProvider(
        textsPerRequest: 10,
        onTranslate: (_) async =>
            throw const RateLimited(retryAfter: Duration(milliseconds: 1)),
      );
      final runner = TranslationRunner(db: db, provider: provider);

      await runner.startTranslation(auth: auth);

      // Five attempts on one batch — never a split, which would multiply the
      // requests that caused the limit in the first place.
      expect(provider.callCount, equals(5));

      final entries = await allEntries();
      expect(entries.every((e) => e.status == 'invalid'), isTrue);
      expect(entries.first.validationJson, isNotNull);
    });

    test('InvalidResponse (generic 4xx) is not retried', () async {
      await seedEntries(2);

      final provider = ScriptedProvider(
        textsPerRequest: 10,
        onTranslate: (_) async =>
            throw const InvalidResponse('API 오류 (400): bad request'),
      );
      final runner = TranslationRunner(db: db, provider: provider);

      await runner.startTranslation(auth: auth);

      expect(provider.callCount, equals(1));
      final entries = await allEntries();
      expect(entries.every((e) => e.status == 'invalid'), isTrue);
    });

    test('A count mismatch splits the batch instead of failing it', () async {
      await seedEntries(4);

      final provider = ScriptedProvider(
        textsPerRequest: 10,
        onTranslate: (request) async {
          // Drop an item whenever more than one was asked for.
          if (request.texts.length > 1) {
            return request.texts.skip(1).map((t) => '번역_$t').toList();
          }
          return ['번역_${request.texts.first}'];
        },
      );
      final runner = TranslationRunner(db: db, provider: provider);

      await runner.startTranslation(auth: auth);

      final entries = await allEntries();
      expect(entries.every((e) => e.status == 'done'), isTrue);
    });

    test(
      'A single entry that keeps mismatching is recorded, not lost',
      () async {
        await seedEntries(1);

        final provider = ScriptedProvider(onTranslate: (_) async => <String>[]);
        final runner = TranslationRunner(db: db, provider: provider);

        await runner.startTranslation(auth: auth);

        final entry = (await allEntries()).single;
        expect(entry.status, equals('invalid'));
        expect(entry.validationJson, contains('개수 불일치'));
      },
    );
  });

  group('Error handling', () {
    test('An auth failure stops the whole queue', () async {
      await seedEntries(40);

      final provider = ScriptedProvider(
        concurrency: 1,
        textsPerRequest: 10,
        onTranslate: (_) async => throw const AuthError(),
      );
      final runner = TranslationRunner(db: db, provider: provider);

      await runner.startTranslation(auth: auth);

      expect(runner.status, equals(RunnerStatus.error));
      expect(provider.callCount, equals(1));
    });

    test('An unexpected error marks its batch instead of vanishing', () async {
      await seedEntries(2);

      final provider = ScriptedProvider(
        onTranslate: (_) async => throw StateError('boom'),
      );
      final runner = TranslationRunner(db: db, provider: provider);

      await runner.startTranslation(auth: auth);

      final entries = await allEntries();
      expect(entries.every((e) => e.status == 'invalid'), isTrue);
      expect(entries.first.validationJson, contains('알 수 없는 오류'));
    });

    test('Repeated network failures pause the run', () async {
      await seedEntries(60);

      final provider = ScriptedProvider(
        concurrency: 1,
        textsPerRequest: 10,
        onTranslate: (_) async => throw const NetworkError(),
      );
      final runner = TranslationRunner(
        db: db,
        provider: provider,
        backoffStrategy: (_) => Duration.zero,
      );

      final run = runner.startTranslation(auth: auth);

      // The run holds its place in the queue rather than ending, so the user
      // can reconnect and resume (AC-5.10).
      while (runner.status != RunnerStatus.paused) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }

      // An outage is not the entries' fault: nothing is marked 검증 실패.
      final duringOutage = await allEntries();
      expect(duringOutage.every((e) => e.status == 'wait'), isTrue);

      runner.cancel();
      await run;
    });

    test('Resuming after an outage finishes the queue', () async {
      await seedEntries(30);

      var failing = true;
      final provider = ScriptedProvider(
        concurrency: 1,
        textsPerRequest: 10,
        onTranslate: (request) async {
          if (failing) throw const NetworkError();
          return request.texts.map((t) => '번역_$t').toList();
        },
      );
      final runner = TranslationRunner(
        db: db,
        provider: provider,
        backoffStrategy: (_) => Duration.zero,
      );

      final run = runner.startTranslation(auth: auth);
      while (runner.status != RunnerStatus.paused) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }

      failing = false;
      runner.resume();
      await run;

      // The batches that failed were re-queued, not dropped.
      final entries = await allEntries();
      expect(entries.where((e) => e.status == 'done').length, equals(30));
    });
  });

  group('Validation', () {
    test('A token mismatch is never stored as a translation', () async {
      await seedEntries(1);
      await (db.update(db.entries)).write(
        EntriesCompanion(
          sourceText: const Value('Deals %s damage to %s'),
          updatedAt: Value(DateTime.now()),
        ),
      );

      // Every placeholder comes back, so restoration succeeds — but one of
      // them was duplicated, so the token multiset no longer matches.
      final provider = ScriptedProvider(
        onTranslate: (request) async => <String>[
          '${request.texts.first} ${TokenProtector.placeholder(0)}',
        ],
      );
      final runner = TranslationRunner(db: db, provider: provider);

      await runner.startTranslation(auth: auth);

      final entry = (await allEntries()).single;
      expect(entry.status, equals('invalid'));
      expect(
        entry.newTranslation,
        isNull,
        reason: 'AGENTS.md 2.1 — a rejected value must not be stored',
      );
      expect(entry.validationJson, contains('tokenMismatch'));
    });

    test('A validated translation is stored', () async {
      await seedEntries(1);
      await (db.update(db.entries)).write(
        EntriesCompanion(
          sourceText: const Value('Deals %s damage'),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final provider = ScriptedProvider(
        onTranslate: (request) async => <String>['${request.texts.first} 피해'],
      );
      final runner = TranslationRunner(db: db, provider: provider);

      await runner.startTranslation(auth: auth);

      final entry = (await allEntries()).single;
      expect(entry.status, equals('done'));
      expect(entry.newTranslation, contains('%s'));
    });
  });

  group('Namespace eligibility', () {
    test('Excluded and broken namespaces never enter the queue', () async {
      await seedEntries(2);
      final now = DateTime.now();

      await db
          .into(db.namespaces)
          .insert(
            NamespacesCompanion.insert(
              id: 'nsExcluded',
              inputFileId: 'f1',
              name: 'excluded',
              state: 'ok',
              excluded: const Value(true),
            ),
          );
      await db
          .into(db.namespaces)
          .insert(
            NamespacesCompanion.insert(
              id: 'nsBroken',
              inputFileId: 'f1',
              name: 'broken',
              state: 'jsonError',
            ),
          );
      await db.batch((b) {
        b.insertAll(db.entries, [
          EntriesCompanion.insert(
            id: 'x1',
            namespaceId: 'nsExcluded',
            key: 'k',
            keyOrder: 0,
            sourceText: 'Hidden',
            status: 'wait',
            updatedAt: now,
          ),
          EntriesCompanion.insert(
            id: 'x2',
            namespaceId: 'nsBroken',
            key: 'k',
            keyOrder: 0,
            sourceText: 'Broken',
            status: 'wait',
            updatedAt: now,
          ),
        ]);
      });

      final runner = TranslationRunner(db: db, provider: ScriptedProvider());
      await runner.startTranslation(auth: auth);

      final entries = await allEntries();
      expect(entries.firstWhere((e) => e.id == 'x1').status, equals('wait'));
      expect(entries.firstWhere((e) => e.id == 'x2').status, equals('wait'));
      // The healthy namespace still completed (AC-3.3).
      expect(
        entries
            .where((e) => e.namespaceId == 'ns1')
            .every((e) => e.status == 'done'),
        isTrue,
      );
    });
  });

  group('Concurrency', () {
    test('Requests run in parallel up to the provider limit', () async {
      await seedEntries(80);

      final provider = ScriptedProvider(
        concurrency: 4,
        textsPerRequest: 10,
        onTranslate: (request) async {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return request.texts.map((t) => '번역_$t').toList();
        },
      );
      final runner = TranslationRunner(db: db, provider: provider);

      await runner.startTranslation(auth: auth);

      expect(provider.maxInFlight, greaterThan(1));
      expect(provider.maxInFlight, lessThanOrEqualTo(4));
      expect(
        (await allEntries()).where((e) => e.status == 'done').length,
        equals(80),
      );
    });
  });

  group('Retrying failed entries', () {
    test('A second run can pick up 검증 실패 entries', () async {
      await seedEntries(2);
      await (db.update(db.entries)).write(
        EntriesCompanion(
          status: const Value('invalid'),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final runner = TranslationRunner(db: db, provider: ScriptedProvider());

      await runner.startTranslation(auth: auth);
      expect(
        (await allEntries()).every((e) => e.status == 'invalid'),
        isTrue,
        reason: 'a normal run only takes 대기 entries',
      );

      await runner.startTranslation(auth: auth, retryFailed: true);
      expect((await allEntries()).every((e) => e.status == 'done'), isTrue);
    });
  });

  group('Progress reporting', () {
    test(
      'Progress is throttled but state changes always come through',
      () async {
        await seedEntries(60);

        final runner = TranslationRunner(
          db: db,
          provider: ScriptedProvider(concurrency: 1, textsPerRequest: 1),
        );

        final messages = <String>[];
        // Subscribing before the run starts must capture every event.
        final subscription = runner.progressStream.listen((p) {
          if (p.currentMessage != null) messages.add(p.currentMessage!);
        });

        await runner.startTranslation(auth: auth);
        // Broadcast delivery is asynchronous; let the last events land.
        await Future<void>.delayed(Duration.zero);
        await subscription.cancel();

        // 60 single-entry batches, but the throttle keeps the stream far below
        // one event per batch.
        expect(messages.length, lessThan(60));
        expect(messages.last, contains('완료'));
      },
    );

    test('Per-item invalids count toward failedCount and the banner', () async {
      await seedEntries(2);
      await (db.update(db.entries)..where((t) => t.id.equals('e0'))).write(
        EntriesCompanion(
          sourceText: const Value('Deals %s damage'),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final provider = ScriptedProvider(
        textsPerRequest: 10,
        onTranslate: (request) async => [
          for (final text in request.texts)
            text.contains('\u2063') ? '피해만' : '번역_$text',
        ],
      );
      final runner = TranslationRunner(db: db, provider: provider);

      TranslationRunnerProgress? last;
      final sub = runner.progressStream.listen((p) => last = p);
      await runner.startTranslation(auth: auth);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(last, isNotNull);
      expect(last!.failedCount, greaterThan(0));
      expect(last!.currentMessage, contains('검증 실패'));
    });
  });

  group('Source echo handling', () {
    test(
      'A full-echo batch is split and finalized as fallback, not done',
      () async {
        await seedEntries(4);

        final provider = ScriptedProvider(
          textsPerRequest: 4,
          onTranslate: (request) async => List<String>.from(request.texts),
        );
        final runner = TranslationRunner(db: db, provider: provider);

        await runner.startTranslation(auth: auth);

        final entries = await allEntries();
        expect(entries.every((e) => e.status == 'fallback'), isTrue);
        expect(entries.every((e) => e.newTranslation == e.sourceText), isTrue);
        expect(provider.callCount, greaterThan(1), reason: 'must split/retry');
      },
    );

    test(
      'A 96% echo batch (48/50 pattern) triggers retry, not silent done',
      () async {
        await seedEntries(50);

        var pass = 0;
        final provider = ScriptedProvider(
          textsPerRequest: 50,
          concurrency: 1,
          onTranslate: (request) async {
            pass++;
            // First large request: echo 48, translate 2 — the burnt_basic G3 shape.
            if (request.texts.length >= 50) {
              return [
                for (var i = 0; i < request.texts.length; i++)
                  (i == 38 || i == 47)
                      ? '번역_${request.texts[i]}'
                      : request.texts[i],
              ];
            }
            // Smaller retries: still echo so singles settle as fallback.
            return List<String>.from(request.texts);
          },
        );
        final runner = TranslationRunner(db: db, provider: provider);

        await runner.startTranslation(auth: auth);

        final entries = await allEntries();
        final done = entries.where((e) => e.status == 'done').length;
        final fallback = entries.where((e) => e.status == 'fallback').length;
        // Must not accept 48 echoes as done.
        expect(done, lessThan(10));
        expect(fallback, greaterThan(40));
        expect(pass, greaterThan(1));
      },
    );

    test('A single-item echo is stored as fallback', () async {
      await seedEntries(1);

      final provider = ScriptedProvider(
        onTranslate: (request) async => List<String>.from(request.texts),
      );
      final runner = TranslationRunner(db: db, provider: provider);

      await runner.startTranslation(auth: auth);

      final entry = (await allEntries()).single;
      expect(entry.status, equals('fallback'));
      expect(entry.validationJson, contains('sourceEcho'));
    });

    test('Empty provider output is rejected', () async {
      await seedEntries(1);

      final provider = ScriptedProvider(onTranslate: (_) async => ['']);
      final runner = TranslationRunner(db: db, provider: provider);

      await runner.startTranslation(auth: auth);

      final entry = (await allEntries()).single;
      expect(entry.status, equals('invalid'));
      expect(entry.newTranslation, isNull);
      expect(entry.validationJson, contains('emptyTranslation'));
    });

    test('Control characters and excessive length are rejected', () async {
      await seedEntries(2);
      await (db.update(db.entries)..where((t) => t.id.equals('e0'))).write(
        const EntriesCompanion(sourceText: Value('Short')),
      );
      await (db.update(db.entries)..where((t) => t.id.equals('e1'))).write(
        const EntriesCompanion(sourceText: Value('Hi')),
      );

      final provider = ScriptedProvider(
        textsPerRequest: 10,
        onTranslate: (request) async => [
          for (final text in request.texts)
            if (text == 'Short') 'bad\x00text' else 'x' * 30,
        ],
      );
      final runner = TranslationRunner(db: db, provider: provider);

      await runner.startTranslation(auth: auth);

      final entries = await allEntries();
      expect(entries.every((e) => e.status == 'invalid'), isTrue);
      expect(
        entries.map((e) => e.validationJson).join(),
        contains('controlChars'),
      );
      expect(
        entries.map((e) => e.validationJson).join(),
        contains('excessiveLength'),
      );
    });

    test('Previously done echoes are requeued on the next run', () async {
      await seedEntries(2);
      final now = DateTime.now();
      await (db.update(db.entries)..where((t) => t.id.equals('e0'))).write(
        EntriesCompanion(
          status: const Value('done'),
          newTranslation: const Value('Item 0'), // echo of sourceText
          updatedAt: Value(now),
        ),
      );
      await (db.update(db.entries)..where((t) => t.id.equals('e1'))).write(
        EntriesCompanion(
          status: const Value('done'),
          newTranslation: const Value('진짜 번역'),
          updatedAt: Value(now),
        ),
      );
      // Intentional fallback must not be touched.
      await db
          .into(db.entries)
          .insert(
            EntriesCompanion.insert(
              id: 'eKeep',
              namespaceId: 'ns1',
              key: 'keep',
              keyOrder: 99,
              sourceText: 'Minecraft',
              status: 'fallback',
              newTranslation: const Value('Minecraft'),
              updatedAt: now,
            ),
          );

      final provider = ScriptedProvider(
        onTranslate: (request) async =>
            request.texts.map((t) => '번역_$t').toList(),
      );
      final runner = TranslationRunner(db: db, provider: provider);

      await runner.startTranslation(auth: auth);

      final entries = await allEntries();
      expect(entries.firstWhere((e) => e.id == 'e0').status, equals('done'));
      expect(
        entries.firstWhere((e) => e.id == 'e0').newTranslation,
        equals('번역_Item 0'),
      );
      expect(
        entries.firstWhere((e) => e.id == 'e1').newTranslation,
        equals('진짜 번역'),
      );
      expect(
        entries.firstWhere((e) => e.id == 'eKeep').status,
        equals('fallback'),
      );
    });

    test('Requeue never reaches a namespace the queue would skip', () async {
      await seedEntries(1);
      final now = DateTime.now();
      await (db.update(db.entries)..where((t) => t.id.equals('e0'))).write(
        EntriesCompanion(
          status: const Value('done'),
          newTranslation: const Value('Item 0'), // echo
          updatedAt: Value(now),
        ),
      );
      // Deselecting the namespace takes its entries out of the queue. Blanking
      // them anyway would strand them in 대기 with no value.
      await (db.update(db.namespaces)..where((t) => t.id.equals('ns1'))).write(
        const NamespacesCompanion(selected: Value(false)),
      );

      final provider = ScriptedProvider();
      final runner = TranslationRunner(db: db, provider: provider);

      await runner.startTranslation(auth: auth);

      final entry = (await allEntries()).single;
      expect(entry.status, equals('done'));
      expect(entry.newTranslation, equals('Item 0'));
      expect(provider.callCount, equals(0));
    });

    test('Echo fallbacks return to the queue only on retryFailed', () async {
      final now = DateTime.now();
      await seedEntries(1);
      await db
          .into(db.entries)
          .insert(
            EntriesCompanion.insert(
              id: 'eEcho',
              namespaceId: 'ns1',
              key: 'echo',
              keyOrder: 50,
              sourceText: 'Splash',
              status: 'fallback',
              newTranslation: const Value('Splash'),
              validationJson: const Value('{"reason":"sourceEcho"}'),
              updatedAt: now,
            ),
          );
      // User's own 원문 유지 — same shape, but never swept.
      await db
          .into(db.entries)
          .insert(
            EntriesCompanion.insert(
              id: 'eUser',
              namespaceId: 'ns1',
              key: 'user',
              keyOrder: 51,
              sourceText: 'Minecraft',
              status: 'fallback',
              newTranslation: const Value('Minecraft'),
              userTranslation: const Value('Minecraft'),
              userEdited: const Value(true),
              updatedAt: now,
            ),
          );

      final plain = ScriptedProvider(
        onTranslate: (request) async =>
            request.texts.map((t) => '번역_$t').toList(),
      );
      await TranslationRunner(
        db: db,
        provider: plain,
      ).startTranslation(auth: auth);

      var echo = (await allEntries()).firstWhere((e) => e.id == 'eEcho');
      expect(echo.status, equals('fallback'), reason: 'no sweep by default');

      final retry = ScriptedProvider(
        onTranslate: (request) async =>
            request.texts.map((t) => '번역_$t').toList(),
      );
      await TranslationRunner(
        db: db,
        provider: retry,
      ).startTranslation(auth: auth, retryFailed: true);

      final entries = await allEntries();
      echo = entries.firstWhere((e) => e.id == 'eEcho');
      expect(echo.status, equals('done'));
      expect(echo.newTranslation, equals('번역_Splash'));

      final user = entries.firstWhere((e) => e.id == 'eUser');
      expect(user.status, equals('fallback'));
      expect(user.newTranslation, equals('Minecraft'));
    });

    test('A fully echoing run does not fan out into a split tree', () async {
      await seedEntries(100);

      final provider = ScriptedProvider(
        textsPerRequest: 25,
        concurrency: 1,
        onTranslate: (request) async => List<String>.from(request.texts),
      );
      final runner = TranslationRunner(db: db, provider: provider);

      await runner.startTranslation(auth: auth);

      final entries = await allEntries();
      expect(entries.every((e) => e.status == 'fallback'), isTrue);
      // 4 initial batches × (1 batch + 2 halves + 25 singles) = 112.
      // Halves restarting at `initial` would build a binary tree: 196.
      expect(provider.callCount, equals(112));
    });
  });

  group('Cache and glossary local hits', () {
    test('cache hit skips the provider entirely', () async {
      await seedEntries(1);
      final cache = TranslationCacheStore.inMemory();
      addTearDown(cache.close);

      final key = TranslationCacheStore.buildKey(
        sourceText: 'Item 0',
        sourceLangCode: 'en_us',
        targetLangCode: 'ko_kr',
        providerId: 'scripted',
        modelId: 'scripted-model',
        glossaryFingerprint: CacheHashes.glossaryFingerprint(const []),
      );
      await cache.put(
        key: key,
        kind: CacheKind.auto,
        translation: '캐시된 아이템',
        sourceText: 'Item 0',
      );

      final provider = ScriptedProvider();
      final runner = TranslationRunner(
        db: db,
        provider: provider,
        cacheStore: cache,
      );

      await runner.startTranslation(auth: auth, model: 'scripted-model');

      expect(provider.callCount, equals(0));
      final entry = (await allEntries()).single;
      expect(entry.status, equals('cache'));
      expect(entry.newTranslation, equals('캐시된 아이템'));
    });

    test('glossary exact match skips the provider', () async {
      await seedEntries(1);
      final glossary = GlossaryStore.inMemory(projectDb: db);
      addTearDown(glossary.close);
      await glossary.upsertProject(
        const GlossaryTerm(
          id: 'g1',
          sourceTerm: 'Item 0',
          targetTerm: '용어집 아이템',
          sourceLang: 'en_us',
          targetLang: 'ko_kr',
        ),
      );

      final provider = ScriptedProvider();
      final runner = TranslationRunner(
        db: db,
        provider: provider,
        glossaryStore: glossary,
      );

      await runner.startTranslation(auth: auth);

      expect(provider.callCount, equals(0));
      final entry = (await allEntries()).single;
      expect(entry.status, equals('done'));
      expect(entry.newTranslation, equals('용어집 아이템'));
      expect(entry.validationJson, contains('glossaryExact'));
    });
  });
}
