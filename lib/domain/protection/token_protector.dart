import 'token_pattern.dart';

class ProtectedText {
  final String masked;
  final List<String> tokens;

  const ProtectedText({required this.masked, required this.tokens});
}

abstract final class TokenProtector {
  /// Bump when substitution rules change so cache keys diverge (TECHNICAL 7.5).
  static const String version = '1';

  /// Invisible separator U+2063 wrapper for placeholders
  static String placeholder(int index) => '\u{2063}LF$index\u{2063}';

  /// Replaces all variables and formatting codes matching `tokenPattern`
  /// with invisible placeholders (`\u{2063}LF{i}\u{2063}`).
  static ProtectedText protect(String text) {
    if (text.isEmpty) {
      return const ProtectedText(masked: '', tokens: []);
    }

    final tokens = <String>[];
    int tokenIndex = 0;

    final masked = text.replaceAllMapped(tokenPattern, (match) {
      final tokenStr = match.group(0)!;
      tokens.add(tokenStr);
      final p = placeholder(tokenIndex);
      tokenIndex++;
      return p;
    });

    return ProtectedText(masked: masked, tokens: tokens);
  }

  /// Restores original tokens from placeholders in [translatedText].
  /// Returns null if placeholders are missing or corrupted.
  static String? restore(ProtectedText protected, String translatedText) {
    if (protected.tokens.isEmpty) return translatedText;

    String result = translatedText;

    for (int i = 0; i < protected.tokens.length; i++) {
      final p = placeholder(i);
      final token = protected.tokens[i];

      if (!result.contains(p)) {
        // Placeholder was deleted or corrupted by translation engine
        return null;
      }
      result = result.replaceAll(p, token);
    }

    // Check if any leftover placeholders remain
    if (RegExp('\u2063LF\\d+\u2063').hasMatch(result)) {
      return null;
    }

    return result;
  }
}
