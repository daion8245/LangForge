import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../domain/model/entry_status.dart';
import '../../infrastructure/db/app_database.dart';
import '../../infrastructure/db/registry_database.dart';
import '../../infrastructure/project/project_paths.dart';
import '../../infrastructure/project/project_service.dart';
import '../../infrastructure/project/registry_service.dart';

/// Result of asking the session to save.
enum SaveOutcome {
  saved,

  /// The project has never been saved, so the caller must ask the user where
  /// to put it (AC-10.8).
  needsLocation,

  /// Nothing was open, or nothing had changed.
  skipped,
  failed,
}

/// The project currently loaded in the app.
class ProjectSession {
  const ProjectSession({
    required this.db,
    this.isOpen = false,
    this.filePath,
    this.name = defaultName,
    this.isDirty = false,
    this.isSaving = false,
    this.lastSavedAt,
    this.notices = const [],
    this.errorMessage,
    this.autoSaveEnabled = true,
  });

  static const String defaultName = 'Untitled Project';

  /// Always present so providers that read the database never see null. When
  /// no project is open this is a scratch in-memory database.
  final AppDatabase db;

  /// False while the start screen (S0) is showing.
  final bool isOpen;

  /// Null until the project has been saved somewhere.
  final String? filePath;

  final String name;
  final bool isDirty;
  final bool isSaving;
  final DateTime? lastSavedAt;

  /// Banner text produced by opening — missing or changed input files.
  final List<String> notices;

  final String? errorMessage;

  /// Mirrors `togglesJson.autoSave` so [markDirty] does not need an async read.
  final bool autoSaveEnabled;

  bool get hasFile => filePath != null;

  ProjectSession copyWith({
    AppDatabase? db,
    bool? isOpen,
    String? filePath,
    String? name,
    bool? isDirty,
    bool? isSaving,
    DateTime? lastSavedAt,
    List<String>? notices,
    String? errorMessage,
    bool? autoSaveEnabled,
    bool clearFilePath = false,
    bool clearError = false,
  }) {
    return ProjectSession(
      db: db ?? this.db,
      isOpen: isOpen ?? this.isOpen,
      filePath: clearFilePath ? null : (filePath ?? this.filePath),
      name: name ?? this.name,
      isDirty: isDirty ?? this.isDirty,
      isSaving: isSaving ?? this.isSaving,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
      notices: notices ?? this.notices,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      autoSaveEnabled: autoSaveEnabled ?? this.autoSaveEnabled,
    );
  }
}

/// Opens, saves, and closes the project, and owns its database.
///
/// A `.lfproj` is a SQLite file, so ordinary edits are written the moment they
/// happen. Saving is therefore about three things: giving an in-memory project
/// a file for the first time, stamping the metadata, and keeping the recent
/// list current (TECHNICAL.md 3.1).
class ProjectSessionController extends Notifier<ProjectSession> {
  static final Logger _log = Logger('ProjectSession');

  /// TECHNICAL.md 10.2 — ordinary changes coalesce into one save.
  static const Duration autoSaveDebounce = Duration(seconds: 2);

  Timer? _autoSaveTimer;

  /// Mirrors `state.db`. Riverpod forbids reading `state` from a life-cycle
  /// callback, so disposal needs its own handle on the open database.
  AppDatabase? _openDatabase;

  @override
  ProjectSession build() {
    final scratch = ProjectService.inMemory();
    _openDatabase = scratch;
    ref.onDispose(() {
      _autoSaveTimer?.cancel();
      unawaited(_openDatabase?.close());
      _openDatabase = null;
    });
    return ProjectSession(db: scratch);
  }

  /// Starts an empty project. It lives in memory until the first save, which
  /// is when the user is asked for a location (AC-10.8).
  Future<void> newProject() async {
    await _swapDatabase(ProjectService.inMemory());
    state = state.copyWith(
      isOpen: true,
      name: ProjectSession.defaultName,
      isDirty: false,
      notices: const [],
      clearFilePath: true,
      clearError: true,
    );
  }

