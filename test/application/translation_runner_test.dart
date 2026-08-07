import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/application/translation/translation_runner.dart';
import 'package:langforge/domain/protection/token_protector.dart';
import 'package:langforge/domain/provider/translation_error.dart';
import 'package:langforge/domain/provider/translation_provider.dart';
import 'package:langforge/infrastructure/db/app_database.dart';

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
  });
}
