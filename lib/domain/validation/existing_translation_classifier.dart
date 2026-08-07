import '../model/entry_status.dart';
import '../protection/multiset.dart';

/// Why an existing translation needs the user's attention.
enum ExistingTranslationWarning {
  /// The stored translation is byte-identical to the source text. That can be
  /// deliberate (a proper noun), so it is kept rather than re-translated.
  sameAsSource,

  /// Token multiset differs from the source — a variable was dropped, added,
  /// or changed. Shipping this could break the game.
  tokenMismatch,

  /// The target language file itself failed the JSON precheck, so nothing in
  /// it can be trusted.
  targetFileCorrupt,
}

class ExistingTranslationVerdict {
  const ExistingTranslationVerdict(this.status, [this.warning]);

  final EntryStatus status;
  final ExistingTranslationWarning? warning;
}

/// Classifies values found in the input file's target language JSON.
/// See TECHNICAL.md 7.2 — those values are never trusted blindly.
abstract final class ExistingTranslationClassifier {
  static ExistingTranslationVerdict classify({
    required String sourceText,
    required String? existingText,
    bool targetFileCorrupt = false,
  }) {
    // A broken target file makes every value in it suspect, so the whole
    // namespace goes back to 대기 rather than importing garbage.
    if (targetFileCorrupt) {
      return const ExistingTranslationVerdict(
        EntryStatus.wait,
        ExistingTranslationWarning.targetFileCorrupt,
      );
    }

    if (sourceText.isEmpty) {
      // Nothing to translate. TECHNICAL.md 5.4 pins these to 빈 문자열 유지 so
      // they are never sent to a provider.
      return const ExistingTranslationVerdict(EntryStatus.empty);
    }

    if (existingText == null || existingText.isEmpty) {
      return const ExistingTranslationVerdict(EntryStatus.wait);
    }

    if (existingText == sourceText) {
      return const ExistingTranslationVerdict(
        EntryStatus.kept,
        ExistingTranslationWarning.sameAsSource,
      );
    }

    if (!MultisetValidator.validate(sourceText, existingText).isMatch) {
      return const ExistingTranslationVerdict(
        EntryStatus.confirm,
        ExistingTranslationWarning.tokenMismatch,
      );
    }

    return const ExistingTranslationVerdict(EntryStatus.kept);
  }

  /// Keys present in the target language file but missing from the source.
  ///
  /// They are excluded from output (TECHNICAL.md 7.2) and listed in the
  /// report so the user knows what was dropped.
  static List<String> findStaleKeys({
    required Iterable<String> sourceKeys,
    required Iterable<String> existingKeys,
  }) {
    final source = sourceKeys.toSet();
    return existingKeys.where((k) => !source.contains(k)).toList();
  }
}
