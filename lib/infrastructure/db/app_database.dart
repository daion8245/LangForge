import 'package:drift/drift.dart';

import 'daos/entry_dao.dart';
import 'tables/conflicts.dart';
import 'tables/entries.dart';
import 'tables/export_records.dart';
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
  ],
  daos: [EntryDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        // Create indexes specified in TECHNICAL.md 3.3
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
      },
    );
  }
}
