import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../app_version.dart';
import '../../domain/policy/conflict_priority.dart';
import '../../infrastructure/db/app_database.dart';
import '../db_provider.dart';
import 'project_session.dart';

/// The 일반 탭 toggles (ROADMAP 10.3), stored in `project_meta.toggles_json`.
///
/// Unknown keys are carried through untouched: an older build must not wipe
/// settings a newer one wrote (TECHNICAL.md 3.4).
class ProjectToggles {
  const ProjectToggles({
    this.autoSave = true,
    this.verboseLog = false,
    this.notifyOnComplete = true,
    this.keepOnRescan = true,
    this.allowSkipChecks = false,
    this.unknown = const {},
  });

  static const ProjectToggles defaults = ProjectToggles();

  /// 자동 저장.
  final bool autoSave;

  /// 상세 로그 (FINE). Raises the logging level for the in-app log viewer.
  final bool verboseLog;

  /// 번역 완료 시 소리·알림.
  final bool notifyOnComplete;

  /// 재탐색 시 기존 번역 유지 (AC-10.7). Off means a rescan throws work away.
  final bool keepOnRescan;

  /// 출력 전 검사 건너뛰기 허용 (E3). Off means the gate cannot be bypassed.
  final bool allowSkipChecks;

  /// Keys written by a different app version.
  final Map<String, dynamic> unknown;

  static const _known = {
    'autoSave',
    'verboseLog',
    'notifyOnComplete',
    'keepOnRescan',
    'allowSkipChecks',
  };

  static ProjectToggles fromJsonString(String? raw) {
    if (raw == null || raw.trim().isEmpty) return defaults;
    Map<String, dynamic> map;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return defaults;
      map = decoded;
    } on FormatException {
      // A corrupt settings blob must not stop the project from opening.
      return defaults;
    }

    bool read(String key, bool fallback) {
      final value = map[key];
      return value is bool ? value : fallback;
    }

    return ProjectToggles(
      autoSave: read('autoSave', defaults.autoSave),
      verboseLog: read('verboseLog', defaults.verboseLog),
      notifyOnComplete: read('notifyOnComplete', defaults.notifyOnComplete),
      keepOnRescan: read('keepOnRescan', defaults.keepOnRescan),
      allowSkipChecks: read('allowSkipChecks', defaults.allowSkipChecks),
      unknown: {
        for (final entry in map.entries)
          if (!_known.contains(entry.key)) entry.key: entry.value,
      },
    );
  }

  String toJsonString() => jsonEncode({
    ...unknown,
    'autoSave': autoSave,
    'verboseLog': verboseLog,
    'notifyOnComplete': notifyOnComplete,
    'keepOnRescan': keepOnRescan,
    'allowSkipChecks': allowSkipChecks,
  });

  ProjectToggles copyWith({
    bool? autoSave,
    bool? verboseLog,
    bool? notifyOnComplete,
    bool? keepOnRescan,
    bool? allowSkipChecks,
  }) {
    return ProjectToggles(
      autoSave: autoSave ?? this.autoSave,
      verboseLog: verboseLog ?? this.verboseLog,
      notifyOnComplete: notifyOnComplete ?? this.notifyOnComplete,
      keepOnRescan: keepOnRescan ?? this.keepOnRescan,
      allowSkipChecks: allowSkipChecks ?? this.allowSkipChecks,
      unknown: unknown,
    );
  }
}

/// One toggle, so the settings panel can build its rows from data.
enum ToggleId {
  autoSave('자동 저장', '변경 사항을 2초 뒤에 자동으로 저장합니다.'),
  verboseLog('상세 로그 (FINE)', '로그 뷰어에 상세 진단 로그를 남깁니다.'),
  notifyOnComplete('번역 완료 시 소리·알림', '긴 번역이 끝나면 알립니다.'),
  keepOnRescan('재탐색 시 기존 번역 유지', '끄면 다시 검사할 때 기존 번역을 버립니다.'),
  allowSkipChecks('출력 전 검사 건너뛰기 허용', '켜면 출력 화면에서 검사 실패를 무시할 수 있습니다.');

  const ToggleId(this.label, this.description);

  final String label;
  final String description;

