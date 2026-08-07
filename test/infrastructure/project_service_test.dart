import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/infrastructure/db/app_database.dart';
import 'package:langforge/infrastructure/project/project_service.dart';
import 'package:path/path.dart' as p;

void main() {
  group('ProjectService & Crash Recovery Tests', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('project_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('1. Creates new .lfproj file and initial ProjectMeta', () async {
      final projPath = p.join(tempDir.path, 'TestProject.lfproj');
      final db = await ProjectService.createProject(
        filePath: projPath,
        projectName: 'Test Project',
      );

      final meta = await db.select(db.projectMeta).getSingle();
      expect(meta.name, equals('Test Project'));
      expect(File(projPath).existsSync(), isTrue);

      await db.close();
    });

    test(
      '2. Resets running status entries back to wait on crash recovery',
      () async {
        final projPath = p.join(tempDir.path, 'CrashProject.lfproj');
        final db = await ProjectService.createProject(
          filePath: projPath,
          projectName: 'Crash Project',
        );

        final now = DateTime.now();

        await db
            .into(db.inputFiles)
            .insert(
              InputFilesCompanion.insert(
                id: 'file1',
                originalName: 'test.jar',
                sha256: 'abc123456789',
                kind: 'jar',
                absolutePath: '/path/test.jar',
                sizeBytes: 1024,
                scanState: 'ok',
                addedAt: now,
              ),
            );

        await db
            .into(db.namespaces)
            .insert(
              NamespacesCompanion.insert(
                id: 'ns1',
                inputFileId: 'file1',
                name: 'test_ns',
                state: 'ok',
              ),
            );

        await db
            .into(db.entries)
            .insert(
              EntriesCompanion.insert(
                id: 'e1',
                namespaceId: 'ns1',
                key: 'item.test',
                keyOrder: 1,
                sourceText: 'Source',
                status: 'running', // Interrupted running status
                updatedAt: now,
              ),
            );

        await ProjectService.restoreCrashStatus(db);

        final updatedEntry = await db.select(db.entries).getSingle();
        expect(updatedEntry.status, equals('wait'));

        await db.close();
      },
    );
  });
}
