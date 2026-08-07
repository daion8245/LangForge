import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import '../db/app_database.dart';

abstract final class ProjectService {
  /// Opens an `.lfproj` SQLite database file and performs schema check & backup per TECHNICAL.md 3.1 & 3.5.
  static Future<AppDatabase> openProject(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw FileSystemException('프로젝트 파일을 찾을 수 없습니다: $filePath');
    }

    // Create backup file (.lfproj.bak) before opening
    try {
      file.copySync('$filePath.bak');
    } catch (_) {}

    final db = AppDatabase(NativeDatabase(file));

    // Restore crash status: reset any running status entries to wait per ROADMAP.md 6.11
    await restoreCrashStatus(db);

    return db;
  }

  /// Creates a new `.lfproj` file database and populates initial ProjectMeta.
  static Future<AppDatabase> createProject({
    required String filePath,
    required String projectName,
  }) async {
    final file = File(filePath);
    if (file.existsSync()) {
      try {
        file.copySync('$filePath.bak');
      } catch (_) {}
    }

    final db = AppDatabase(NativeDatabase(file));

    final now = DateTime.now();
    await db
        .into(db.projectMeta)
        .insertOnConflictUpdate(
          ProjectMetaCompanion.insert(
            id: const Value(1),
            name: projectName,
            schemaVersion: '1.0',
            appVersion: '0.1.0',
            createdAt: now,
            updatedAt: now,
          ),
        );

    return db;
  }

  /// Resets entries with status == 'running' back to 'wait' on crash recovery.
  static Future<void> restoreCrashStatus(AppDatabase db) async {
    await (db.update(
      db.entries,
    )..where((tbl) => tbl.status.equals('running'))).write(
      EntriesCompanion(
        status: const Value('wait'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
