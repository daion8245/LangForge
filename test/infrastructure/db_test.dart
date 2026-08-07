import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/infrastructure/db/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('In-memory Drift DB batch insert and query 1,000 entries', () async {
    // 1. Insert ProjectMeta
    await db
        .into(db.projectMeta)
        .insert(
          ProjectMetaCompanion.insert(
            name: 'Test Project',
            schemaVersion: '1.0',
            appVersion: '1.0.0',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

    // 2. Insert InputFile
    await db
        .into(db.inputFiles)
        .insert(
          InputFilesCompanion.insert(
            id: 'file-1',
            originalName: 'test.jar',
            absolutePath: '/path/to/test.jar',
            kind: 'jar',
            sizeBytes: 1024,
            sha256: 'dummy-sha256',
            addedAt: DateTime.now(),
            scanState: 'ok',
          ),
        );

    // 3. Insert Namespace
    await db
        .into(db.namespaces)
        .insert(
          NamespacesCompanion.insert(
            id: 'ns-1',
            inputFileId: 'file-1',
            name: 'quark',
            state: 'ok',
          ),
        );

    // 4. Batch insert 1,000 entries
    final now = DateTime.now();
    final companions = List.generate(
      1000,
      (i) => EntriesCompanion.insert(
        id: 'entry-$i',
        namespaceId: 'ns-1',
        key: 'block.quark.item_$i',
        keyOrder: i,
        sourceText: 'Item $i',
        status: 'wait',
        updatedAt: now,
      ),
    );

    await db.batch((batch) {
      batch.insertAll(db.entries, companions);
    });

    // 5. Query entries by namespace and status index
    final results =
        await (db.select(db.entries)..where(
              (tbl) =>
                  tbl.namespaceId.equals('ns-1') & tbl.status.equals('wait'),
            ))
            .get();

    expect(results.length, equals(1000));
    expect(results.first.key, equals('block.quark.item_0'));
    expect(results.last.key, equals('block.quark.item_999'));
  });
}
