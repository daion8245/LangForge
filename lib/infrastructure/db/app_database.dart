import 'package:drift/drift.dart';

import 'daos/entry_dao.dart';
import 'tables/conflicts.dart';
import 'tables/entries.dart';
import 'tables/export_records.dart';
import 'tables/glossary_terms.dart';
import 'tables/input_files.dart';
import 'tables/language_files.dart';
import 'tables/namespaces.dart';
import 'tables/project_meta.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    ProjectMeta,
    InputFiles,
    Namespaces,
    LanguageFiles,
    Entries,
    Conflicts,
    ExportRecords,
    GlossaryTerms,
  ],
  daos: [EntryDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        await _createIndexes();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(glossaryTerms);
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_glossary_lang '
            'ON glossary_terms(source_lang, target_lang);',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_glossary_ns '
            'ON glossary_terms(namespace);',
          );
        }
        if (from < 3) {
          await m.addColumn(projectMeta, projectMeta.conflictPriority);
          await m.addColumn(conflicts, conflicts.suggestedEntryId);
        }
      },
    );
  }

  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_entries_ns_key ON entries(namespace_id, key);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_entries_status ON entries(namespace_id, status);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_entries_order ON entries(namespace_id, key_order);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_entries_edited ON entries(user_edited) WHERE user_edited = 1;',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_ns_input ON namespaces(input_file_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_ns_name ON namespaces(name);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_langfile_ns ON language_files(namespace_id);',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_input_hash ON input_files(sha256);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_glossary_lang '
      'ON glossary_terms(source_lang, target_lang);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_glossary_ns '
      'ON glossary_terms(namespace);',
    );
  }
}
