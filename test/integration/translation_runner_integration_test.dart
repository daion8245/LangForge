import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/application/translation/translation_runner.dart';
import 'package:langforge/domain/provider/translation_provider.dart';
import 'package:langforge/infrastructure/db/app_database.dart';

class MockTranslationProvider implements TranslationProvider {
  MockTranslationProvider({this.decorate = false});

  /// When set, the mock imitates the noise a real LLM adds — wrapping quotes
  /// and padding — so the post-processing step can be observed.
  final bool decorate;

  @override
  String get id => 'mock';
  @override
  String get displayName => 'Mock Provider';
  @override
  List<AuthField> get authFields => [];
  @override
  List<String> get models => ['mock-model'];
  @override
  BatchLimits get limits => const BatchLimits(maxTextsPerRequest: 10);

  @override
  Future<void> verify(AuthValues auth) async {}

  @override
  Future<List<String>> translate(TranslationRequest request) async {
    return request.texts
        .map((t) => decorate ? '  "번역_$t"  ' : '번역_$t')
        .toList();
  }
}

void main() {
  late AppDatabase db;
  late TranslationRunner runner;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    runner = TranslationRunner(db: db, provider: MockTranslationProvider());
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'IT-2: TranslationRunner processes waiting entries and updates status to done/fallback',
    () async {
      final now = DateTime.now();

      // Populate DB with test entries
      await db
          .into(db.inputFiles)
          .insert(
            InputFilesCompanion.insert(
              id: 'file1',
              originalName: 'test.jar',
              sha256: 'abc123456789',
              kind: 'jar',
              absolutePath: '/path/test.jar',
              sizeBytes: 1024,
              scanState: 'ok',
              addedAt: now,
            ),
          );

      await db
          .into(db.namespaces)
          .insert(
            NamespacesCompanion.insert(
              id: 'ns1',
              inputFileId: 'file1',
              name: 'test_ns',
              state: 'ok',
            ),
          );

      await db
          .into(db.entries)
          .insert(
            EntriesCompanion.insert(
              id: 'entry1',
              namespaceId: 'ns1',
              key: 'item.test.oak',
              keyOrder: 1,
              sourceText: 'Oak Item',
              status: 'wait',
              updatedAt: now,
            ),
          );

      await db
          .into(db.entries)
          .insert(
            EntriesCompanion.insert(
              id: 'entry2',
              namespaceId: 'ns1',
              key: 'item.test.url',
              keyOrder: 2,
              sourceText: 'https://minecraft.net',
              status: 'wait',
              updatedAt: now,
            ),
          );

      final auth = const AuthValues({'apiKey': 'TEST'});

      // Start translation
      await runner.startTranslation(auth: auth);

      final updatedEntries = await db.select(db.entries).get();
      expect(updatedEntries.length, equals(2));

      final e1 = updatedEntries.firstWhere((e) => e.id == 'entry1');
      expect(e1.status, equals('done'));
      expect(e1.newTranslation, contains('번역_'));

      // A URL is excluded from translation, so it keeps its source text.
      // That is 원문 유지 ('fallback'), not 기존 번역 유지 ('kept').
      final e2 = updatedEntries.firstWhere((e) => e.id == 'entry2');
      expect(e2.status, equals('fallback'));
      expect(e2.newTranslation, equals(e2.sourceText));
    },
  );

  test(
    'IT-2b: Provider output passes through post-processing before validation',
    () async {
      final now = DateTime.now();
      final decoratingRunner = TranslationRunner(
        db: db,
        provider: MockTranslationProvider(decorate: true),
      );

      await db
          .into(db.inputFiles)
          .insert(
            InputFilesCompanion.insert(
              id: 'file1',
              originalName: 'test.jar',
              sha256: 'abc123456789',
              kind: 'jar',
              absolutePath: '/path/test.jar',
              sizeBytes: 1024,
              scanState: 'ok',
              addedAt: now,
            ),
          );
      await db
          .into(db.namespaces)
          .insert(
            NamespacesCompanion.insert(
              id: 'ns1',
              inputFileId: 'file1',
              name: 'test_ns',
              state: 'ok',
            ),
          );
      await db
          .into(db.entries)
          .insert(
            EntriesCompanion.insert(
              id: 'entry1',
              namespaceId: 'ns1',
              key: 'block.oak',
              keyOrder: 0,
              sourceText: 'Oak Hedge',
              status: 'wait',
              updatedAt: now,
            ),
          );

      await decoratingRunner.startTranslation(
        auth: const AuthValues({'apiKey': 'TEST'}),
      );

      final stored = await (db.select(
        db.entries,
      )..where((t) => t.id.equals('entry1'))).getSingle();

      // The mock returned '  "번역_Oak Hedge"  '. TECHNICAL.md 5.5 strips the
      // padding and the wrapping quotes before the value is stored.
      expect(stored.status, equals('done'));
      expect(stored.newTranslation, equals('번역_Oak Hedge'));
    },
  );
}
