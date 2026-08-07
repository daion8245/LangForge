import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/infrastructure/export/zip_verifier.dart';
import 'package:path/path.dart' as p;

void main() {
  group('ZipVerifier Structure Tests', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('zip_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('1. Passes valid ZIP with pack.mcmeta at root', () async {
      final zipPath = p.join(tempDir.path, 'valid.zip');
      final archive = Archive()
        ..addFile(ArchiveFile('pack.mcmeta', 10, '{"pack":{}}'.codeUnits))
        ..addFile(
          ArchiveFile('assets/quark/lang/ko_kr.json', 10, '{}'.codeUnits),
        );

      final bytes = ZipEncoder().encode(archive);
      File(zipPath).writeAsBytesSync(bytes);

      await expectLater(ZipVerifier.verifyPackZip(zipPath), completes);
    });

    test('2. Fails ZIP missing pack.mcmeta', () async {
      final zipPath = p.join(tempDir.path, 'no_meta.zip');
      final archive = Archive()
        ..addFile(
          ArchiveFile('assets/quark/lang/ko_kr.json', 10, '{}'.codeUnits),
        );

      final bytes = ZipEncoder().encode(archive);
      File(zipPath).writeAsBytesSync(bytes);

      await expectLater(
        ZipVerifier.verifyPackZip(zipPath),
        throwsA(isA<ExportError>()),
      );
    });

    test('3. Fails ZIP with redundant outer pack folder', () async {
      final zipPath = p.join(tempDir.path, 'nested.zip');
      final archive = Archive()
        ..addFile(
          ArchiveFile('MyPack/pack.mcmeta', 10, '{"pack":{}}'.codeUnits),
        );

      final bytes = ZipEncoder().encode(archive);
      File(zipPath).writeAsBytesSync(bytes);

      await expectLater(
        ZipVerifier.verifyPackZip(zipPath),
        throwsA(isA<ExportError>()),
      );
    });
  });
}
