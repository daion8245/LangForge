import 'text_normalizer.dart';

/// Cleans up a provider's output before it is validated and stored.
/// See TECHNICAL.md 5.5.
///
/// Every rule here is conservative in the same direction: it removes noise the
/// translator added, and never adds meaning the source did not have. When in
/// doubt about whether something came from the source, it is preserved.
abstract final class TextPostProcessor {
  /// Runs steps 2–6 of TECHNICAL.md 5.5. Step 1 (placeholder restoration) has
  /// already happened by the time this is called, and step 7 (glossary) is
  /// [1.0].
  ///
  /// [normalizer] performs step 5. It defaults to doing nothing so that pure
  /// domain tests need no wiring; the running app injects a real one.
  static String process(
    String sourceText,
    String translatedText, {
    TextNormalizer normalizer = const NoopTextNormalizer(),
  }) {
    if (translatedText.isEmpty) return translatedText;

    var result = translatedText;
    result = _collapseSpaces(sourceText, result);
    result = _trimEdges(sourceText, result);
    result = _stripWrappingQuotes(sourceText, result);
    result = normalizer.toNfc(result);
    result = _stripControlCharacters(sourceText, result);
    return result;
  }

  /// 2. Collapse runs of spaces, unless the source itself has them.
  static String _collapseSpaces(String sourceText, String value) {
    if (sourceText.contains(_multipleSpaces)) return value;
    return value.replaceAll(_multipleSpaces, ' ');
  }

  /// 3. Trim each edge only where the source has no space there.
  static String _trimEdges(String sourceText, String value) {
    var result = value;
    if (!sourceText.startsWith(' ')) result = result.trimLeft();
    if (!sourceText.endsWith(' ')) result = result.trimRight();
    return result;
  }

  /// 4. Drop quotes the translator wrapped around the whole string.
  ///
  /// Runs after trimming so that `  "번역"  ` is handled, and only when the
  /// source was not quoted itself.
  static String _stripWrappingQuotes(String sourceText, String value) {
    if (value.length < 2) return value;

    for (final pair in _quotePairs) {
      final open = pair[0];
      final close = pair[1];
      if (value.startsWith(open) &&
          value.endsWith(close) &&
          !sourceText.startsWith(open)) {
        final inner = value.substring(1, value.length - 1);
        // A string like `"a" and "b"` is not a quoted whole; leave it alone.
        if (inner.contains(open) || inner.contains(close)) return value;
        return inner;
      }
    }
    return value;
  }

  /// 6. Remove control characters the translator introduced.
  ///
  /// A control character that also appears in the source is deliberate — the
  /// mod author put it there — so it stays.
  static String _stripControlCharacters(String sourceText, String value) {
    final buffer = StringBuffer();
    for (final unit in value.runes) {
      if (_isStrippableControl(unit) && !sourceText.runes.contains(unit)) {
        continue;
      }
      buffer.writeCharCode(unit);
    }
    return buffer.toString();
  }

  /// C0 and C1 control characters, excluding tab, newline and carriage return.
  static bool _isStrippableControl(int rune) {
    if (rune == 0x09 || rune == 0x0A || rune == 0x0D) return false;
    return rune < 0x20 || (rune >= 0x7F && rune <= 0x9F);
  }

  static final RegExp _multipleSpaces = RegExp(r' {2,}');

  static const List<String> _quotePairs = ['""', '“”', "''", '‘’', '「」'];
}
