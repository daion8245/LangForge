import 'dart:convert';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/entry_status.dart';
import '../../domain/policy/merge_policy.dart';
import '../cache/cache_providers.dart';
import '../db_provider.dart';
import '../merge/merge_hydrator.dart';
import '../project/project_language_pair.dart';
import '../settings/engine_settings.dart';

/// One candidate the user can pick in the conflict modal (S11).
class ConflictCandidate {
  const ConflictCandidate({
    required this.entryId,
    required this.namespaceId,
    required this.inputFileId,
    required this.inputFileName,
    required this.sourceText,
    required this.translation,
    required this.status,
  });

  final String entryId;
  final String namespaceId;
  final String inputFileId;

  /// Falls back to the id when the input file row is gone, so the modal never
  /// shows a nameless option.
  final String inputFileName;

  final String sourceText;

  /// What export would write for this entry today (MergePolicy 7.1).
  final String translation;

  final EntryStatus status;
}

/// One conflict, ready to render.
class ConflictView {
  const ConflictView({
    required this.id,
    required this.namespaceName,
    required this.key,
    required this.candidates,
    this.suggestedEntryId,
    this.resolvedEntryId,
    this.resolved = false,
  });

  final String id;
  final String namespaceName;
  final String key;
  final List<ConflictCandidate> candidates;

  /// Preselected by the conflict priority setting. A hint, never a decision
  /// (AC-8.5).
  final String? suggestedEntryId;

  final String? resolvedEntryId;
  final bool resolved;

  /// What the radio group starts on: the user's own answer if they gave one,
  /// otherwise the suggestion, otherwise nothing.
  String? get initialSelection => resolvedEntryId ?? suggestedEntryId;
}

/// Every conflict in the project, resolved ones included.
///
/// The modal shows resolved rows too so a choice can be revisited; the export
/// gate only ever counts the unresolved ones.
final conflictListProvider = FutureProvider<List<ConflictView>>((ref) async {
  final db = ref.watch(appDatabaseProvider);

  final rows =
      await (db.select(db.conflicts)..orderBy([
            (t) => OrderingTerm.asc(t.namespaceName),
            (t) => OrderingTerm.asc(t.key),
          ]))
          .get();
  if (rows.isEmpty) return const [];

  final participantsByConflict = {
    for (final row in rows) row.id: _decodeParticipants(row.participantsJson),
  };

  final entryIds = {
    for (final participants in participantsByConflict.values)
      for (final participant in participants) participant.entryId,
  }.toList();

  final entryRows = await (db.select(
    db.entries,
  )..where((t) => t.id.isIn(entryIds))).get();

  final engine = ref.watch(engineSettingsProvider);
  final langs = await ProjectLanguagePair.fromDb(db);
  final hydrator = MergeHydrator(
    db: db,
    cacheStore: ref.watch(translationCacheStoreProvider),
    glossaryStore: ref.watch(glossaryStoreProvider),
    sourceLang: langs.sourceLang,
    targetLang: langs.targetLang,
    providerId: engine.providerId,
    modelId: engine.model,
  );
  final hydrated = {
    for (final entry in await hydrator.hydrateAll(entryRows)) entry.id: entry,
  };

  final fileNames = {
    for (final file in await db.select(db.inputFiles).get())
      file.id: file.originalName,
  };

  return [
    for (final row in rows)
      ConflictView(
        id: row.id,
        namespaceName: row.namespaceName,
        key: row.key,
        suggestedEntryId: row.suggestedEntryId,
        resolvedEntryId: row.resolvedEntryId,
        resolved: row.resolved,
        candidates: [
          for (final participant in participantsByConflict[row.id]!)
            () {
              final entry = hydrated[participant.entryId];
              return ConflictCandidate(
                entryId: participant.entryId,
                namespaceId: participant.namespaceId,
                inputFileId: participant.inputFileId,
                inputFileName:
                    fileNames[participant.inputFileId] ??
                    participant.inputFileId,
                sourceText: entry?.sourceText ?? participant.sourceText,
                translation: entry == null
                    ? participant.sourceText
                    : MergePolicy.resolveFinal(entry),
                status: entry?.status ?? EntryStatus.wait,
              );
            }(),
        ],
      ),
  ];
});

/// Unresolved conflicts block export outright (AC-8.6 · AC-9.2).
final unresolvedConflictCountProvider = FutureProvider<int>((ref) async {
  final conflicts = await ref.watch(conflictListProvider.future);
  return conflicts.where((conflict) => !conflict.resolved).length;
});

class _StoredParticipant {
  const _StoredParticipant({
    required this.entryId,
    required this.namespaceId,
    required this.inputFileId,
    required this.sourceText,
  });

  final String entryId;
  final String namespaceId;
  final String inputFileId;
  final String sourceText;
}

/// Tolerates rows written before the participant shape gained ids — those
/// simply have no entry to look up and fall back to their stored source text.
List<_StoredParticipant> _decodeParticipants(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is! List) return const [];
  return [
    for (final item in decoded)
      if (item is Map)
        _StoredParticipant(
          entryId: item['entryId'] as String? ?? '',
          namespaceId: item['namespaceId'] as String? ?? '',
          inputFileId: item['inputFileId'] as String? ?? '',
          sourceText: item['sourceText'] as String? ?? '',
        ),
  ];
}
