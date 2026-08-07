import '../model/translation_entry.dart';

/// One side of a conflict: the entry a single input file contributed.
class ConflictParticipant {
  const ConflictParticipant({
    required this.entryId,
    required this.namespaceId,
    required this.inputFileId,
    required this.addOrder,
    required this.sourceText,
  });

  final String entryId;
  final String namespaceId;
  final String inputFileId;

  /// Position of the contributing input file in add order (0 = added first).
  ///
  /// Passed in rather than derived here so the domain rule stays independent of
  /// how files are stored; the caller sorts by `added_at` then `id` so the value
  /// is deterministic.
  final int addOrder;

  final String sourceText;
}

class ConflictItem {
  const ConflictItem({
    required this.namespaceName,
    required this.key,
    required this.participants,
  });

  final String namespaceName;
  final String key;

  /// Two or more entries with differing source text, in add order.
  final List<ConflictParticipant> participants;

  /// The first source text seen. Kept for the two-participant case, which is
  /// what the scan flow produces in practice.
  String get sourceTextA => participants.first.sourceText;

  /// The first source text that differs from [sourceTextA].
  String get sourceTextB =>
      participants.firstWhere((p) => p.sourceText != sourceTextA).sourceText;
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
  ///
  /// [inputFileOrder] maps an input file id to its add-order index. Files
  /// missing from the map sort last, in the order their entries appear.
  static List<ConflictItem> detect({
    required List<NamespaceUnit> namespaces,
    required List<TranslationEntry> entries,
    Map<String, int> inputFileOrder = const {},
  }) {
    final namespaceById = {for (final ns in namespaces) ns.id: ns};

    // namespace name -> key -> participants
    final grouped = <String, Map<String, List<ConflictParticipant>>>{};
    // Preserves first-seen order so the output does not depend on Map internals.
    final order = <(String, String)>[];

    for (final entry in entries) {
      final namespace = namespaceById[entry.namespaceId];
      // An entry whose namespace was not supplied cannot be attributed, and
      // bucketing it under a placeholder would invent conflicts.
      if (namespace == null) continue;

      final byKey = grouped.putIfAbsent(namespace.name, () => {});
      final participants = byKey.putIfAbsent(entry.key, () {
        order.add((namespace.name, entry.key));
        return [];
      });

      participants.add(
        ConflictParticipant(
          entryId: entry.id,
          namespaceId: entry.namespaceId,
          inputFileId: namespace.inputFileId,
          addOrder:
              inputFileOrder[namespace.inputFileId] ?? inputFileOrder.length,
          sourceText: entry.sourceText,
        ),
      );
    }

    final conflicts = <ConflictItem>[];
    for (final (namespaceName, key) in order) {
      final participants = grouped[namespaceName]![key]!;
      if (participants.length < 2) continue;

      final distinct = participants.map((p) => p.sourceText).toSet();
      if (distinct.length < 2) continue;

      final sorted = [...participants]
        ..sort((a, b) {
          final byOrder = a.addOrder.compareTo(b.addOrder);
          if (byOrder != 0) return byOrder;
          return a.entryId.compareTo(b.entryId);
        });

      conflicts.add(
        ConflictItem(
          namespaceName: namespaceName,
          key: key,
          participants: sorted,
        ),
      );
    }

    return conflicts;
  }
}
