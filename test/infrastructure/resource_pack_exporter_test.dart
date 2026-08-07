import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/model/entry_status.dart';
import 'package:langforge/domain/model/translation_entry.dart';
import 'package:langforge/infrastructure/export/resource_pack_exporter.dart';
import 'package:langforge/infrastructure/export/zip_verifier.dart';
import 'package:path/path.dart' as p;

final inputFiles = [
  const InputFileUnit(
    id: 'f1',
    originalName: 'test.jar',
    kind: 'jar',
    sizeBytes: 100,
    sha256: 'abc123456789',
    scanState: ScanState.ok,
  ),
];

final namespaces = [
  const NamespaceUnit(
    id: 'ns1',
    inputFileId: 'f1',
    name: 'quark',
    state: NamespaceState.ok,
    keyCount: 2,
  ),
];

final entries = [
  const TranslationEntry(
    id: 'e1',
    namespaceId: 'ns1',
    key: 'block.oak_hedge',
    keyOrder: 0,
    sourceText: 'Oak Hedge',
    newTranslation: '참나무 산울타리',
    status: EntryStatus.done,
  ),
  const TranslationEntry(
    id: 'e2',
    namespaceId: 'ns1',
    key: 'item.rune',
    keyOrder: 1,
    sourceText: 'Rune',
    newTranslation: '룬 · 문양 “테스트”',
    status: EntryStatus.done,
  ),
];

Future<String> runExport(
  Directory dir,
  ExportFormat format, {
  List<int>? packIconBytes,
}) {
  return ResourcePackExporter.export(
    targetDirPath: dir.path,
    format: format,
    inputFiles: inputFiles,
    namespaces: namespaces,
    entries: entries,
    packFormat: 15,
    providerName: 'Gemini',
    modelName: 'gemini-3.6-flash',
    sourceLangCode: 'en_us',
    targetLangCode: 'ko_kr',
    outputFileName: 'ko_kr.json',
    appVersion: '0.1.0',
    packIconBytes: packIconBytes,
  );
}

