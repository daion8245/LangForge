import 'package:drift/drift.dart';

part 'cache_database.g.dart';

/// Global translation cache (`%APPDATA%\LangForge\cache.db`). TECHNICAL 3.2a.
class CacheEntries extends Table {
  TextColumn get sourceHash => text()();
  TextColumn get sourceLangCode => text()();
  TextColumn get targetLangCode => text()();
  TextColumn get providerId => text()();
  TextColumn get modelId => text()();
  TextColumn get glossaryFingerprint => text()();
  TextColumn get protectorVersion => text()();
  TextColumn get postProcessorVersion => text()();

  /// [CacheKind] wire name.
  TextColumn get kind => text()();
  TextColumn get translation => text()();

  /// Debug only — never part of the lookup key.
  TextColumn get sourceText => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {
    sourceHash,
    sourceLangCode,
    targetLangCode,
    providerId,
    modelId,
    glossaryFingerprint,
    protectorVersion,
    postProcessorVersion,
    kind,
  };
}

@DriftDatabase(tables: [CacheEntries])
class CacheDatabase extends _$CacheDatabase {
  CacheDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        await customStatement('''
CREATE INDEX IF NOT EXISTS idx_cache_lookup ON cache_entries(
  source_hash, source_lang_code, target_lang_code, provider_id, model_id,
  glossary_fingerprint, protector_version, post_processor_version
);
''');
      },
    );
  }
}
