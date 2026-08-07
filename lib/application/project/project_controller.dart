import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../infrastructure/db/registry_database.dart';

class ProjectState {
  final String? currentProjectPath;
  final String projectName;
  final bool isDirty;
  final bool isAutoSaving;
  final List<RecentProject> recentProjects;

  const ProjectState({
    this.currentProjectPath,
    this.projectName = 'Untitled Project',
    this.isDirty = false,
    this.isAutoSaving = false,
    this.recentProjects = const [],
  });

  ProjectState copyWith({
    String? currentProjectPath,
    String? projectName,
    bool? isDirty,
    bool? isAutoSaving,
    List<RecentProject>? recentProjects,
  }) {
    return ProjectState(
      currentProjectPath: currentProjectPath ?? this.currentProjectPath,
      projectName: projectName ?? this.projectName,
      isDirty: isDirty ?? this.isDirty,
      isAutoSaving: isAutoSaving ?? this.isAutoSaving,
      recentProjects: recentProjects ?? this.recentProjects,
    );
  }
}

class ProjectController extends Notifier<ProjectState> {
  Timer? _autoSaveDebounceTimer;

  @override
  ProjectState build() {
    ref.onDispose(() {
      _autoSaveDebounceTimer?.cancel();
    });
    return const ProjectState();
  }

  RegistryDatabase? get _registryDb => null;

  Future<void> loadRecentProjects() async {
    final db = _registryDb;
    if (db == null) return;
    try {
      final recents = await db.getRecentProjects();
      state = state.copyWith(recentProjects: recents);
    } catch (_) {}
  }

  void markDirty() {
    state = state.copyWith(isDirty: true);
    _autoSaveDebounceTimer?.cancel();
    _autoSaveDebounceTimer = Timer(const Duration(seconds: 2), () {
      saveCurrentProject();
    });
  }

  Future<void> saveCurrentProject() async {
    if (state.currentProjectPath == null) return;

    state = state.copyWith(isAutoSaving: true);
    final db = _registryDb;
    if (db == null) {
      state = state.copyWith(isAutoSaving: false, isDirty: false);
      return;
    }

    try {
      final now = DateTime.now();
      await db.addOrUpdateRecentProject(
        RecentProjectsCompanion.insert(
          id: state.currentProjectPath!,
          name: state.projectName,
          path: state.currentProjectPath!,
          lastOpenedAt: now,
        ),
      );
      await loadRecentProjects();
      state = state.copyWith(isDirty: false, isAutoSaving: false);
    } catch (_) {
      state = state.copyWith(isAutoSaving: false);
    }
  }

  Future<void> setProjectInfo(String path, String name) async {
    state = state.copyWith(currentProjectPath: path, projectName: name);
    await saveCurrentProject();
  }
}
