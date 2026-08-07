import '../protection/token_pattern.dart';

abstract final class ExclusionPolicy {
  static final Map<String, RegExp> _excludePatterns = {
    'url': RegExp(r'^https?://\S+$'),
    'resource': RegExp(r'^[a-z0-9_.-]+:[a-z0-9/_.-]+$'),
    'path': RegExp(r'^[A-Za-z]:[\\/]|^/[\w/.-]+$'),
    'command': RegExp(r'^/\w+'),
    'uuid': RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ),
    'numeric': RegExp(r'^[\d\s.,+\-%]+$'),
  };

  /// Returns true if [text] consists purely of variables/formatting tokens.
  static bool isTokenOnly(String text) {
    final stripped = text.replaceAll(tokenPattern, '').trim();
    return stripped.isEmpty;
  }

  /// Evaluates whether a given source text should be excluded from translation.
  static bool shouldExclude(String text) {
    final trimmed = text.trim();

    if (trimmed.isEmpty) return true;
    if (isTokenOnly(trimmed)) return true;

    for (final pattern in _excludePatterns.values) {
      if (pattern.hasMatch(trimmed)) return true;
    }

    return false;
  }
}
