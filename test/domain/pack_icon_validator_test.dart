import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/validation/pack_icon_validator.dart';

List<int> _png({required int width, required int height}) {
  final bytes = Uint8List(33);
  const sig = PackIconValidator.pngSignature;
  for (var i = 0; i < sig.length; i++) {
    bytes[i] = sig[i];
  }
  // IHDR length = 13
  bytes[11] = 13;
  bytes[12] = 0x49; // I
  bytes[13] = 0x48; // H
  bytes[14] = 0x44; // D
  bytes[15] = 0x52; // R
  final view = ByteData.sublistView(bytes);
  view.setUint32(16, width);
  view.setUint32(20, height);
  return bytes;
}

void main() {
  group('PackIconValidator', () {
    test('accepts a square PNG in range', () {
      final result = PackIconValidator.validate(_png(width: 128, height: 128));
      expect(result.isValid, isTrue);
      expect(result.width, 128);
    });

    test('rejects non-PNG', () {
      expect(PackIconValidator.validate([1, 2, 3, 4]).isValid, isFalse);
    });

    test('rejects non-square', () {
      final result = PackIconValidator.validate(_png(width: 128, height: 64));
      expect(result.isValid, isFalse);
      expect(result.reason, contains('정사각형'));
    });

    test('rejects too small', () {
      final result = PackIconValidator.validate(_png(width: 32, height: 32));
      expect(result.isValid, isFalse);
    });

    test('rejects too large', () {
      final result = PackIconValidator.validate(
        _png(width: 2048, height: 2048),
      );
      expect(result.isValid, isFalse);
    });
  });
}
