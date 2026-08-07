import 'package:unorm_dart/unorm_dart.dart' as unorm;

import '../../domain/normalize/text_normalizer.dart';

/// NFC normalization backed by `unorm_dart`.
///
/// Minecraft language files are UTF-8 but say nothing about composition form.
/// A translation provider can return decomposed Hangul (NFD), which renders
/// the same in game but compares and searches differently from the composed
/// text everywhere else in the project.
class UnicodeTextNormalizer implements TextNormalizer {
  const UnicodeTextNormalizer();

  @override
  String toNfc(String input) {
    if (input.isEmpty) return input;
    return unorm.nfc(input);
  }
}