void main() {
  group('ResourcePackExporter', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('export_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test('Writes a ZIP pack with pack.mcmeta at the root', () async {
      final zipPath = await runExport(tempDir, ExportFormat.zipPack);

      expect(File(zipPath).existsSync(), isTrue);
      expect(p.basename(zipPath), equals('KO_Translation_Pack.zip'));

      final archive = ZipDecoder().decodeBytes(File(zipPath).readAsBytesSync());
      final names = archive.files.map((f) => f.name).toList();
      expect(names, contains('pack.mcmeta'));
      expect(names, contains('assets/quark/lang/ko_kr.json'));
      expect(names.any((n) => n.contains('\\')), isFalse);
    });

    test('Korean text survives the round trip as UTF-8', () async {
      final zipPath = await runExport(tempDir, ExportFormat.zipPack);
      final archive = ZipDecoder().decodeBytes(File(zipPath).readAsBytesSync());

      final langFile = archive.files.firstWhere(
        (f) => f.name == 'assets/quark/lang/ko_kr.json',
      );
      final decoded =
          jsonDecode(utf8.decode(langFile.content as List<int>))
              as Map<String, dynamic>;

      expect(decoded['block.oak_hedge'], equals('참나무 산울타리'));
      expect(decoded['item.rune'], equals('룬 · 문양 “테스트”'));
    });

    test('Key order matches the original JSON order', () async {
      final zipPath = await runExport(tempDir, ExportFormat.zipPack);
      final archive = ZipDecoder().decodeBytes(File(zipPath).readAsBytesSync());
      final langFile = archive.files.firstWhere(
        (f) => f.name == 'assets/quark/lang/ko_kr.json',
      );
      final text = utf8.decode(langFile.content as List<int>);

      expect(
        text.indexOf('block.oak_hedge'),
        lessThan(text.indexOf('item.rune')),
      );
    });

    test('The report is written beside the pack, not inside it', () async {
      final zipPath = await runExport(tempDir, ExportFormat.zipPack);
      final archive = ZipDecoder().decodeBytes(File(zipPath).readAsBytesSync());

      expect(
        archive.files.any((f) => f.name.endsWith('.md')),
        isFalse,
        reason: 'TECHNICAL.md 8.1 fixes the pack contents',
      );
      expect(
        File(p.join(tempDir.path, 'Translation_Report.md')).existsSync(),
        isTrue,
      );
    });

    test('pack.png is included when an icon is supplied', () async {
      final zipPath = await runExport(
        tempDir,
        ExportFormat.zipPack,
        packIconBytes: <int>[0x89, 0x50, 0x4E, 0x47],
      );
      final archive = ZipDecoder().decodeBytes(File(zipPath).readAsBytesSync());

      expect(archive.files.map((f) => f.name), contains('pack.png'));
    });

    test('Folder pack writes UTF-8 JSON under assets/', () async {
      final path = await runExport(tempDir, ExportFormat.folderPack);
      final langFile = File(
        p.join(path, 'assets', 'quark', 'lang', 'ko_kr.json'),
      );

      expect(langFile.existsSync(), isTrue);
      final decoded =
          jsonDecode(utf8.decode(langFile.readAsBytesSync()))
              as Map<String, dynamic>;
      expect(decoded['block.oak_hedge'], equals('참나무 산울타리'));
      expect(File(p.join(path, 'pack.mcmeta')).existsSync(), isTrue);
    });

    test('Path-preserving JSON keeps the assets/{ns}/lang shape', () async {
      await runExport(tempDir, ExportFormat.pathJson);
      expect(
        File(
          p.join(tempDir.path, 'assets', 'quark', 'lang', 'ko_kr.json'),
        ).existsSync(),
        isTrue,
      );
    });

    test('Re-exporting keeps the previous output as a backup', () async {
      final first = await runExport(tempDir, ExportFormat.zipPack);
      await runExport(tempDir, ExportFormat.zipPack);

      expect(File('$first.bak').existsSync(), isTrue);
      expect(File(first).existsSync(), isTrue);
    });

    test('No staging directory is left behind', () async {
      await runExport(tempDir, ExportFormat.zipPack);
      final leftovers = Directory.systemTemp
          .listSync()
          .whereType<Directory>()
          .where((d) => p.basename(d.path).startsWith('langforge_export_'));
      expect(leftovers, isEmpty);
    });

    test('Folder pack carries pack.png when an icon is supplied', () async {
      final path = await runExport(
        tempDir,
        ExportFormat.folderPack,
        packIconBytes: <int>[0x89, 0x50, 0x4E, 0x47],
      );

      expect(File(p.join(path, 'pack.png')).existsSync(), isTrue);
    });

    test('Verification rejects a lang path with the wrong shape', () async {
      // Guards the assets/{ns}/lang/{file} rule from TECHNICAL.md 7.3.
      final badZip = File(p.join(tempDir.path, 'bad.zip'));
      final archive = Archive()
        ..addFile(_textFile('pack.mcmeta', '{}'))
        ..addFile(_textFile('assets/quark/ko_kr.json', '{}'));
      badZip.writeAsBytesSync(ZipEncoder().encode(archive));

      await expectLater(
        ZipVerifier.verifyPackZip(badZip.path),
        throwsA(isA<ExportError>()),
      );
    });

    test('Verification rejects a pack with no language files', () async {
      final emptyZip = File(p.join(tempDir.path, 'empty.zip'));
      final archive = Archive()..addFile(_textFile('pack.mcmeta', '{}'));
      emptyZip.writeAsBytesSync(ZipEncoder().encode(archive));

      await expectLater(
        ZipVerifier.verifyPackZip(emptyZip.path),
        throwsA(isA<ExportError>()),
      );
    });

    test('Verification rejects a misplaced pack.png', () async {
      final zip = File(p.join(tempDir.path, 'nested_icon.zip'));
      final archive = Archive()
        ..addFile(_textFile('pack.mcmeta', '{}'))
        ..addFile(_textFile('assets/quark/lang/ko_kr.json', '{}'))
        ..addFile(_textFile('Pack/pack.png', 'x'));
      zip.writeAsBytesSync(ZipEncoder().encode(archive));

      await expectLater(
        ZipVerifier.verifyPackZip(zip.path),
        throwsA(isA<ExportError>()),
      );
    });
  });
}

ArchiveFile _textFile(String name, String content) {
  final bytes = utf8.encode(content);
  return ArchiveFile(name, bytes.length, bytes);
}
