import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/model/entry_status.dart';
import 'package:langforge/infrastructure/db/app_database.dart';
import 'package:langforge/infrastructure/db/daos/entry_dao.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());

    await db
        .into(db.inputFiles)
        .insert(
          InputFilesCompanion.insert(
            id: 'f1',
            originalName: 'test.jar',
            absolutePath: '/test.jar',
            kind: 'jar',
            sizeBytes: 1,
            sha256: 'hash',
            addedAt: DateTime.now(),
            scanState: 'ok',
          ),
        );

    for (final nsId in ['ns1', 'ns2']) {
      await db
          .into(db.namespaces)
          .insert(
            NamespacesCompanion.insert(
              id: nsId,
              inputFileId: 'f1',
              name: nsId,
              state: 'ok',
            ),
          );
    }

    // 1,000 rows in ns1 — far more than one page.
    final now = DateTime.now();
    await db.batch((b) {
      b.insertAll(db.entries, [
        for (var i = 0; i < 1000; i++)
          EntriesCompanion.insert(
            id: 'ns1-e$i',
            namespaceId: 'ns1',
            key: 'block.item_$i',
            keyOrder: i,
            sourceText: 'Item $i',
            status: i % 4 == 0
                ? EntryStatus.done.wireName
                : EntryStatus.wait.wireName,
            updatedAt: now,
          ),
        for (var i = 0; i < 10; i++)
          EntriesCompanion.insert(
            id: 'ns2-e$i',
            namespaceId: 'ns2',
            key: 'gui.other_$i',
            keyOrder: i,
            sourceText: 'Other $i',
            status: EntryStatus.wait.wireName,
            updatedAt: now,
          ),
      ]);
    });
  });

  tearDown(() async => db.close());

  group('EntryDao paging', () {
    test('A page is capped at the page size, not the table size', () async {
      final page = await db.entryDao.getPage(
        const EntryQuery(namespaceId: 'ns1'),
      );
      expect(page.length, equals(entryPageSize));
    });

    test('Rows come back in original JSON key order', () async {
      final page = await db.entryDao.getPage(
        const EntryQuery(namespaceId: 'ns1'),
      );
      expect(page.first.keyOrder, equals(0));
      expect(page.last.keyOrder, equals(entryPageSize - 1));
    });

    test('The offset walks to the next page', () async {
      final second = await db.entryDao.getPage(
        const EntryQuery(namespaceId: 'ns1', offset: entryPageSize),
      );
      expect(second.first.keyOrder, equals(entryPageSize));
    });

    test('Counts are computed in SQL, independent of the page', () async {
      final count = await db.entryDao
          .watchCount(const EntryQuery(namespaceId: 'ns1'))
          .first;
      expect(count, equals(1000));
    });

    test('Status counts cover the whole namespace', () async {
      final counts = await db.entryDao
          .watchStatusCounts(namespaceId: 'ns1')
          .first;
      expect(counts[EntryStatus.done.wireName], equals(250));
      expect(counts[EntryStatus.wait.wireName], equals(750));
    });

    test('A namespace filter excludes other namespaces', () async {
      final count = await db.entryDao
          .watchCount(const EntryQuery(namespaceId: 'ns2'))
          .first;
      expect(count, equals(10));
    });

    test('A status filter narrows both page and count', () async {
      final query = EntryQuery(
        namespaceId: 'ns1',
        status: EntryStatus.done.wireName,
      );
      expect(await db.entryDao.watchCount(query).first, equals(250));
      final page = await db.entryDao.getPage(query);
      expect(page.every((e) => e.status == EntryStatus.done.wireName), isTrue);
    });

    test('Search matches key and source text', () async {
      final byKey = await db.entryDao.getPage(
        const EntryQuery(namespaceId: 'ns1', searchText: 'item_42'),
      );
      expect(byKey.map((e) => e.key), contains('block.item_42'));

      final bySource = await db.entryDao.getPage(
        const EntryQuery(namespaceId: 'ns1', searchText: 'Item 999'),
      );
      expect(bySource.single.key, equals('block.item_999'));
    });

    test('LIKE wildcards typed by the user are literal', () async {
      // Without escaping, '%' would match every row.
      final count = await db.entryDao
          .watchCount(const EntryQuery(searchText: '%'))
          .first;
      expect(count, equals(0));
    });
  });
}