  /// Opens a `.lfproj`, re-checking its input files on the way in (AC-10.3 ·
  /// AC-10.4 · AC-10.5).
  Future<bool> openProject(String path) async {
    try {
      final db = await ProjectService.openProject(path);
      final meta = await ProjectService.readMeta(db);

      final checks = await ProjectService.verifyInputFiles(db);
      final notice = ProjectService.describeChecks(checks);

      await _swapDatabase(db);
      state = state.copyWith(
        isOpen: true,
        filePath: path,
        name: meta?.name ?? ProjectPaths.projectNameFromInputFile(path),
        isDirty: false,
        lastSavedAt: meta?.updatedAt,
        notices: notice == null ? const [] : [notice],
        autoSaveEnabled: _autoSaveFromTogglesJson(meta?.togglesJson),
        clearError: true,
      );

      await _remember(
        hasMissingFiles: checks.any(
          (c) => c.verdict == InputFileVerdict.missing,
        ),
      );
      return true;
    } catch (error, stackTrace) {
      _log.warning('Failed to open project', error, stackTrace);
      state = state.copyWith(errorMessage: '$error');
      return false;
    }
  }

  Future<bool> openRecent(RecentProject project) => openProject(project.path);

  /// `Ctrl+S`. Returns [SaveOutcome.needsLocation] when the caller has to run
  /// the location dialog first.
  Future<SaveOutcome> save() async {
    if (!state.isOpen) return SaveOutcome.skipped;

    final path = state.filePath;
    if (path == null) return SaveOutcome.needsLocation;

    _autoSaveTimer?.cancel();
    state = state.copyWith(isSaving: true);
    try {
      await ProjectService.touch(state.db, name: state.name);
      await _remember();
      state = state.copyWith(
        isDirty: false,
        isSaving: false,
        lastSavedAt: DateTime.now(),
        clearError: true,
      );
      return SaveOutcome.saved;
    } catch (error, stackTrace) {
      _log.severe('Save failed', error, stackTrace);
      state = state.copyWith(isSaving: false, errorMessage: '저장 실패: $error');
      return SaveOutcome.failed;
    }
  }

  /// First save, or 다른 이름으로 저장. Copies the current project into
  /// [targetPath] and continues working against that file.
  Future<SaveOutcome> saveAs(String targetPath) async {
    if (!state.isOpen) return SaveOutcome.skipped;

    _autoSaveTimer?.cancel();
    state = state.copyWith(isSaving: true);
    try {
      final saved = await ProjectService.saveAs(
        source: state.db,
        targetPath: targetPath,
        projectName: state.name,
      );
      final finalPath = ProjectPaths.ensureProjectExtension(targetPath);

      await _swapDatabase(saved);
      state = state.copyWith(
        filePath: finalPath,
        isDirty: false,
        isSaving: false,
        lastSavedAt: DateTime.now(),
        clearError: true,
      );
      await _remember();
      return SaveOutcome.saved;
    } catch (error, stackTrace) {
      _log.severe('Save-as failed', error, stackTrace);
      state = state.copyWith(isSaving: false, errorMessage: '저장 실패: $error');
      return SaveOutcome.failed;
    }
  }

  /// Closes the project and returns to the start screen. Anything already on
  /// disk stays there; an unsaved project is discarded by the caller's choice.
  Future<void> closeProject() async {
    _autoSaveTimer?.cancel();
    if (state.isOpen && state.hasFile) {
      await ProjectService.touch(state.db, name: state.name);
      await _remember();
    }
    await _swapDatabase(ProjectService.inMemory());
    state = state.copyWith(
      isOpen: false,
      name: ProjectSession.defaultName,
      isDirty: false,
      notices: const [],
      clearFilePath: true,
      clearError: true,
    );
  }

