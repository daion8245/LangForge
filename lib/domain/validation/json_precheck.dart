import 'dart:convert';

class JsonPrecheckResult {
  final bool isValid;
  final String? errorMessage;
  final int? errorLine;
  final Map<String, String> entries;
  final List<String> keyOrder;
  final List<String> duplicateKeys;

  const JsonPrecheckResult({
    required this.isValid,
    this.errorMessage,
    this.errorLine,
    this.entries = const {},
    this.keyOrder = const [],
    this.duplicateKeys = const [],
  });
}

abstract final class JsonPrecheck {
  /// Prechecks raw JSON string content for syntax, top-level object, string values, and duplicate keys.
  static JsonPrecheckResult check(String rawJsonStr) {
    if (rawJsonStr.trim().isEmpty) {
      return const JsonPrecheckResult(
        isValid: false,
        errorMessage: 'JSON content is empty',
        errorLine: 1,
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(rawJsonStr);
    } catch (e) {
      int? line;
      if (e is FormatException && e.offset != null) {
        line = _getLineNumberFromOffset(rawJsonStr, e.offset!);
      }
      return JsonPrecheckResult(
        isValid: false,
        errorMessage: 'Syntax error: ${e.toString()}',
        errorLine: line,
      );
    }

    if (decoded is! Map) {
      return const JsonPrecheckResult(
        isValid: false,
        errorMessage: 'Root JSON element must be an Object',
        errorLine: 1,
      );
    }

    final entries = <String, String>{};
    final keyOrder = <String>[];
    final duplicateKeys = <String>[];

    for (final entry in (decoded as Map<String, dynamic>).entries) {
      final key = entry.key.toString();
      final val = entry.value;

      if (val is! String) {
        final line = _findKeyLineNumber(rawJsonStr, key);
        return JsonPrecheckResult(
          isValid: false,
          errorMessage:
              'Unsupported structure: key "$key" contains non-string value (${val.runtimeType})',
          errorLine: line,
        );
      }

      keyOrder.add(key);
      entries[key] = val;
    }

    // jsonDecode silently keeps only the last value for a repeated key, so the
    // decoded map can never reveal a duplicate. The raw text is the only place
    // the second occurrence still exists.
    duplicateKeys.addAll(findDuplicateKeys(rawJsonStr));

    return JsonPrecheckResult(
      isValid: true,
      entries: entries,
      keyOrder: keyOrder,
      duplicateKeys: duplicateKeys,
    );
  }

  /// Scans the raw JSON text for top-level keys that appear more than once.
  ///
  /// Only depth 1 is considered: lang files are flat, and a nested object has
  /// already been rejected as an unsupported structure by the time this runs.
  static List<String> findDuplicateKeys(String rawJsonStr) {
    final seen = <String>{};
    final duplicates = <String>[];
    final chars = rawJsonStr.codeUnits;

    var depth = 0;
    var inString = false;
    var escaped = false;
    final current = StringBuffer();
    String? lastString;

    for (var i = 0; i < chars.length; i++) {
      final c = chars[i];

      if (inString) {
        if (escaped) {
          escaped = false;
          current.writeCharCode(c);
          continue;
        }
        if (c == 0x5C) {
          escaped = true;
          current.writeCharCode(c);
          continue;
        }
        if (c == 0x22) {
          inString = false;
          lastString = current.toString();
          current.clear();
          continue;
        }
        current.writeCharCode(c);
        continue;
      }

      switch (c) {
        case 0x22: // "
          inString = true;
        case 0x7B: // {
          depth++;
        case 0x7D: // }
          depth--;
        case 0x5B: // [
          depth++;
        case 0x5D: // ]
          depth--;
        case 0x3A: // :
          // The string immediately before a colon at depth 1 is a top-level key.
          if (depth == 1 && lastString != null) {
            final decodedKey = _unescape(lastString);
            if (!seen.add(decodedKey) && !duplicates.contains(decodedKey)) {
              duplicates.add(decodedKey);
            }
          }
          lastString = null;
      }
    }

    return duplicates;
  }

  static String _unescape(String raw) {
    try {
      return jsonDecode('"$raw"') as String;
    } on FormatException {
      return raw;
    }
  }

  static int _getLineNumberFromOffset(String text, int offset) {
    int line = 1;
    final clampedOffset = offset.clamp(0, text.length);
    for (int i = 0; i < clampedOffset; i++) {
      if (text[i] == '\n') line++;
    }
    return line;
  }

  static int _findKeyLineNumber(String text, String key) {
    final lines = text.split('\n');
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('"$key"')) {
        return i + 1;
      }
    }
    return 1;
  }
}
