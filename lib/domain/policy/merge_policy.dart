import '../model/entry_status.dart';
import '../model/translation_entry.dart';

/// Decides which of an entry's candidate values wins. See TECHNICAL.md 7.1.
abstract final class MergePolicy {
  /// Resolves the value that will be written to the output file.
  ///
  /// Priority: user edit → existing translation → glossary [1.0] →
  /// reviewed/userEdited cache [1.0] → provider / auto-cache → source text.
  ///
  /// A present-but-empty value counts as a real answer and stops the chain.
  /// A user who clears a field means "leave this blank", not "fall back to
  /// whatever was here before" — collapsing the two would silently discard
  /// their edit.
  ///
  /// [CacheKind.auto] must land in [TranslationEntry.newTranslation], never
  /// in [TranslationEntry.reviewedCacheTranslation].
  static String resolveFinal(TranslationEntry entry) {
    final user = entry.userTranslation;
    if (user != null) return user;

    final existing = entry.existingTranslation;
    if (existing != null) return existing;

    final glossary = entry.glossaryTranslation;
    if (glossary != null) return glossary;

    final reviewed = entry.reviewedCacheTranslation;
    if (reviewed != null) return reviewed;

    final fresh = entry.newTranslation;
    if (fresh != null) return fresh;

    return entry.sourceText;
  }

  /// Status to show in the list, which can differ from the stored status while
  /// a user edit is awaiting review.
  ///
  /// `원문 유지` and `빈 문자열 유지` are already decisions, not drafts. Both are
  /// written by explicitly choosing them, so showing them as `확인 필요` would
  /// ask the user to re-confirm what they just confirmed.
  static EntryStatus resolveStatus(TranslationEntry entry) {
    if (entry.status == EntryStatus.fallback ||
        entry.status == EntryStatus.empty) {
      return entry.status;
    }
    if (entry.userEdited && entry.userTranslation != null) {
      return EntryStatus.confirm;
    }
    return entry.status;
  }
}
