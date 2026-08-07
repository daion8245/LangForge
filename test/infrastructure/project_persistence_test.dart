import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/infrastructure/db/app_database.dart';
import 'package:langforge/infrastructure/project/project_service.dart';
import 'package:path/path.dart' as p;

/// Fills [db] with one input file, one namespace and [entryCount] entries.
Future<void> seed(AppDatabase db, {int entryCount = 3}) async {
  final now = DateTime.now();
  await db
      .into(db.inputFiles)
      .insert(
        InputFilesCompanion.insert(
          id: 'f1',
          originalName: 'Example.jar',
          absolutePath: '/does/not/exist/Example.jar',
          kind: 'jar',
          sizeBytes: 10,
          sha256: 'hash-f1',
          addedAt: now,
          scanState: 'ok',
        ),
      );
  await db
      .into(db.namespaces)
      .insert(
        NamespacesCompanion.insert(
          id: 'ns1',
          inputFileId: 'f1',
          name: 'exalpha',
          state: 'ok',
        ),
      );
  await db.batch((b) {
    b.insertAll(db.entries, [
      for (var i = 0; i < entryCount; i++)
        EntriesCompanion.insert(
          id: 'e$i',
          namespaceId: 'ns1',
          key: 'item.k$i',
          keyOrder: i,
          sourceText: 'Item $i',
          status: i == 0 ? 'confirm' : 'wait',
          userTranslation: i == 0 ? const Value('사용자 번역') : const Value(null),
          userEdited: Value(i == 0),
          updatedAt: now,
        ),
    ]);
  });
}

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('lfproj_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      try {
        tempDir.deleteSync(recursive: true);
      } on FileSystemException {
        // Windows can still hold the file briefly; the OS reclaims it.
      }
    }
  });

  group('Save and reopen', () {
    test('An in-memory project survives save → close → open', () async {
      final scratch = ProjectService.inMemory();
      await seed(scratch, entryCount: 5);

      final path = p.join(tempDir.path, 'MyPack.lfproj');
      final saved = await ProjectService.saveAs(
        source: scratch,
        targetPath: path,
        projectName: 'MyPack',
      );
      await scratch.close();
      await saved.close();

      expect(File(path).existsSync(), isTrue);

      final reopened = await ProjectService.openProject(path);
      final meta = await ProjectService.readMeta(reopened);
      final entries = await reopened.select(reopened.entries).get();
      final namespaces = await reopened.select(reopened.namespaces).get();

      expect(meta!.name, equals('MyPack'));
      expect(entries.length, equals(5));
      expect(namespaces.single.name, equals('exalpha'));

      // AC-10.3 — the user's own edit came back exactly as it was.
      final edited = entries.firstWhere((e) => e.id == 'e0');
      expect(edited.status, equals('confirm'));
      expect(edited.userTranslation, equals('사용자 번역'));
      expect(edited.userEdited, isTrue);

      await reopened.close();
    });

    test('The extension is added when the user omits it', () async {
      final scratch = ProjectService.inMemory();
      final saved = await ProjectService.saveAs(
        source: scratch,
        targetPath: p.join(tempDir.path, 'NoExtension'),
        projectName: 'NoExtension',
      );
      await scratch.close();
      await saved.close();

      expect(
        File(p.join(tempDir.path, 'NoExtension.lfproj')).existsSync(),
        isTrue,
      );
    });

    test('Overwriting an existing project keeps the old one as .bak', () async {
      final path = p.join(tempDir.path, 'Twice.lfproj');

      final first = ProjectService.inMemory();
      await seed(first, entryCount: 2);
      final saved = await ProjectService.saveAs(
        source: first,
        targetPath: path,
        projectName: 'Twice',
      );
      await first.close();
      await saved.close();

      final second = ProjectService.inMemory();
      final resaved = await ProjectService.saveAs(
        source: second,
        targetPath: path,
        projectName: 'Twice',
      );
      await second.close();
      await resaved.close();

      expect(File('$path.bak').existsSync(), isTrue);
    });
  });

  group('Schema guard', () {
    test('A project from a newer app is refused', () async {
      final path = p.join(tempDir.path, 'FromTheFuture.lfproj');
      final db = await ProjectService.createProject(
        filePath: path,
        projectName: 'Future',
      );
      await (db.update(db.projectMeta)..where((t) => t.id.equals(1))).write(
        const ProjectMetaCompanion(schemaVersion: Value('99')),
      );
      await db.close();

      expect(
        () => ProjectService.openProject(path),
        throwsA(isA<ProjectTooNewException>()),
      );
    });

    test('A file that is not a project is refused', () async {
      final path = p.join(tempDir.path, 'random.lfproj');
      File(path).writeAsStringSync('this is not a database');

      expect(
        () => ProjectService.openProject(path),
        throwsA(isA<NotAProjectFileException>()),
      );
    });

    test('An older schema is migrated behind a backup', () async {
      final path = p.join(tempDir.path, 'Old.lfproj');
      final db = await ProjectService.createProject(
        filePath: path,
        projectName: 'Old',
      );
      await seed(db, entryCount: 2);
      await (db.update(db.projectMeta)..where((t) => t.id.equals(1))).write(
        const ProjectMetaCompanion(schemaVersion: Value('0')),
      );
      await db.close();

      final migrated = await ProjectService.openProject(path);
      final meta = await ProjectService.readMeta(migrated);

      expect(meta!.schemaVersion, equals('1'));
      expect(File('$path.bak').existsSync(), isTrue);
      expect((await migrated.select(migrated.entries).get()).length, equals(2));

      await migrated.close();
    });
  });

  group('Crash recovery', () {
    test('Entries left running come back as 대기', () async {
      final path = p.join(tempDir.path, 'Crashed.lfproj');
      final db = await ProjectService.createProject(
        filePath: path,
        projectName: 'Crashed',
      );
      await seed(db, entryCount: 2);
      await (db.update(db.entries)..where((t) => t.id.equals('e1'))).write(
        const EntriesCompanion(status: Value('running')),
      );
      await db.close();

      final reopened = await ProjectService.openProject(path);
      final entry = await (reopened.select(
        reopened.entries,
      )..where((t) => t.id.equals('e1'))).getSingle();

      expect(entry.status, equals('wait'));

      // The user's edit is untouched by recovery.
      final edited = await (reopened.select(
        reopened.entries,
      )..where((t) => t.id.equals('e0'))).getSingle();
      expect(edited.status, equals('confirm'));

      await reopened.close();
    });
  });

  group('Input file re-check', () {
    test(
      'A missing input file excludes its namespaces and is reported',
      () async {
        final db = ProjectService.inMemory();
        await seed(db);

        final checks = await ProjectService.verifyInputFiles(db);

        expect(checks.single.verdict, equals(InputFileVerdict.missing));
        expect(ProjectService.describeChecks(checks), contains('삭제된 입력 파일'));

        final namespace = await db.select(db.namespaces).getSingle();
        expect(namespace.excluded, isTrue, reason: 'AC-10.4');
        expect(namespace.selected, isFalse);

        final inputFile = await db.select(db.inputFiles).getSingle();
        expect(inputFile.scanState, equals('missing'));

        await db.close();
      },
    );

    test('A changed hash is reported but nothing is excluded', () async {
      final jar = File(p.join(tempDir.path, 'Real.jar'))
        ..writeAsStringSync('contents');

      final db = ProjectService.inMemory();
      final now = DateTime.now();
      await db
          .into(db.inputFiles)
          .insert(
            InputFilesCompanion.insert(
              id: 'f1',
              originalName: 'Real.jar',
              absolutePath: jar.path,
              kind: 'jar',
              sizeBytes: 8,
              sha256: 'a-hash-that-does-not-match',
              addedAt: now,
              scanState: 'ok',
            ),
          );
      await db
          .into(db.namespaces)
          .insert(
            NamespacesCompanion.insert(
              id: 'ns1',
              inputFileId: 'f1',
              name: 'exalpha',
              state: 'ok',
            ),
          );

      final checks = await ProjectService.verifyInputFiles(db);

      expect(checks.single.verdict, equals(InputFileVerdict.changed));
      expect(ProjectService.describeChecks(checks), contains('변경'));

      final namespace = await db.select(db.namespaces).getSingle();
      expect(namespace.excluded, isFalse, reason: 'AC-10.5 only warns');

      await db.close();
    });

    test('An untouched file produces no banner', () async {
      final jar = File(p.join(tempDir.path, 'Same.jar'))
        ..writeAsStringSync('contents');
      final digest = sha256.convert(jar.readAsBytesSync()).toString();

      final db = ProjectService.inMemory();
      await db
          .into(db.inputFiles)
          .insert(
            InputFilesCompanion.insert(
              id: 'f1',
              originalName: 'Same.jar',
              absolutePath: jar.path,
              kind: 'jar',
              sizeBytes: jar.lengthSync(),
              sha256: digest,
              addedAt: DateTime.now(),
              scanState: 'ok',
            ),
          );

      final checks = await ProjectService.verifyInputFiles(db);

      expect(checks.single.verdict, equals(InputFileVerdict.unchanged));
      expect(ProjectService.describeChecks(checks), isNull);

      await db.close();
    });
  });
}
