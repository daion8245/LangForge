import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/application/db_provider.dart';
import 'package:langforge/application/scan/scan_controller.dart';
import 'package:langforge/infrastructure/db/app_database.dart';
import 'package:path/path.dart' as p;

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

  test(
    'IT-1: Add Example Mode 3 JARs -> Discover 6 namespaces & error isolation',
    () async {
      final fixturesDir = Directory(p.join('test_fixtures', 'Example Mode'));
      expect(
        fixturesDir.existsSync(),
        isTrue,
        reason: 'test_fixtures/Example Mode must exist',
      );

      final jar1 = p.join(fixturesDir.path, 'ExampleMultiNs-1.0.jar');
      final jar2 = p.join(fixturesDir.path, 'ExampleLegacy-2.1.jar');
      final jar3 = p.join(fixturesDir.path, 'ExampleBroken-0.9.jar');

      expect(File(jar1).existsSync(), isTrue);
      expect(File(jar2).existsSync(), isTrue);
      expect(File(jar3).existsSync(), isTrue);

      // Scan all 3 JARs
      await controller.addFiles([jar1, jar2, jar3]);

      // 1. Check InputFiles stored in DB
      final inputFiles = await db.select(db.inputFiles).get();
      expect(inputFiles.length, equals(3));

      // 2. Check Namespaces stored in DB
      final namespaces = await db.select(db.namespaces).get();
      expect(namespaces.length, equals(6));

      final nsNames = namespaces.map((n) => n.name).toSet();
      expect(
        nsNames,
        containsAll({
          'exalpha',
          'exbeta',
          'exgamma',
          'exlegacy',
          'exlegacyok',
          'exbroken',
        }),
      );

      // 3. Check error isolation on exbroken
      final brokenNs = namespaces.firstWhere((n) => n.name == 'exbroken');
      expect(brokenNs.state, equals('jsonError'));
      expect(brokenNs.errorMessage, isNotNull);

      // 4. Check noSource on exlegacy
      final legacyNs = namespaces.firstWhere((n) => n.name == 'exlegacy');
      expect(legacyNs.state, equals('noSource'));

      // 5. Check entries stored in DB
      final entries = await db.select(db.entries).get();
      expect(entries.isNotEmpty, isTrue);

      final exalphaEntries = entries
          .where(
            (e) =>
                e.namespaceId ==
                namespaces.firstWhere((n) => n.name == 'exalpha').id,
          )
          .toList();
      expect(exalphaEntries.length, equals(22));

      // Check existing translation 'kept' status on exalpha
      final keptEntry = exalphaEntries.firstWhere(
        (e) => e.key == 'block.exalpha.oak_hedge',
      );
      expect(keptEntry.status, equals('kept'));
      expect(keptEntry.existingTranslation, equals('참나무 산울타리'));

      // 6. The existing-translation classifier runs during the scan
      //    (TECHNICAL.md 7.2), so a value whose tokens do not match the source
      //    must land in 확인 필요 rather than being trusted as 기존 번역 유지.
      final mismatched = exalphaEntries.firstWhere(
        (e) => e.key == 'death.exalpha.escape',
      );
      expect(mismatched.status, equals('confirm'));
      expect(mismatched.warningsJson, contains('tokenMismatch'));

      // 7. An empty source is pinned to 빈 문자열 유지 and never queued for a
      //    provider.
      final emptyEntry = exalphaEntries.firstWhere(
        (e) => e.key == 'msg.exalpha.empty',
      );
      expect(emptyEntry.status, equals('empty'));

      // 8. An untranslated key still waits.
      final waiting = exalphaEntries.firstWhere(
        (e) => e.key == 'item.exalpha.ancient_tome',
      );
      expect(waiting.status, equals('wait'));
      expect(waiting.warningsJson, isNull);
    },
  );
}
