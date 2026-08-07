/// The eight fields that identify a cache row. See TECHNICAL.md 7.5.
///
/// Hashes are computed outside this type (domain must stay package-free).
/// Changing any field yields a different key — that is the miss rule.
class CacheKey {
  const CacheKey({
    required this.sourceHash,
    required this.sourceLangCode,
    required this.targetLangCode,
    required this.providerId,
    required this.modelId,
    required this.glossaryFingerprint,
    required this.protectorVersion,
    required this.postProcessorVersion,
  });

  /// SHA-256 of the raw source text before token protection.
  final String sourceHash;
  final String sourceLangCode;
  final String targetLangCode;
  final String providerId;

  /// Empty string when the provider has no model concept.
  final String modelId;
  final String glossaryFingerprint;
  final String protectorVersion;
  final String postProcessorVersion;

  CacheKey copyWith({
    String? sourceHash,
    String? sourceLangCode,
    String? targetLangCode,
    String? providerId,
    String? modelId,
    String? glossaryFingerprint,
    String? protectorVersion,
    String? postProcessorVersion,
  }) {
    return CacheKey(
      sourceHash: sourceHash ?? this.sourceHash,
      sourceLangCode: sourceLangCode ?? this.sourceLangCode,
      targetLangCode: targetLangCode ?? this.targetLangCode,
      providerId: providerId ?? this.providerId,
      modelId: modelId ?? this.modelId,
      glossaryFingerprint: glossaryFingerprint ?? this.glossaryFingerprint,
      protectorVersion: protectorVersion ?? this.protectorVersion,
      postProcessorVersion: postProcessorVersion ?? this.postProcessorVersion,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CacheKey &&
        other.sourceHash == sourceHash &&
        other.sourceLangCode == sourceLangCode &&
        other.targetLangCode == targetLangCode &&
        other.providerId == providerId &&
        other.modelId == modelId &&
        other.glossaryFingerprint == glossaryFingerprint &&
        other.protectorVersion == protectorVersion &&
        other.postProcessorVersion == postProcessorVersion;
  }

  @override
  int get hashCode => Object.hash(
    sourceHash,
    sourceLangCode,
    targetLangCode,
    providerId,
    modelId,
    glossaryFingerprint,
    protectorVersion,
    postProcessorVersion,
  );
}
