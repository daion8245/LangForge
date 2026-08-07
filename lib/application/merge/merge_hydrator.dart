import 'dart:convert';

import '../../domain/cache/cache_kind.dart';
import '../../domain/cache/cache_key.dart';
import '../../domain/glossary/glossary_policy.dart';
import '../../domain/glossary/glossary_term.dart';
import '../../domain/model/entry_status.dart';
import '../../domain/model/translation_entry.dart';
import '../../infrastructure/cache/cache_hashes.dart';
import '../../infrastructure/cache/translation_cache_store.dart';
import '../../infrastructure/db/app_database.dart';
import '../../infrastructure/db/row_mappers.dart';
import '../../infrastructure/glossary/glossary_store.dart';

/// Fills MergePolicy steps 3–4 from live stores. TECHNICAL.md 7.1 · 7.5.
///
/// Glossary dual-source rule:
/// - Rows already applied as `glossaryExact` keep the **stored** snapshot in
///   [TranslationEntry.glossaryTranslation] so a later glossary edit cannot
///   silently diverge editor vs export.
/// - `wait` (and other rows without a stored translation) use a **live** exact
///   match so export can still emit glossary values without an API run.
class MergeHydrator {
  MergeHydrator({
    required this.db,
    this.cacheStore,
    this.glossaryStore,
    required this.sourceLang,
    required this.targetLang,
    required this.providerId,
    this.modelId = '',
  });

  final AppDatabase db;
  final TranslationCacheStore? cacheStore;
  final GlossaryStore? glossaryStore;
  final String sourceLang;
  final String targetLang;
  final String providerId;
  final String modelId;

  Map<String, String>? _namespaceNames;
  List<GlossaryTerm>? _mergedGlossary;

  Future<TranslationEntry> hydrate(Entry row) async {
    final list = await hydrateAll([row]);
    return list.single;
  }

  /// Batch path: one glossary load + one cache slice query for the whole set.
  Future<List<TranslationEntry>> hydrateAll(List<Entry> rows) async {
    if (rows.isEmpty) return const [];
    await _ensureLookups();

    final keys = <CacheKey>[];
    final keyByEntryId = <String, CacheKey>{};
    for (final row in rows) {
      final nsName = _namespaceNames![row.namespaceId];
      final applicable = GlossaryPolicy.applicable(
        merged: _mergedGlossary!,
        sourceLang: sourceLang,
        targetLang: targetLang,
        namespaceName: nsName,
      );
      final key = TranslationCacheStore.buildKey(
        sourceText: row.sourceText,
        sourceLangCode: sourceLang,
        targetLangCode: targetLang,
        providerId: providerId,
        modelId: modelId,
        glossaryFingerprint: CacheHashes.glossaryFingerprint(
          GlossaryPolicy.fingerprintInputs(applicable),
        ),
      );
      keys.add(key);
      keyByEntryId[row.id] = key;
    }

    final cacheHits = cacheStore == null
        ? const <CacheKey, CacheHit?>{}
        : await cacheStore!.lookupMany(keys);

    return [
      for (final row in rows) _hydrateOne(row, cacheHits[keyByEntryId[row.id]]),
    ];
  }

  TranslationEntry _hydrateOne(Entry row, CacheHit? cacheHit) {
    final entry = row.toDomain();
    final nsName = _namespaceNames![row.namespaceId];
    final applicable = GlossaryPolicy.applicable(
      merged: _mergedGlossary!,
      sourceLang: sourceLang,
      targetLang: targetLang,
      namespaceName: nsName,
    );

    final glossaryTranslation = _resolveGlossary(row, entry, applicable);

    String? reviewed;
    if (cacheHit != null && CacheKind.mergeStep4.contains(cacheHit.kind)) {
      reviewed = cacheHit.translation;
    }

    return entry.copyWith(
      glossaryTranslation: glossaryTranslation,
      reviewedCacheTranslation: reviewed,
    );
  }

  String? _resolveGlossary(
    Entry row,
    TranslationEntry entry,
    List<GlossaryTerm> applicable,
  ) {
    if (entryIsGlossaryExact(row) && entry.newTranslation != null) {
      return entry.newTranslation;
    }
    // Live match only when nothing is stored yet — avoids dual-source drift
    // for already-translated rows when the glossary is edited later.
    if (entry.status == EntryStatus.wait ||
        (entry.newTranslation == null &&
            entry.userTranslation == null &&
            entry.existingTranslation == null)) {
      return GlossaryPolicy.exactMatch(entry.sourceText, applicable);
    }
    return null;
  }

  Future<void> _ensureLookups() async {
    if (_namespaceNames != null && _mergedGlossary != null) return;
    final namespaces = await db.select(db.namespaces).get();
    _namespaceNames = {for (final ns in namespaces) ns.id: ns.name};
    final store = glossaryStore;
    if (store == null) {
      _mergedGlossary = const [];
    } else {
      store.attachProject(db);
      _mergedGlossary = await store.mergedTerms();
    }
  }
}

/// Parses [Entry.validationJson] for the glossaryExact marker.
bool entryIsGlossaryExact(Entry row) {
  final raw = row.validationJson;
  if (raw == null || raw.isEmpty) return false;
  try {
    final map = jsonDecode(raw);
    return map is Map && map['reason'] == 'glossaryExact';
  } catch (_) {
    return false;
  }
}
