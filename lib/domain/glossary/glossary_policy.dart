import '../cache/glossary_fingerprint_input.dart';
import 'glossary_term.dart';

/// Pure glossary match / violation rules. TECHNICAL.md 5.5 · 7.5.
abstract final class GlossaryPolicy {
  /// Trimmed full-string match only. Partial matches never skip the API.
  static String? exactMatch(String sourceText, List<GlossaryTerm> terms) {
    final trimmed = sourceText.trim();
    for (final term in terms) {
      if (_equals(trimmed, term.sourceTerm, term.caseSensitive)) {
        return term.targetTerm;
      }
    }
    return null;
  }

  /// `source contains sourceTerm` AND `result lacks targetTerm` → violation.
  static bool isViolation({
    required String sourceText,
    required String translation,
    required GlossaryTerm term,
  }) {
    if (!_contains(sourceText, term.sourceTerm, term.caseSensitive)) {
      return false;
    }
    return !_contains(translation, term.targetTerm, term.caseSensitive);
  }

  static List<GlossaryTerm> findViolations({
    required String sourceText,
    required String translation,
    required List<GlossaryTerm> terms,
  }) {
    return [
      for (final term in terms)
        if (isViolation(
          sourceText: sourceText,
          translation: translation,
          term: term,
        ))
          term,
    ];
  }

  /// Rows that apply to [namespaceName] for a language pair.
  static List<GlossaryTerm> applicable({
    required List<GlossaryTerm> merged,
    required String sourceLang,
    required String targetLang,
    required String? namespaceName,
  }) {
    return [
      for (final term in merged)
        if (term.sourceLang == sourceLang &&
            term.targetLang == targetLang &&
            (term.namespace == null || term.namespace == namespaceName))
          term,
    ];
  }

  /// Project rows win over global rows with the same identity key.
  static List<GlossaryTerm> mergeProjectOverGlobal({
    required List<GlossaryTerm> global,
    required List<GlossaryTerm> project,
  }) {
    final byIdentity = <String, GlossaryTerm>{};
    for (final term in global) {
      byIdentity[_identity(term)] = term;
    }
    for (final term in project) {
      byIdentity[_identity(term)] = term;
    }
    return byIdentity.values.toList();
  }

  static List<GlossaryFingerprintInput> fingerprintInputs(
    List<GlossaryTerm> applicableTerms,
  ) {
    return [
      for (final term in applicableTerms)
        GlossaryFingerprintInput(
          sourceTerm: term.sourceTerm,
          targetTerm: term.targetTerm,
          namespace: term.namespace,
          caseSensitive: term.caseSensitive,
        ),
    ];
  }

  static String _identity(GlossaryTerm term) =>
      '${term.sourceTerm}\u{1f}${term.sourceLang}\u{1f}${term.targetLang}\u{1f}${term.namespace ?? ''}';

  static bool _equals(String a, String b, bool caseSensitive) {
    if (caseSensitive) return a == b;
    return a.toLowerCase() == b.toLowerCase();
  }

  static bool _contains(String haystack, String needle, bool caseSensitive) {
    if (needle.isEmpty) return false;
    if (caseSensitive) return haystack.contains(needle);
    return haystack.toLowerCase().contains(needle.toLowerCase());
  }
}
