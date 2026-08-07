import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/application/db_provider.dart';
import 'package:langforge/application/scan/scan_controller.dart';
import 'package:langforge/infrastructure/db/app_database.dart';
import 'package:path/path.dart' as p;

/// IT-6 — re-scanning must not undo finished work (AC-10.7 · AGENTS.md 5.7).
void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late ScanController controller;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    controller = container.read(scanControllerProvider.notifier);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('Re-scanning keeps translated and user-edited entries', () async {
    final jar = p.join(
      'test_fixtures',
      'Example Mode',
      'ExampleMultiNs-1.0.jar',
    );
    expect(File(jar).existsSync(), isTrue, reason: 'fixture must exist');

    await controller.addFiles([jar]);

    final beforeEntries = await db.select(db.entries).get();
    expect(beforeEntries, isNotEmpty);

    // Stand in for a completed run: one automatic translation and one edit the
    // user typed.
    final translated = beforeEntries.firstWhere((e) => e.status == 'wait');
    final edited = beforeEntries.lastWhere((e) => e.status == 'wait');
    expect(translated.id, isNot(equals(edited.id)));

    await (db.update(
      db.entries,
    )..where((t) => t.id.equals(translated.id))).write(
      EntriesCompanion(
        status: const Value('done'),
        newTranslation: const Value('자동 번역 결과'),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await (db.update(db.entries)..where((t) => t.id.equals(edited.id))).write(
      EntriesCompanion(
        status: const Value('confirm'),
        userTranslation: const Value('사용자가 고친 값'),
        userEdited: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );

    await controller.rescanAll();

    final afterTranslated = await (db.select(
      db.entries,
    )..where((t) => t.id.equals(translated.id))).getSingleOrNull();
    final afterEdited = await (db.select(
      db.entries,
    )..where((t) => t.id.equals(edited.id))).getSingleOrNull();

    expect(
      afterTranslated,
      isNotNull,
      reason: 'the row must survive a re-scan',
    );
    expect(afterTranslated!.status, equals('done'));
    expect(afterTranslated.newTranslation, equals('자동 번역 결과'));

    expect(afterEdited, isNotNull);
    expect(afterEdited!.status, equals('confirm'));
    expect(afterEdited.userTranslation, equals('사용자가 고친 값'));
    expect(afterEdited.userEdited, isTrue);
  });

  test('Re-scanning does not duplicate keys or lose any', () async {
    final jar = p.join(
      'test_fixtures',
      'Example Mode',
      'ExampleMultiNs-1.0.jar',
    );
    await controller.addFiles([jar]);

    final before = await db.select(db.entries).get();
    final beforeKeys = before.map((e) => '${e.namespaceId}/${e.key}').toSet();

    await controller.rescanAll();

    final after = await db.select(db.entries).get();
    final afterKeys = after.map((e) => '${e.namespaceId}/${e.key}').toSet();

    expect(after.length, equals(before.length));
    expect(afterKeys, equals(beforeKeys));

    // Key order is what the output file depends on (AC-9.11).
    final beforeOrder = {for (final e in before) e.id: e.keyOrder};
    for (final entry in after) {
      if (beforeOrder.containsKey(entry.id)) {
        expect(entry.keyOrder, equals(beforeOrder[entry.id]));
      }
    }
  });

  test('Re-scanning a project with no input files does nothing', () async {
    await controller.rescanAll();
    expect(await db.select(db.entries).get(), isEmpty);
  });
}
