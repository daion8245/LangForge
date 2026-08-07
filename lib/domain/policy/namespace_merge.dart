import '../model/translation_entry.dart';

/// The keys one output file will contain, in the order they are written.
class MergedNamespace {
  const MergedNamespace({required this.name, required this.entries});

  /// `assets/{name}/lang/{target}.json`.
  final String name;

  /// One entry per key, already deduplicated across input files.
  final List<TranslationEntry> entries;
}

/// Folds every namespace that shares a name into one output file.
///
/// Two JARs can both ship `assets/quark/lang`, and both get their own
/// namespace row — but export writes a single `assets/quark/lang/ko_kr.json`.
/// Without this, one file would simply overwrite the other and the losing JAR's
/// keys would vanish from the pack.
///
/// Duplicate keys are settled in this order:
/// 1. the entry the user picked in the conflict modal ([resolutions]),
/// 2. otherwise the first occurrence — which is the right answer whenever the
///    source texts agree (AC-8.4), and the safe answer otherwise, since an
///    unresolved conflict blocks export before it can get here (AC-8.6).
abstract final class NamespaceMerge {
  /// [resolutions] is namespace name -> key -> winning entry id.
  static List<MergedNamespace> merge({
    required List<NamespaceUnit> namespaces,
    required List<TranslationEntry> entries,
    Map<String, Map<String, String>> resolutions = const {},
  }) {
    final entriesByNamespace = <String, List<TranslationEntry>>{};
    for (final entry in entries) {
      entriesByNamespace.putIfAbsent(entry.namespaceId, () => []).add(entry);
    }

    final nameOrder = <String>[];
    final keyOrderByName = <String, List<String>>{};
    final candidatesByName = <String, Map<String, List<TranslationEntry>>>{};

    for (final namespace in namespaces) {
      final byKey = candidatesByName.putIfAbsent(namespace.name, () {
        nameOrder.add(namespace.name);
        keyOrderByName[namespace.name] = [];
        return {};
      });

      final nsEntries = [...?entriesByNamespace[namespace.id]]
        ..sort((a, b) => a.keyOrder.compareTo(b.keyOrder));

      for (final entry in nsEntries) {
        final candidates = byKey.putIfAbsent(entry.key, () {
          keyOrderByName[namespace.name]!.add(entry.key);
          return [];
        });
        candidates.add(entry);
      }
    }

    return [
      for (final name in nameOrder)
        MergedNamespace(
          name: name,
          entries: [
            for (final key in keyOrderByName[name]!)
              _pick(candidatesByName[name]![key]!, resolutions[name]?[key]),
          ],
        ),
    ];
  }

  /// A resolution naming an entry that is no longer present falls back to the
  /// first occurrence rather than dropping the key from the pack.
  static TranslationEntry _pick(
    List<TranslationEntry> candidates,
    String? winnerId,
  ) {
    if (winnerId == null) return candidates.first;
    for (final candidate in candidates) {
      if (candidate.id == winnerId) return candidate;
    }
    return candidates.first;
  }
}