  Future<void> rename(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed == state.name) return;
    state = state.copyWith(name: trimmed);
    if (state.hasFile) {
      await ProjectService.touch(state.db, name: trimmed);
      await _remember();
    }
    markDirty();
  }

  /// Names an untitled project after the first input file the user added
  /// (AC-10.9).
  void suggestNameFromInput(String inputFilePath) {
    if (state.name != ProjectSession.defaultName) return;
    state = state.copyWith(
      name: ProjectPaths.projectNameFromInputFile(inputFilePath),
    );
  }

  /// Records a change and schedules the debounced auto-save (AC-10.1).
  void markDirty() {
    if (!state.isOpen) return;
    state = state.copyWith(isDirty: true);

    _autoSaveTimer?.cancel();
    // An unsaved project has nowhere to auto-save to; it waits for the first
    // explicit save rather than popping a dialog the user did not ask for.
    if (!state.hasFile || !state.autoSaveEnabled) return;
    _autoSaveTimer = Timer(autoSaveDebounce, () => unawaited(save()));
  }

  void setAutoSaveEnabled(bool enabled) {
    if (state.autoSaveEnabled == enabled) return;
    state = state.copyWith(autoSaveEnabled: enabled);
    if (!enabled) _autoSaveTimer?.cancel();
  }

  /// Defaults to ON when the blob is missing or corrupt (TECHNICAL.md 3.4).
  static bool _autoSaveFromTogglesJson(String? raw) {
    if (raw == null || raw.trim().isEmpty) return true;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return true;
      final value = decoded['autoSave'];
      return value is bool ? value : true;
    } on FormatException {
      return true;
    }
  }

  /// Save point for the translation run: completion, pause, cancel, or error
  /// (TECHNICAL.md 6.4). Never called per batch.
  Future<void> saveTranslationCheckpoint() async {
    if (!state.isOpen || !state.hasFile) return;
    await save();
  }

  void dismissNotices() {
    if (state.notices.isEmpty) return;
    state = state.copyWith(notices: const []);
  }

  void dismissError() {
    if (state.errorMessage == null) return;
    state = state.copyWith(clearError: true);
  }

  Future<void> _swapDatabase(AppDatabase next) async {
    final previous = state.db;
    _openDatabase = next;
    state = state.copyWith(db: next);
    if (!identical(previous, next)) {
      await previous.close();
    }
  }

  Future<void> _remember({bool? hasMissingFiles}) async {
    final path = state.filePath;
    if (path == null) return;

    try {
      final registry = await ref.read(registryServiceProvider.future);
      final counts = await _keyCounts();
      await registry.remember(
        path: path,
        name: state.name,
        totalKeys: counts.$1,
        doneKeys: counts.$2,
        hasMissingFiles: hasMissingFiles ?? false,
      );
      ref.invalidate(recentProjectsProvider);
    } catch (error, stackTrace) {
      // The recent list is a convenience; failing to update it must not fail
      // the save itself.
      _log.warning(
        'Could not update the recent project list',
        error,
        stackTrace,
      );
    }
  }

  /// `(total, done)` for the recent-projects row.
  Future<(int, int)> _keyCounts() async {
    final db = state.db;
    final total = db.entries.id.count();
    final totalRow = await (db.selectOnly(
      db.entries,
    )..addColumns([total])).getSingleOrNull();

    final doneCount = db.entries.id.count();
    final doneRow =
        await (db.selectOnly(db.entries)
              ..addColumns([doneCount])
              ..where(
                db.entries.status.isIn([
                  EntryStatus.done.wireName,
                  EntryStatus.kept.wireName,
                  EntryStatus.cache.wireName,
                ]),
              ))
            .getSingleOrNull();

    return (totalRow?.read(total) ?? 0, doneRow?.read(doneCount) ?? 0);
  }
}

final projectSessionProvider =
    NotifierProvider<ProjectSessionController, ProjectSession>(
      ProjectSessionController.new,
    );

/// Overridden in tests with [RegistryService.inMemory].
final registryServiceProvider = FutureProvider<RegistryService>((ref) async {
  final service = await RegistryService.open();
  ref.onDispose(() => unawaited(service.close()));
  await service.prune();
  return service;
});

/// The start screen's list (AC-10.2).
final recentProjectsProvider = FutureProvider<List<RecentProject>>((ref) async {
  final registry = await ref.watch(registryServiceProvider.future);
  return registry.recentProjects();
});
