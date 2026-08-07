import 'dart:convert';

abstract final class JsonRebuilder {
  /// Reconstructs flat JSON string preserving original `keyOrder`,
  /// 2-space indentation, non-escaped UTF-8 Korean literals, and a trailing `\n`.
  static String rebuild({
    required Map<String, String> entries,
    required List<String> keyOrder,
  }) {
    final buffer = StringBuffer();
    buffer.write('{\n');

    final orderedKeys = <String>[];
    final seen = <String>{};

    for (final k in keyOrder) {
      if (entries.containsKey(k) && !seen.contains(k)) {
        orderedKeys.add(k);
        seen.add(k);
      }
    }

    // Add any remaining keys not present in keyOrder
    for (final k in entries.keys) {
      if (!seen.contains(k)) {
        orderedKeys.add(k);
      }
    }

    for (int i = 0; i < orderedKeys.length; i++) {
      final key = orderedKeys[i];
      final val = entries[key] ?? '';

      final encodedKey = jsonEncode(key);
      final encodedVal = jsonEncode(val);
      final comma = (i < orderedKeys.length - 1) ? ',' : '';

      buffer.write('  $encodedKey: $encodedVal$comma\n');
    }

    buffer.write('}\n');
    return buffer.toString();
  }
}
