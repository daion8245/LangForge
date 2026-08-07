/// One glossary row's contribution to [glossaryFingerprint].
///
/// Ordering and hashing happen in infrastructure; this is the sorted payload.
class GlossaryFingerprintInput implements Comparable<GlossaryFingerprintInput> {
  const GlossaryFingerprintInput({
    required this.sourceTerm,
    required this.targetTerm,
    this.namespace,
    required this.caseSensitive,
  });

  final String sourceTerm;
  final String targetTerm;

  /// `null` means applies to every namespace.
  final String? namespace;
  final bool caseSensitive;

  /// Canonical line used before SHA-256. Stable across platforms.
  String get canonicalLine {
    final ns = namespace ?? '';
    final cs = caseSensitive ? '1' : '0';
    return '$sourceTerm\u{1f}$targetTerm\u{1f}$ns\u{1f}$cs';
  }

  @override
  int compareTo(GlossaryFingerprintInput other) {
    final bySource = sourceTerm.compareTo(other.sourceTerm);
    if (bySource != 0) return bySource;
    final byTarget = targetTerm.compareTo(other.targetTerm);
    if (byTarget != 0) return byTarget;
    final byNs = (namespace ?? '').compareTo(other.namespace ?? '');
    if (byNs != 0) return byNs;
    return (caseSensitive ? 1 : 0).compareTo(other.caseSensitive ? 1 : 0);
  }
}