  bool read(ProjectToggles toggles) => switch (this) {
    ToggleId.autoSave => toggles.autoSave,
    ToggleId.verboseLog => toggles.verboseLog,
    ToggleId.notifyOnComplete => toggles.notifyOnComplete,
    ToggleId.keepOnRescan => toggles.keepOnRescan,
    ToggleId.allowSkipChecks => toggles.allowSkipChecks,
  };

  ProjectToggles write(ProjectToggles toggles, bool value) => switch (this) {
    ToggleId.autoSave => toggles.copyWith(autoSave: value),
    ToggleId.verboseLog => toggles.copyWith(verboseLog: value),
    ToggleId.notifyOnComplete => toggles.copyWith(notifyOnComplete: value),
    ToggleId.keepOnRescan => toggles.copyWith(keepOnRescan: value),
    ToggleId.allowSkipChecks => toggles.copyWith(allowSkipChecks: value),
  };
}

/// Everything the 환경설정 화면 edits, as one value.
class ProjectSettingsData {
  const ProjectSettingsData({
    this.conflictPriority = ConflictPriority.manual,
    this.toggles = ProjectToggles.defaults,
    this.targetLangCode = 'ko_kr',
    this.packIconMode = 'default',
    this.packIconPath,
  });

  final ConflictPriority conflictPriority;
  final ProjectToggles toggles;
  final String targetLangCode;
  final String packIconMode;
  final String? packIconPath;

  ProjectSettingsData copyWith({
    ConflictPriority? conflictPriority,
    ProjectToggles? toggles,
    String? targetLangCode,
    String? packIconMode,
    String? packIconPath,
    bool clearPackIconPath = false,
  }) {
    return ProjectSettingsData(
      conflictPriority: conflictPriority ?? this.conflictPriority,
      toggles: toggles ?? this.toggles,
      targetLangCode: targetLangCode ?? this.targetLangCode,
      packIconMode: packIconMode ?? this.packIconMode,
      packIconPath: clearPackIconPath
          ? null
          : (packIconPath ?? this.packIconPath),
    );
  }
}

/// Reads and writes the settings columns of the single `project_meta` row.
abstract final class ProjectSettings {
  static Future<ProjectSettingsData> read(AppDatabase db) async {
    final meta = await db.select(db.projectMeta).getSingleOrNull();
    if (meta == null) return const ProjectSettingsData();
    return ProjectSettingsData(
      conflictPriority: ConflictPriority.fromWire(meta.conflictPriority),
      toggles: ProjectToggles.fromJsonString(meta.togglesJson),
      targetLangCode: meta.targetLangCode,
      packIconMode: meta.packIconMode,
      packIconPath: meta.packIconPath,
    );
  }

  static Future<ConflictPriority> readConflictPriority(AppDatabase db) async {
    final meta = await db.select(db.projectMeta).getSingleOrNull();
    return ConflictPriority.fromWire(meta?.conflictPriority);
  }

  static Future<ProjectToggles> readToggles(AppDatabase db) async {
    final meta = await db.select(db.projectMeta).getSingleOrNull();
    return ProjectToggles.fromJsonString(meta?.togglesJson);
  }

  static Future<void> writeConflictPriority(
    AppDatabase db,
    ConflictPriority priority,
  ) => _write(db, conflictPriority: priority.wireName);

  static Future<void> writeToggles(AppDatabase db, ProjectToggles toggles) =>
      _write(db, togglesJson: toggles.toJsonString());

  static Future<void> writeTargetLang(AppDatabase db, String code) =>
      _write(db, targetLangCode: code);

  static Future<void> writePackIcon(
    AppDatabase db, {
    required String mode,
    String? path,
    bool clearPath = false,
  }) => _write(
    db,
    packIconMode: mode,
    packIconPath: path,
    clearPackIconPath: clearPath,
  );

