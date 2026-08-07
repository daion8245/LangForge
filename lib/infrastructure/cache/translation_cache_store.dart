import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import '../../domain/cache/cache_kind.dart';
import '../../domain/cache/cache_key.dart';
import '../../domain/normalize/text_post_processor.dart';
import '../../domain/protection/token_protector.dart';
import '../db/cache_database.dart';
import '../project/project_paths.dart';
import 'cache_hashes.dart';

/// One hit from [TranslationCacheStore.lookup].
class CacheHit {
  const CacheHit({required this.kind, required this.translation});

  final CacheKind kind;
  final String translation;
}

/// One row to upsert via [TranslationCacheStore.putAll].
class CacheWrite {
  const CacheWrite({
    required this.key,
    required this.kind,
    required this.translation,
    required this.sourceText,
  });

  final CacheKey key;
  final CacheKind kind;
  final String translation;
  final String sourceText;
}

/// Read/write facade over `cache.db`. See TECHNICAL.md 7.5.
class TranslationCacheStore {
  TranslationCacheStore._(this._db);

  final CacheDatabase _db;

  static Future<TranslationCacheStore> open() async {
    final file = await ProjectPaths.cacheFile();
    return TranslationCacheStore._(CacheDatabase(NativeDatabase(file)));
  }

  static TranslationCacheStore inMemory() =>
      TranslationCacheStore._(CacheDatabase(NativeDatabase.memory()));

  Future<void> close() => _db.close();

  /// Builds a key with current protector / post-processor versions.
  static CacheKey buildKey({
    required String sourceText,
    required String sourceLangCode,
    required String targetLangCode,
    required String providerId,
    String modelId = '',
    required String glossaryFingerprint,
  }) {
    return CacheKey(
      sourceHash: CacheHashes.sourceHash(sourceText),
      sourceLangCode: sourceLangCode,
      targetLangCode: targetLangCode,
      providerId: providerId,
      modelId: modelId,
      glossaryFingerprint: glossaryFingerprint,
      protectorVersion: TokenProtector.version,
      postProcessorVersion: TextPostProcessor.version,
    );
  }

  /// Prefers userEdited → reviewed → auto for the same 8-element key.
  Future<CacheHit?> lookup(CacheKey key) async {
    final map = await lookupMany([key]);
    return map[key];
  }

  /// One query for a language-pair / provider slice, then in-memory match.
  Future<Map<CacheKey, CacheHit?>> lookupMany(List<CacheKey> keys) async {
    if (keys.isEmpty) return const {};

    final byIdentity = <String, CacheKey>{};
    for (final key in keys) {
      byIdentity[_keyIdentity(key)] = key;
    }
    final unique = byIdentity.values.toList();

    // All keys in a run share lang/provider/model/versions; fingerprints vary.
    final sample = unique.first;
    final hashes = unique.map((k) => k.sourceHash).toSet().toList();
    final fingerprints = unique
        .map((k) => k.glossaryFingerprint)
        .toSet()
        .toList();

    final rows =
        await (_db.select(_db.cacheEntries)..where(
              (t) =>
                  t.sourceHash.isIn(hashes) &
                  t.glossaryFingerprint.isIn(fingerprints) &
                  t.sourceLangCode.equals(sample.sourceLangCode) &
                  t.targetLangCode.equals(sample.targetLangCode) &
                  t.providerId.equals(sample.providerId) &
                  t.modelId.equals(sample.modelId) &
                  t.protectorVersion.equals(sample.protectorVersion) &
                  t.postProcessorVersion.equals(sample.postProcessorVersion),
            ))
            .get();

    final grouped = <String, List<CacheEntry>>{};
    for (final row in rows) {
      final id = _rowIdentity(row);
      grouped.putIfAbsent(id, () => []).add(row);
    }

    final result = <CacheKey, CacheHit?>{};
    for (final key in keys) {
      final group = grouped[_keyIdentity(key)];
      if (group == null || group.isEmpty) {
        result[key] = null;
        continue;
      }
      final byKind = {for (final row in group) row.kind: row};
      CacheHit? hit;
      for (final kind in CacheKind.lookupOrder) {
        final row = byKind[kind.wireName];
        if (row != null) {
          hit = CacheHit(kind: kind, translation: row.translation);
          break;
        }
      }
      result[key] = hit;
    }
    return result;
  }

  Future<CacheHit?> lookupKind(CacheKey key, CacheKind kind) async {
    final row =
        await (_db.select(_db.cacheEntries)
              ..where(_matchesKey(key))
              ..where((t) => t.kind.equals(kind.wireName)))
            .getSingleOrNull();
    if (row == null) return null;
    return CacheHit(kind: kind, translation: row.translation);
  }

  /// Upserts a translation. [invalid] results must never call this.
  Future<void> put({
    required CacheKey key,
    required CacheKind kind,
    required String translation,
    required String sourceText,
  }) {
    return putAll([
      CacheWrite(
        key: key,
        kind: kind,
        translation: translation,
        sourceText: sourceText,
      ),
    ]);
  }

  /// Single transaction for a batch of writes (export / runner flush).
  Future<void> putAll(List<CacheWrite> writes) async {
    if (writes.isEmpty) return;
    final now = DateTime.now();
    await _db.batch((b) {
      b.insertAllOnConflictUpdate(_db.cacheEntries, [
        for (final write in writes)
          CacheEntriesCompanion.insert(
            sourceHash: write.key.sourceHash,
            sourceLangCode: write.key.sourceLangCode,
            targetLangCode: write.key.targetLangCode,
            providerId: write.key.providerId,
            modelId: write.key.modelId,
            glossaryFingerprint: write.key.glossaryFingerprint,
            protectorVersion: write.key.protectorVersion,
            postProcessorVersion: write.key.postProcessorVersion,
            kind: write.kind.wireName,
            translation: write.translation,
            sourceText: write.sourceText,
            updatedAt: now,
          ),
      ]);
    });
  }

  Expression<bool> Function($CacheEntriesTable t) _matchesKey(CacheKey key) {
    return (t) =>
        t.sourceHash.equals(key.sourceHash) &
        t.sourceLangCode.equals(key.sourceLangCode) &
        t.targetLangCode.equals(key.targetLangCode) &
        t.providerId.equals(key.providerId) &
        t.modelId.equals(key.modelId) &
        t.glossaryFingerprint.equals(key.glossaryFingerprint) &
        t.protectorVersion.equals(key.protectorVersion) &
        t.postProcessorVersion.equals(key.postProcessorVersion);
  }

  static String _keyIdentity(CacheKey key) =>
      '${key.sourceHash}\u{1f}${key.sourceLangCode}\u{1f}${key.targetLangCode}'
      '\u{1f}${key.providerId}\u{1f}${key.modelId}\u{1f}${key.glossaryFingerprint}'
      '\u{1f}${key.protectorVersion}\u{1f}${key.postProcessorVersion}';

  static String _rowIdentity(CacheEntry row) =>
      '${row.sourceHash}\u{1f}${row.sourceLangCode}\u{1f}${row.targetLangCode}'
      '\u{1f}${row.providerId}\u{1f}${row.modelId}\u{1f}${row.glossaryFingerprint}'
      '\u{1f}${row.protectorVersion}\u{1f}${row.postProcessorVersion}';
}
