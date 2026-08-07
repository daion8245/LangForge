class ResourcePathInfo {
  final String namespace;
  final String rawCode;

  /// The archive entry path exactly as stored, used for extraction.
  final String entryPath;
  final bool hasUppercaseNamespace;

  const ResourcePathInfo({
    required this.namespace,
    required this.rawCode,
    required this.entryPath,
    this.hasUppercaseNamespace = false,
  });
}

abstract final class ResourcePathParser {
  static final RegExp _langPathPattern = RegExp(
    r'^assets/([A-Za-z0-9._-]+)/lang/([A-Za-z0-9_.-]+)\.json$',
    caseSensitive: false,
  );

  /// Checks whether [path] matches `assets/{namespace}/lang/{code}.json`.
  static bool isLangResource(String path) {
    final unified = path.replaceAll('\\', '/');
    return _langPathPattern.hasMatch(unified);
  }

  /// Parses [path] into [ResourcePathInfo] if valid, or null if invalid.
  static ResourcePathInfo? parse(String path) {
    final unified = path.replaceAll('\\', '/');
    final match = _langPathPattern.firstMatch(unified);
    if (match == null) return null;

    final rawNs = match.group(1)!;
    final rawCode = match.group(2)!;

    final hasUpper = rawNs != rawNs.toLowerCase();
    final ns = rawNs.toLowerCase();

    // Verify depth is strictly 4 segments: assets / ns / lang / code.json
    final segments = unified.split('/');
    if (segments.length != 4) return null;

    return ResourcePathInfo(
      namespace: ns,
      rawCode: rawCode,
      // The archive entry must be addressed exactly as it is stored. Rebuilding
      // it from the lowercased namespace would miss `assets/Quark/...`
      // (TECHNICAL.md 4.5).
      entryPath: unified,
      hasUppercaseNamespace: hasUpper,
    );
  }
}
