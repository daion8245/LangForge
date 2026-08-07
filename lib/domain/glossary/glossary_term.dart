/// One glossary row, independent of where it is stored. TECHNICAL.md 7.5.
class GlossaryTerm {
  const GlossaryTerm({
    required this.id,
    required this.sourceTerm,
    required this.targetTerm,
    required this.sourceLang,
    required this.targetLang,
    this.namespace,
    this.caseSensitive = false,
    this.note,
  });

  final String id;
  final String sourceTerm;
  final String targetTerm;
  final String sourceLang;
  final String targetLang;

  /// `null` = every namespace.
  final String? namespace;
  final bool caseSensitive;
  final String? note;
}
