import '../../infrastructure/db/app_database.dart';

class ConflictItem {
  final String namespaceName;
  final String key;
  final String sourceTextA;
  final String sourceTextB;

  const ConflictItem({
    required this.namespaceName,
    required this.key,
    required this.sourceTextA,
    required this.sourceTextB,
  });
}

abstract final class ConflictDetector {
  /// Detects conflicts where multiple entries in the same namespace share the same key but have differing source texts.
  static List<ConflictItem> detect({
    required List<Namespace> namespaces,
    required List<Entry> entries,
  }) {
    final conflicts = <ConflictItem>[];

    final nsMap = {for (final ns in namespaces) ns.id: ns.name};
    final keyMap = <String, Map<String, String>>{}; // nsId -> {key: sourceText}

    for (final entry in entries) {
      final nsId = entry.namespaceId;
      final keyMapForNs = keyMap.putIfAbsent(nsId, () => {});

      if (keyMapForNs.containsKey(entry.key)) {
        final existingText = keyMapForNs[entry.key]!;
        if (existingText != entry.sourceText) {
          conflicts.add(
            ConflictItem(
              namespaceName: nsMap[nsId] ?? 'unknown',
              key: entry.key,
              sourceTextA: existingText,
              sourceTextB: entry.sourceText,
            ),
          );
        }
      } else {
        keyMapForNs[entry.key] = entry.sourceText;
      }
    }

    return conflicts;
  }
}
