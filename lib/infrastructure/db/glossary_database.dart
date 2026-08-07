import 'package:drift/drift.dart';

part 'glossary_database.g.dart';

/// Global glossary (`%APPDATA%\LangForge\glossary.db`). TECHNICAL 3.2a.
@DataClassName('GlobalGlossaryTermRow')
class GlobalGlossaryTerms extends Table {
  TextColumn get id => text()();
  TextColumn get sourceTerm => text()();
  TextColumn get targetTerm => text()();
  TextColumn get sourceLang => text()();
  TextColumn get targetLang => text()();
  TextColumn get namespace => text().nullable()();
  BoolColumn get caseSensitive =>
      boolean().withDefault(const Constant(false))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'glossary_terms';
}

@DriftDatabase(tables: [GlobalGlossaryTerms])
class GlossaryDatabase extends _$GlossaryDatabase {
  GlossaryDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_glossary_lang '
          'ON glossary_terms(source_lang, target_lang);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_glossary_ns '
          'ON glossary_terms(namespace);',
        );
      },
    );
  }
}
