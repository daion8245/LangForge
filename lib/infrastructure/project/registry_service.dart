import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:logging/logging.dart';

import '../db/registry_database.dart';
import 'project_paths.dart';

/// The recent-projects list in `%APPDATA%\LangForge\registry.db`.
///
/// Separate from the project database on purpose: it survives every project
/// and holds nothing a user would want inside a `.lfproj` they hand to someone
/// else (TECHNICAL.md 3.1).
class RegistryService {
  RegistryService._(this._db);

  static final Logger _log = Logger('RegistryService');

  final RegistryDatabase _db;

  static Future<RegistryService> open() async {
    final file = await ProjectPaths.registryFile();
    return RegistryService._(RegistryDatabase(NativeDatabase(file)));
  }

  /// For tests: an isolated registry that never touches the user's machine.
  static RegistryService inMemory() =>
      RegistryService._(RegistryDatabase(NativeDatabase.memory()));

  Future<List<RecentProject>> recentProjects() => _db.getRecentProjects();

  /// Records a project as most recently opened. The path is the identity — a
  /// project moved to a new folder is a new row, and the stale one is dropped
  /// by [prune].
  Future<void> remember({
    required String path,
    required String name,
    int totalKeys = 0,
    int doneKeys = 0,
    bool hasMissingFiles = false,
  }) async {
    await _db.addOrUpdateRecentProject(
      RecentProjectsCompanion.insert(
        id: path,
        name: name,
        path: path,
        lastOpenedAt: DateTime.now(),
        totalKeys: Value(totalKeys),
        doneKeys: Value(doneKeys),
        hasMissingFiles: Value(hasMissingFiles),
      ),
    );
  }

  Future<void> forget(String path) => _db.removeRecentProject(path);

  /// Drops entries whose file is gone, so the start screen never offers a
  /// project that cannot be opened.
  Future<void> prune() async {
    for (final project in await _db.getRecentProjects()) {
      if (!File(project.path).existsSync()) {
        _log.info('Pruning missing recent project');
        await _db.removeRecentProject(project.id);
      }
    }
  }

  Future<void> close() => _db.close();
}
