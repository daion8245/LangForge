/// Removes credentials and user-identifying paths from any text that leaves
/// the process as a log line, a report, or an error message.
///
/// See TECHNICAL.md 9.3 and 13.2.
abstract final class SensitiveFilter {
  static const String redacted = '[REDACTED]';

  /// Patterns whose whole match is a secret.
  static final List<RegExp> _wholeMatchPatterns = <RegExp>[
    // Google / Gemini API key. Real keys are AIza + 35 chars, but the length
    // is matched loosely so a truncated or future-format key still redacts.
    RegExp(r'AIza[0-9A-Za-z_\-]{16,}'),
    // DeepL auth key. The ':fx' suffix is required so that plain UUIDs — which
    // this app uses as row ids — are not mistaken for credentials.
    RegExp(
      r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}:fx',
      caseSensitive: false,
    ),
  ];

  /// Patterns where group 1 is a label worth keeping and everything after it
  /// on the same line is a credential. Matching on the label catches keys
  /// whose shape we do not know.
  ///
  /// The value is consumed to end of line, not just to the next space:
  /// `Authorization: DeepL-Auth-Key <key>` must lose the key, and TECHNICAL.md
  /// 13.2 forbids recording the Authorization header at all.
  static final List<RegExp> _labelledValuePatterns = <RegExp>[
    RegExp(
      r'((?:api[_-]?key|apikey|secret|token|authorization)\s*[:=]\s*).*',
      caseSensitive: false,
    ),
    RegExp(r'(DeepL-Auth-Key\s+).*', caseSensitive: false),
    RegExp(r'(Bearer\s+).*', caseSensitive: false),
    RegExp(r'(x-goog-api-key\s*[:=]\s*).*', caseSensitive: false),
    RegExp(r'(X-NCP-APIGW-API-KEY(?:-ID)?\s*[:=]\s*).*', caseSensitive: false),
  ];

  /// Windows user profile directory, e.g. `C:\Users\kingh`.
  static final RegExp _windowsHomePattern = RegExp(
    r'[A-Za-z]:[\\/]Users[\\/][^\\/\s"]+',
  );

  /// POSIX home directory, e.g. `/home/kingh` or `/Users/kingh`.
  static final RegExp _posixHomePattern = RegExp(r'/(?:home|Users)/[^/\s"]+');

  /// Replaces credentials with [redacted] and shortens the user's home
  /// directory to `%USERPROFILE%`.
  ///
  /// Every log record and every generated report passes through this.
  static String scrub(String input) {
    if (input.isEmpty) return input;
    var out = input;

    for (final pattern in _labelledValuePatterns) {
      out = out.replaceAllMapped(
        pattern,
        (match) => '${match.group(1)}$redacted',
      );
    }
    for (final pattern in _wholeMatchPatterns) {
      out = out.replaceAll(pattern, redacted);
    }

    return shortenHomePath(out);
  }

  /// `C:\Users\kingh\AppData\...` → `%USERPROFILE%\AppData\...`
  static String shortenHomePath(String input) {
    return input
        .replaceAll(_windowsHomePattern, r'%USERPROFILE%')
        .replaceAll(_posixHomePattern, r'%USERPROFILE%');
  }
}
