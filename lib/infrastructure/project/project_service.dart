import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:logging/logging.dart';

import '../../app_version.dart' as version;
import '../../domain/model/entry_status.dart';
import '../db/app_database.dart';
import '../isolate/file_verify_worker.dart';
import 'project_paths.dart';

/// The project file was written by a newer LangForge (TECHNICAL.md 3.5).
class ProjectTooNewException implements Exception {
  const ProjectTooNewException(this.fileVersion, this.appVersion);

  final int fileVersion;
  final int appVersion;

  @override
  String toString() =>
      '더 새 버전의 LangForge 로 만든 프로젝트입니다 '
      '(파일 스키마 v$fileVersion · 이 앱 v$appVersion).';
}

/// The file exists but is not a LangForge project.
class NotAProjectFileException implements Exception {
  const NotAProjectFileException(this.path);

  final String path;

  @override
  String toString() => 'LangForge 프로젝트 파일이 아닙니다: $path';
}

/// One input file's state at open time (AC-10.4 · AC-10.5).
enum InputFileVerdict { unchanged, changed, missing }

class InputFileCheck {
  const InputFileCheck({
    required this.inputFileId,
    required this.originalName,
    required this.verdict,
  });

  final String inputFileId;
  final String originalName;
  final InputFileVerdict verdict;
}

/// Opening, creating, saving and validating `.lfproj` files.
///
/// A project **is** a SQLite database, so ordinary edits are already on disk.
/// What "save" adds is the metadata touch, the recent-projects entry, and — for
/// a project that has never been saved — copying the in-memory database into a
/// real file.
abstract final class ProjectService {
  static final Logger _log = Logger('ProjectService');

  /// Bumped whenever the project schema changes. Kept separate from the Drift
  /// schema number so TECHNICAL.md 3.5's double bookkeeping is explicit.
  static const int currentSchemaVersion = 1;

  static AppDatabase inMemory() => AppDatabase(NativeDatabase.memory());

  /// Creates a new `.lfproj` at [filePath] with an initial meta row.
  static Future<AppDatabase> createProject({
    required String filePath,
    required String projectName,
    String appVersion = version.appVersion,
  }) async {
    final file = File(ProjectPaths.ensureProjectExtension(filePath));
    file.parent.createSync(recursive: true);
    if (file.existsSync()) file.deleteSync();

    final db = AppDatabase(NativeDatabase(file));
    await writeMeta(db, name: projectName, appVersion: appVersion);
    return db;
  }

