/// Item-level checks for provider output. See TECHNICAL.md 7.3.
abstract final class TranslationResultChecks {
  /// Batch echo rate at or above this triggers split-and-retry.
  ///
  /// Must stay below 1.0 — a 48/50 (96%) echo batch must still retry.
  static const double batchEchoRetryThreshold = 0.90;

  /// Translations longer than this multiple of the source are rejected.
  static const int maxLengthMultiplier = 10;

  /// True when [translation] is byte-identical to [sourceText].
  static bool isEcho(String sourceText, String translation) =>
      translation == sourceText;

  /// Empty provider output for a non-empty source is never stored.
  static bool isEmptyTranslation(String sourceText, String translation) =>
      sourceText.isNotEmpty && translation.isEmpty;

  /// C0/C1 controls other than tab / LF / CR are abnormal in UI strings.
  static bool hasAbnormalControlChars(String text) {
    for (final unit in text.codeUnits) {
      if (unit == 0x09 || unit == 0x0A || unit == 0x0D) continue;
      if (unit < 0x20 || (unit >= 0x7F && unit <= 0x9F)) return true;
    }
    return false;
  }

  /// True when [translation] is more than [maxLengthMultiplier]× the source.
  static bool isExcessivelyLong(String sourceText, String translation) {
    if (sourceText.isEmpty) return translation.length > maxLengthMultiplier;
    return translation.length > sourceText.length * maxLengthMultiplier;
  }
}
