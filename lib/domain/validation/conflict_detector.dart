import '../model/translation_entry.dart';

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
  /// Finds keys that two input files disagree about: same namespace *name*,
  /// same key, different source text (AC-8.3).
  ///
  /// Grouping is by name rather than by namespace id on purpose. Every input
  /// file gets its own `NamespaceUnit` row even when two JARs both ship
  /// `assets/quark/lang`, and `entries` is unique on (namespace_id, key) — so
  /// grouping by id could never surface the case this exists to catch.
  ///
  /// Identical source text is not a conflict; the duplicate is simply the same
  /// string appearing twice (AC-8.4).
  static List<ConflictItem> detect({
    required List<NamespaceUnit> namespaces,
    required List<TranslationEntry> entries,
  }) {
    final conflicts = <ConflictItem>[];

    final nameById = {for (final ns in namespaces) ns.id: ns.name};
    // namespace name -> {key: first source text seen}
    final seenByName = <String, Map<String, String>>{};

    for (final entry in entries) {
      final nsName = nameById[entry.namespaceId];
      // An entry whose namespace was not supplied cannot be attributed, and
      // bucketing it under a placeholder would invent conflicts.
      if (nsName == null) continue;

      final seen = seenByName.putIfAbsent(nsName, () => {});
      final previous = seen[entry.key];

      if (previous == null) {
        seen[entry.key] = entry.sourceText;
        continue;
      }
      if (previous != entry.sourceText) {
        conflicts.add(
          ConflictItem(
            namespaceName: nsName,
            key: entry.key,
            sourceTextA: previous,
            sourceTextB: entry.sourceText,
          ),
        );
      }
    }

    return conflicts;
  }
}
