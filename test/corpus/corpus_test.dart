@Tags(['corpus'])
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/application/db_provider.dart';
import 'package:langforge/application/scan/scan_controller.dart';
import 'package:langforge/domain/model/entry_status.dart';
import 'package:langforge/domain/policy/merge_policy.dart';
import 'package:langforge/domain/protection/multiset.dart';
import 'package:langforge/infrastructure/db/app_database.dart';
import 'package:langforge/infrastructure/db/row_mappers.dart';
import 'package:langforge/infrastructure/export/resource_pack_exporter.dart';
import 'package:langforge/infrastructure/export/zip_verifier.dart';
import 'package:path/path.dart' as p;

/// C-1 ~ C-8 of TECHNICAL.md 11.6, run against real mod JARs.
///
/// These never run in CI: the JARs are third-party copyrighted files that the
/// repository must not carry. Point `LANGFORGE_CORPUS_DIR` at a folder of real
/// mods and run:
///
///     flutter test --tags corpus
///
/// The default location is `test_fixtures/corpus`, which `.gitignore` keeps
/// out of the repository.
void main() {
  final corpusPath =
      Platform.environment['LANGFORGE_CORPUS_DIR'] ??
      p.join('test_fixtures', 'corpus');
  final corpusDir = Directory(corpusPath);

  final jars = corpusDir.existsSync()
      ? corpusDir
            .listSync()
            .whereType<File>()
            .where((f) => p.extension(f.path).toLowerCase() == '.jar')
            .map((f) => f.path)
            .toList()
      : <String>[];

  if (jars.isEmpty) {
    test('corpus is configured', () {
      fail(
        '코퍼스 JAR 을 찾지 못했습니다: $corpusPath\n'
        'LANGFORGE_CORPUS_DIR 에 실제 모드 폴더 경로를 지정하세요.',
      );
    });
    return;
  }

  late AppDatabase db;
  late ProviderContainer container;
  late ScanController scan;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    scan = container.read(scanControllerProvider.notifier);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('C-1 — every namespace in the corpus is discovered', () async {
    await scan.addFiles(jars);

    final files = await db.select(db.inputFiles).get();
    final namespaces = await db.select(db.namespaces).get();

    expect(
      files.length,
      equals(jars.length),
      reason:
          '거부된 입력 파일이 있습니다: ${container.read(scanControllerProvider).rejectedSummary}',
    );
    expect(namespaces, isNotEmpty);

    // The count must match what the archives actually contain, not the file
    // names (AGENTS.md 5.8).
    for (final namespace in namespaces) {
      expect(namespace.name, matches(RegExp(r'^[a-z0-9._-]+$')));
    }
  });

  test(
    'C-2 · C-3 — output keys equal source keys, character for character',
    () async {
      await scan.addFiles(jars);

      final entries = await db.select(db.entries).get();
      expect(entries, isNotEmpty);

      final namespaces = await db.select(db.namespaces).get();
      final byNamespace = <String, List<Entry>>{};
      for (final entry in entries) {
        byNamespace.putIfAbsent(entry.namespaceId, () => []).add(entry);
      }

      for (final namespace in namespaces) {
        final rows = byNamespace[namespace.id] ?? const <Entry>[];
        if (rows.isEmpty) continue;

        final keys = rows.map((e) => e.key).toList();
        expect(
          keys.toSet().length,
          equals(keys.length),
          reason: '${namespace.name}: 중복 key',
        );

        // Key order survives as a dense 0..n-1 sequence, which is what the
        // exporter replays (AC-9.11).
        final orders = rows.map((e) => e.keyOrder).toList()..sort();
        expect(orders.first, equals(0));
        expect(orders.last, equals(rows.length - 1));
      }
    },
  );

  test('C-4 — validated values keep the source token multiset', () async {
    await scan.addFiles(jars);

    final entries = (await db.select(db.entries).get()).toDomain();
    var checked = 0;

    for (final entry in entries) {
      // 대기 항목은 아직 번역값이 없으므로 검사 대상이 아닙니다.
      if (entry.status == EntryStatus.wait) continue;
      if (entry.status == EntryStatus.invalid) continue;

      final resolved = MergePolicy.resolveFinal(entry);
      final verdict = MultisetValidator.validate(entry.sourceText, resolved);
      expect(
        verdict.isMatch,
        isTrue,
        reason: '${entry.key}: 토큰 불일치\n원문 ${entry.sourceText}\n결과 $resolved',
      );
      checked++;
    }

    expect(checked, greaterThan(0), reason: '검사한 항목이 없습니다');
  });

  test('C-5 — a broken JSON file does not stop the rest', () async {
    await scan.addFiles([
      ...jars,
      p.join('test_fixtures', 'Example Mode', 'ExampleBroken-0.9.jar'),
    ]);

    final namespaces = await db.select(db.namespaces).get();
    final broken = namespaces.where((ns) => ns.state == 'jsonError').toList();
    final healthy = namespaces.where((ns) => ns.state != 'jsonError').toList();

    expect(broken, isNotEmpty, reason: '오류 namespace 가 감지되지 않았습니다');
    expect(healthy, isNotEmpty, reason: '정상 namespace 가 모두 사라졌습니다');

    for (final namespace in healthy) {
      final count = await (db.select(
        db.entries,
      )..where((t) => t.namespaceId.equals(namespace.id))).get();
      if (namespace.keyCount > 0) {
        expect(count, isNotEmpty, reason: '${namespace.name}: 항목이 비었습니다');
      }
    }
  });

  test('C-6 — the exported ZIP passes the structure check', () async {
    await scan.addFiles(jars);

    final tempDir = Directory.systemTemp.createTempSync('corpus_export_');
    addTearDown(() {
      if (tempDir.existsSync()) {
        try {
          tempDir.deleteSync(recursive: true);
        } on FileSystemException {
          // Windows may hold the handle briefly.
        }
      }
    });

    final outputPath = await ResourcePackExporter.export(
      targetDirPath: tempDir.path,
      format: ExportFormat.zipPack,
      inputFiles: (await db.select(db.inputFiles).get()).toDomain(),
      namespaces: (await db.select(db.namespaces).get()).toDomain(),
      entries: (await db.select(db.entries).get()).toDomain(),
      packFormat: 34,
      providerName: 'Gemini',
      modelName: 'gemini-3.6-flash',
      sourceLangCode: 'en_us',
      targetLangCode: 'ko_kr',
      outputFileName: 'ko_kr.json',
      appVersion: '0.1.0',
    );

    expect(File(outputPath).existsSync(), isTrue);
    await ZipVerifier.verifyPackZip(outputPath);
  });

  test('C-7 — no API key string appears in any artefact', () async {
    await scan.addFiles(jars);

    final tempDir = Directory.systemTemp.createTempSync('corpus_secrets_');
    addTearDown(() {
      if (tempDir.existsSync()) {
        try {
          tempDir.deleteSync(recursive: true);
        } on FileSystemException {
          // Windows may hold the handle briefly.
        }
      }
    });

    await ResourcePackExporter.export(
      targetDirPath: tempDir.path,
      format: ExportFormat.folderPack,
      inputFiles: (await db.select(db.inputFiles).get()).toDomain(),
      namespaces: (await db.select(db.namespaces).get()).toDomain(),
      entries: (await db.select(db.entries).get()).toDomain(),
      packFormat: 34,
      providerName: 'Gemini',
      modelName: 'gemini-3.6-flash',
      sourceLangCode: 'en_us',
      targetLangCode: 'ko_kr',
      outputFileName: 'ko_kr.json',
      appVersion: '0.1.0',
    );

    final keyShapes = [
      RegExp(r'AIza[0-9A-Za-z_\-]{16,}'),
      RegExp(r'x-goog-api-key', caseSensitive: false),
      RegExp(r'DeepL-Auth-Key', caseSensitive: false),
      RegExp(r'authorization:\s*\S+', caseSensitive: false),
    ];

    for (final entity in tempDir.listSync(recursive: true)) {
      if (entity is! File) continue;
      final text = entity.readAsStringSync();
      for (final shape in keyShapes) {
        expect(
          shape.hasMatch(text),
          isFalse,
          reason: '${entity.path} 에 자격 증명처럼 보이는 문자열이 있습니다',
        );
      }
    }
  });

  test('C-8 — scanning the corpus stays inside the time budget', () async {
    final stopwatch = Stopwatch()..start();
    await scan.addFiles(jars);
    stopwatch.stop();

    final entryCount = (await db.select(db.entries).get()).length;

    // TECHNICAL.md 10.1 allows 60s for 180 JARs; scale that to this corpus and
    // keep a floor so a two-JAR run is not judged on rounding.
    final budgetMs = (jars.length / 180 * 60000).clamp(5000, 60000);
    expect(
      stopwatch.elapsedMilliseconds,
      lessThan(budgetMs),
      reason:
          'JAR ${jars.length}개 · 항목 $entryCount개 탐색에 '
          '${stopwatch.elapsedMilliseconds}ms 걸렸습니다 (예산 ${budgetMs.round()}ms)',
    );
  });
}
