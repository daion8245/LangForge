import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/infrastructure/export/pack_icon_loader.dart';

/// The bundled icon, read from disk rather than through rootBundle so this
/// stays a plain unit test.
File bundledIcon() => File(PackIconLoader.bundledAssetPath);

void main() {
  group('Bundled pack.png', () {
    test('The asset exists where pubspec.yaml declares it', () {
      expect(bundledIcon().existsSync(), isTrue);
    });

    test('It is a real PNG', () {
      final bytes = bundledIcon().readAsBytesSync();
      expect(
        bytes.sublist(0, 8),
        equals([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]),
      );
    });

    test('It is 128x128, the size Minecraft packs ship', () {
      final bytes = bundledIcon().readAsBytesSync();
      // IHDR width and height are the two big-endian uint32s at offset 16.
      final header = ByteData.sublistView(Uint8List.fromList(bytes));
      expect(header.getUint32(16), equals(128));
      expect(header.getUint32(20), equals(128));
    });

    test('It is small enough to ship inside every exported pack', () {
      expect(bundledIcon().lengthSync(), lessThan(64 * 1024));
    });
  });

  group('PackIconMode', () {
    test('Round-trips the values stored in ProjectMeta', () {
      for (final mode in PackIconMode.values) {
        expect(PackIconMode.fromWire(mode.wireName), equals(mode));
      }
    });

    test('An unknown stored value falls back to the bundled icon', () {
      expect(
        PackIconMode.fromWire('something-else'),
        equals(PackIconMode.bundled),
      );
    });
  });

  group('PackIconLoader', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('pack_icon_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test('none means no icon at all', () async {
      expect(await PackIconLoader.load(mode: PackIconMode.none), isNull);
    });

    test('custom reads the file the user picked', () async {
      final custom = File('${tempDir.path}/custom.png')
        ..writeAsBytesSync([1, 2, 3, 4]);

      expect(
        await PackIconLoader.load(
          mode: PackIconMode.custom,
          customPath: custom.path,
        ),
        equals([1, 2, 3, 4]),
      );
    });

    test('A missing custom file does not fail the export', () async {
      // Losing a whole translation run over a cosmetic icon would be the wrong
      // trade, so this falls back instead of throwing.
      final result = await PackIconLoader.load(
        mode: PackIconMode.custom,
        customPath: '${tempDir.path}/does_not_exist.png',
      );
      expect(result, anyOf(isNull, isNotEmpty));
    });
  });
}
