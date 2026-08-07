import '../model/entry_status.dart';
import '../model/translation_entry.dart';

/// Decides which of an entry's candidate values wins. See TECHNICAL.md 7.1.
abstract final class MergePolicy {
  /// Resolves the value that will be written to the output file.
  ///
  /// Priority: user edit → existing translation → glossary [1.0] →
  /// reviewed cache [1.0] → provider translation → source text.
  ///
  /// A present-but-empty value counts as a real answer and stops the chain.
  /// A user who clears a field means "leave this blank", not "fall back to
  /// whatever was here before" — collapsing the two would silently discard
  /// their edit.
  static String resolveFinal(TranslationEntry entry) {
    final user = entry.userTranslation;
    if (user != null) return user;

    final existing = entry.existingTranslation;
    if (existing != null) return existing;

    // 3. 프로젝트 용어집   [1.0]
    // 4. 검수된 번역 캐시   [1.0]

    final fresh = entry.newTranslation;
    if (fresh != null) return fresh;

    return entry.sourceText;
  }

  /// Status to show in the list, which can differ from the stored status while
  /// a user edit is awaiting review.
  static EntryStatus resolveStatus(TranslationEntry entry) {
    if (entry.userEdited && entry.userTranslation != null) {
      return EntryStatus.confirm;
    }
    return entry.status;
  }
}