  /// A project that has never been saved has no meta row yet, so an update
  /// alone would silently do nothing. Settings must persist either way.
  static Future<void> _write(
    AppDatabase db, {
    String? conflictPriority,
    String? togglesJson,
    String? targetLangCode,
    String? packIconMode,
    String? packIconPath,
    bool clearPackIconPath = false,
  }) async {
    final priorityValue = conflictPriority == null
        ? const Value<String>.absent()
        : Value(conflictPriority);
    final togglesValue = togglesJson == null
        ? const Value<String>.absent()
        : Value(togglesJson);
    final targetValue = targetLangCode == null
        ? const Value<String>.absent()
        : Value(targetLangCode);
    final iconModeValue = packIconMode == null
        ? const Value<String>.absent()
        : Value(packIconMode);
    final iconPathValue = clearPackIconPath
        ? const Value<String?>.absent()
        : packIconPath == null
        ? const Value<String?>.absent()
        : Value<String?>(packIconPath);
    final now = DateTime.now();

    final updated =
        await (db.update(db.projectMeta)..where((t) => t.id.equals(1))).write(
          ProjectMetaCompanion(
            conflictPriority: priorityValue,
            togglesJson: togglesValue,
            targetLangCode: targetValue,
            packIconMode: iconModeValue,
            packIconPath: clearPackIconPath ? const Value(null) : iconPathValue,
            updatedAt: Value(now),
          ),
        );
    if (updated > 0) return;

    await db
        .into(db.projectMeta)
        .insertOnConflictUpdate(
          ProjectMetaCompanion.insert(
            id: const Value(1),
            name: ProjectSession.defaultName,
            schemaVersion: '1',
            appVersion: appVersion,
            createdAt: now,
            updatedAt: now,
            conflictPriority: priorityValue,
            togglesJson: togglesValue,
            targetLangCode: targetValue,
            packIconMode: iconModeValue,
            packIconPath: clearPackIconPath ? const Value(null) : iconPathValue,
          ),
        );
  }
}

class ProjectSettingsController extends AsyncNotifier<ProjectSettingsData> {
  static final Logger _log = Logger('ProjectSettings');

  @override
  Future<ProjectSettingsData> build() async {
    final db = ref.watch(appDatabaseProvider);
    final data = await ProjectSettings.read(db);
    Logger.root.level = data.toggles.verboseLog ? Level.FINE : Level.INFO;
    ref
        .read(projectSessionProvider.notifier)
        .setAutoSaveEnabled(data.toggles.autoSave);
    return data;
  }

  Future<void> setConflictPriority(ConflictPriority priority) async {
    final current = state.value ?? const ProjectSettingsData();
    if (current.conflictPriority == priority) return;

    state = AsyncData(current.copyWith(conflictPriority: priority));
    await _persist(
      () => ProjectSettings.writeConflictPriority(
        ref.read(appDatabaseProvider),
        priority,
      ),
    );
  }

  Future<void> setToggle(ToggleId toggle, bool value) async {
    final current = state.value ?? const ProjectSettingsData();
    if (toggle.read(current.toggles) == value) return;

    final next = toggle.write(current.toggles, value);
    state = AsyncData(current.copyWith(toggles: next));
    await _persist(
      () => ProjectSettings.writeToggles(ref.read(appDatabaseProvider), next),
    );

    if (toggle == ToggleId.verboseLog) {
      Logger.root.level = value ? Level.FINE : Level.INFO;
    }
    if (toggle == ToggleId.autoSave) {
      ref.read(projectSessionProvider.notifier).setAutoSaveEnabled(value);
    }
  }

  Future<void> setTargetLang(String code) async {
    final current = state.value ?? const ProjectSettingsData();
    if (current.targetLangCode == code) return;
    state = AsyncData(current.copyWith(targetLangCode: code));
    await _persist(
      () =>
          ProjectSettings.writeTargetLang(ref.read(appDatabaseProvider), code),
    );
  }

  Future<void> setPackIcon({
    required String mode,
    String? path,
    bool clearPath = false,
  }) async {
    final current = state.value ?? const ProjectSettingsData();
    state = AsyncData(
      current.copyWith(
        packIconMode: mode,
        packIconPath: path,
        clearPackIconPath: clearPath,
      ),
    );
    await _persist(
      () => ProjectSettings.writePackIcon(
        ref.read(appDatabaseProvider),
        mode: mode,
        path: path,
        clearPath: clearPath,
      ),
    );
  }

  /// The panel already shows the new value, so a write failure has to be
  /// reported rather than swallowed — otherwise a setting looks saved and is
  /// gone on the next open.
  Future<void> _persist(Future<void> Function() write) async {
    try {
      await write();
      ref.read(projectSessionProvider.notifier).markDirty();
    } catch (error, stackTrace) {
      _log.severe('Could not save the setting', error, stackTrace);
      ref.invalidateSelf();
    }
  }
}

final projectSettingsProvider =
    AsyncNotifierProvider<ProjectSettingsController, ProjectSettingsData>(
      ProjectSettingsController.new,
    );