  /// Opens an existing `.lfproj`.
  ///
  /// Refuses a file from a newer app, migrates one from an older app behind a
  /// `.bak`, and rolls back to that backup if the migration fails.
  static Future<AppDatabase> openProject(
    String filePath, {
    String appVersion = version.appVersion,
  }) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw FileSystemException('프로젝트 파일을 찾을 수 없습니다', filePath);
    }

    var db = AppDatabase(NativeDatabase(file));
    ProjectMetaData? meta;
    try {
      meta = await db.select(db.projectMeta).getSingleOrNull();
    } catch (error) {
      await db.close();
      _log.warning('Not a LangForge project: $filePath', error);
      throw NotAProjectFileException(filePath);
    }

    if (meta == null) {
      await db.close();
      throw NotAProjectFileException(filePath);
    }

    final fileVersion = int.tryParse(meta.schemaVersion) ?? 1;
    if (fileVersion > currentSchemaVersion) {
      await db.close();
      throw ProjectTooNewException(fileVersion, currentSchemaVersion);
    }

    if (fileVersion < currentSchemaVersion) {
      // The backup is made with the database closed so the copy cannot catch a
      // half-written page.
      await db.close();
      final backup = File('$filePath.bak');
      if (backup.existsSync()) backup.deleteSync();
      file.copySync(backup.path);

      db = AppDatabase(NativeDatabase(file));
      try {
        await _migrate(db, from: fileVersion, appVersion: appVersion);
      } catch (error, stackTrace) {
        _log.severe(
          'Migration failed; rolling back to backup',
          error,
          stackTrace,
        );
        await db.close();
        backup.copySync(filePath);
        rethrow;
      }
    }

    // A batch that was in flight when the app died is meaningless now
    // (ROADMAP 6.11).
    await restoreCrashStatus(db);
    return db;
  }

  /// Copies everything in [source] into a new project file and returns the
  /// database backed by that file.
  ///
  /// Used for the first save of a project that was built in memory, and for
  /// 다른 이름으로 저장. The staging file is only moved into place once the copy
  /// finished, so a failure never leaves a half-written project (TECHNICAL.md
  /// 8.5 applied to the project file).
  static Future<AppDatabase> saveAs({
    required AppDatabase source,
    required String targetPath,
    required String projectName,
    String appVersion = version.appVersion,
  }) async {
    final finalPath = ProjectPaths.ensureProjectExtension(targetPath);
    final finalFile = File(finalPath);
    finalFile.parent.createSync(recursive: true);

    final staging = File('$finalPath.tmp');
    if (staging.existsSync()) staging.deleteSync();

    final target = AppDatabase(NativeDatabase(staging));
    try {
      await _copyAllTables(source, target);
      await writeMeta(target, name: projectName, appVersion: appVersion);
      await target.close();
    } catch (error) {
      await target.close();
      if (staging.existsSync()) staging.deleteSync();
      rethrow;
    }

    if (finalFile.existsSync()) {
      final backup = File('$finalPath.bak');
      if (backup.existsSync()) backup.deleteSync();
      finalFile.renameSync(backup.path);
    }
    staging.renameSync(finalPath);

    return AppDatabase(NativeDatabase(finalFile));
  }

  /// Writes or refreshes the single meta row.
  static Future<void> writeMeta(
    AppDatabase db, {
    required String name,
    required String appVersion,
  }) async {
    final existing = await db.select(db.projectMeta).getSingleOrNull();
    final now = DateTime.now();

    await db
        .into(db.projectMeta)
        .insertOnConflictUpdate(
          ProjectMetaCompanion.insert(
            id: const Value(1),
            name: name,
            schemaVersion: '$currentSchemaVersion',
            appVersion: appVersion,
            createdAt: existing?.createdAt ?? now,
            updatedAt: now,
          ),
        );
  }

  /// Marks the project as saved right now (AC-10.1).
  static Future<void> touch(AppDatabase db, {required String name}) async {
    await (db.update(db.projectMeta)..where((t) => t.id.equals(1))).write(
      ProjectMetaCompanion(name: Value(name), updatedAt: Value(DateTime.now())),
    );
  }

  static Future<ProjectMetaData?> readMeta(AppDatabase db) =>
      db.select(db.projectMeta).getSingleOrNull();

  /// Resets entries left mid-flight back to 대기 (ROADMAP 6.11).
  static Future<void> restoreCrashStatus(AppDatabase db) async {
    await (db.update(
      db.entries,
    )..where((tbl) => tbl.status.equals(EntryStatus.running.wireName))).write(
      EntriesCompanion(
        status: Value(EntryStatus.wait.wireName),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Re-checks every input file on disk (AC-10.4 · AC-10.5).
  ///
  /// A file that disappeared has its namespaces excluded so the project stays
  /// usable and nothing stale is exported. A file whose hash changed is only
  /// reported — re-reading it is the user's call, since it would rebuild
  /// entries.
  static Future<List<InputFileCheck>> verifyInputFiles(AppDatabase db) async {
    final files = await db.select(db.inputFiles).get();
    if (files.isEmpty) return const [];

    final checks = <InputFileCheck>[];

    for (final file in files) {
      final result = await compute(
        verifyInputFileInIsolate,
        FileVerifyRequest(
          inputFileId: file.id,
          absolutePath: file.absolutePath,
          expectedSha256: file.sha256,
        ),
      );

      if (!result.exists) {
        await (db.update(
          db.inputFiles,
        )..where((t) => t.id.equals(file.id))).write(
          InputFilesCompanion(
            scanState: Value(ScanState.missing.wireName),
            rejectReason: const Value('파일을 찾을 수 없습니다.'),
            enabled: const Value(false),
          ),
        );
        await (db.update(
          db.namespaces,
        )..where((t) => t.inputFileId.equals(file.id))).write(
          const NamespacesCompanion(
            excluded: Value(true),
            selected: Value(false),
          ),
        );
        checks.add(
          InputFileCheck(
            inputFileId: file.id,
            originalName: file.originalName,
            verdict: InputFileVerdict.missing,
          ),
        );
        continue;
      }

      if (result.sha256 != file.sha256) {
        await (db.update(
          db.inputFiles,
        )..where((t) => t.id.equals(file.id))).write(
          InputFilesCompanion(
            scanState: Value(ScanState.changed.wireName),
            sizeBytes: Value(result.sizeBytes),
          ),
        );
        checks.add(
          InputFileCheck(
            inputFileId: file.id,
            originalName: file.originalName,
            verdict: InputFileVerdict.changed,
          ),
        );
        continue;
      }

      if (file.scanState != ScanState.ok.wireName) {
        await (db.update(
          db.inputFiles,
        )..where((t) => t.id.equals(file.id))).write(
          InputFilesCompanion(
            scanState: Value(ScanState.ok.wireName),
            rejectReason: const Value(null),
          ),
        );
      }
      checks.add(
        InputFileCheck(
          inputFileId: file.id,
          originalName: file.originalName,
          verdict: InputFileVerdict.unchanged,
        ),
      );
    }

    return checks;
  }

  /// Human-readable summary of [checks] for the banner, or null when nothing
  /// needs saying.
  static String? describeChecks(List<InputFileCheck> checks) {
    final missing = checks
        .where((c) => c.verdict == InputFileVerdict.missing)
        .toList();
    final changed = checks
        .where((c) => c.verdict == InputFileVerdict.changed)
        .toList();
    if (missing.isEmpty && changed.isEmpty) return null;

    final parts = <String>[];
    if (missing.isNotEmpty) {
      parts.add(
        '삭제된 입력 파일 ${missing.length}개를 제외했습니다 '
        '(${missing.map((c) => c.originalName).join(', ')}).',
      );
    }
    if (changed.isNotEmpty) {
      parts.add(
        '입력 파일 ${changed.length}개가 변경되었습니다. 다시 검사(Ctrl+Shift+R)를 권장합니다 '
        '(${changed.map((c) => c.originalName).join(', ')}).',
      );
    }
    return parts.join(' ');
  }

  /// MVP has one schema version, but the ladder exists from the start so a
  /// future version has somewhere to hook in (TECHNICAL.md 3.5).
  static Future<void> _migrate(
    AppDatabase db, {
    required int from,
    required String appVersion,
  }) async {
    _log.info('Migrating project from schema v$from to v$currentSchemaVersion');
    final meta = await db.select(db.projectMeta).getSingleOrNull();
    await writeMeta(
      db,
      name: meta?.name ?? 'Untitled Project',
      appVersion: appVersion,
    );
  }

  static Future<void> _copyAllTables(
    AppDatabase source,
    AppDatabase target,
  ) async {
    // Order matters: every child table has a foreign key onto the one before.
    final inputFiles = await source.select(source.inputFiles).get();
    final namespaces = await source.select(source.namespaces).get();
    final languageFiles = await source.select(source.languageFiles).get();
    final conflicts = await source.select(source.conflicts).get();
    final exportRecords = await source.select(source.exportRecords).get();

    await target.batch((b) {
      b.insertAll(
        target.inputFiles,
        inputFiles,
        mode: InsertMode.insertOrReplace,
      );
      b.insertAll(
        target.namespaces,
        namespaces,
        mode: InsertMode.insertOrReplace,
      );
      b.insertAll(
        target.languageFiles,
        languageFiles,
        mode: InsertMode.insertOrReplace,
      );
      b.insertAll(
        target.conflicts,
        conflicts,
        mode: InsertMode.insertOrReplace,
      );
      b.insertAll(
        target.exportRecords,
        exportRecords,
        mode: InsertMode.insertOrReplace,
      );
    });

    // Entries are the one table that can hold tens of thousands of rows, so it
    // is paged rather than read whole (AGENTS.md 5.6).
    const pageSize = 1000;
    var offset = 0;
    while (true) {
      final page =
          await (source.select(source.entries)
                ..orderBy([(t) => OrderingTerm.asc(t.id)])
                ..limit(pageSize, offset: offset))
              .get();
      if (page.isEmpty) break;

      await target.batch((b) {
        b.insertAll(target.entries, page, mode: InsertMode.insertOrReplace);
      });
      offset += page.length;
      if (page.length < pageSize) break;
    }
  }
}
