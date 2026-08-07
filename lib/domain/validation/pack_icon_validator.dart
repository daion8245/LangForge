import 'dart:typed_data';

/// Result of checking a candidate `pack.png` (DESIGN.md 12.2 · TECHNICAL 8.4b).
class PackIconValidation {
  const PackIconValidation._({
    required this.isValid,
    this.reason,
    this.width,
    this.height,
  });

  const PackIconValidation.ok({required int width, required int height})
    : this._(isValid: true, width: width, height: height);

  const PackIconValidation.invalid(String reason)
    : this._(isValid: false, reason: reason);

  final bool isValid;
  final String? reason;
  final int? width;
  final int? height;
}

/// Pure checks on PNG bytes — no decode library, no I/O.
///
/// Rules: PNG signature · readable IHDR · square · 64..=1024 on a side.
abstract final class PackIconValidator {
  static const pngSignature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
  static const minEdge = 64;
  static const maxEdge = 1024;

  /// IHDR needs signature (8) + length (4) + type (4) + data (13) at least.
  static const _minPngLength = 33;

  static PackIconValidation validate(List<int> bytes) {
    if (bytes.length < _minPngLength) {
      return const PackIconValidation.invalid('파일이 너무 짧거나 손상되었습니다');
    }

    for (var i = 0; i < pngSignature.length; i++) {
      if (bytes[i] != pngSignature[i]) {
        return const PackIconValidation.invalid('PNG 형식이 아닙니다');
      }
    }

    // Chunk: length(4) type(4) data… — first chunk must be IHDR.
    if (bytes[12] != 0x49 ||
        bytes[13] != 0x48 ||
        bytes[14] != 0x44 ||
        bytes[15] != 0x52) {
      return const PackIconValidation.invalid('손상된 PNG 입니다');
    }

    final header = ByteData.sublistView(Uint8List.fromList(bytes));
    final width = header.getUint32(16);
    final height = header.getUint32(20);

    if (width == 0 || height == 0) {
      return const PackIconValidation.invalid('손상된 PNG 입니다');
    }
    if (width != height) {
      return const PackIconValidation.invalid('정사각형이 아닙니다');
    }
    if (width < minEdge || width > maxEdge) {
      return PackIconValidation.invalid(
        '크기는 $minEdge×$minEdge ~ $maxEdge×$maxEdge 여야 합니다',
      );
    }

    return PackIconValidation.ok(width: width, height: height);
  }
}
