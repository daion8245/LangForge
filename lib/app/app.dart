import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show SemanticsService;
import 'package:flutter/services.dart' show MissingPluginException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:window_manager/window_manager.dart';

import '../application/cache/cache_providers.dart';
import '../application/db_provider.dart';
import '../application/entries/entries_page_controller.dart';
import '../application/merge/merge_hydrator.dart';
import '../application/project/project_language_pair.dart';
import '../application/project/project_session.dart';
import '../application/scan/scan_controller.dart';
import '../application/settings/engine_settings.dart';
import '../application/translation/translation_controller.dart';
import '../application/translation/translation_runner.dart' show RunnerStatus;
import '../infrastructure/db/app_database.dart';
import '../infrastructure/db/row_mappers.dart';
import '../infrastructure/export/pack_icon_loader.dart';
import '../infrastructure/export/resource_pack_exporter.dart';
import '../infrastructure/project/project_paths.dart';
import '../presentation/common/close_confirmation_dialog.dart';
import '../presentation/editor/editor_shell.dart';
import '../presentation/empty/empty_project_view.dart';
import '../presentation/export/export_modal_view.dart';
import '../presentation/glossary/glossary_screen.dart';
import '../presentation/start/start_screen_view.dart';
import 'shortcuts.dart';
import 'theme/lf_colors.dart';
import 'theme/lf_radii.dart';
import 'theme/lf_sizes.dart';
import 'theme/lf_spacing.dart';
import 'theme/lf_typography.dart';

/// Shown in the exported report header.
const String appVersion = '0.1.0';

class LangForgeApp extends ConsumerWidget {
  const LangForgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ThemeData.dark().copyWith(
      extensions: [
        LfColors.dark,
        LfSpacing.standard,
        LfRadii.standard,
        LfTypography.standard,
        LfSizes.standard,
      ],
    );

    return MaterialApp(
      title: 'LangForge',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const AppRoot(),
    );
  }
}

/// Chooses between the start screen (S0) and the editor, and owns the
/// window-close interception of EXPERIENCE.md S9.
class AppRoot extends ConsumerStatefulWidget {
  const AppRoot({super.key});

  @override
  ConsumerState<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<AppRoot> with WindowListener {
  bool _listeningToWindow = false;

  @override
  void initState() {
    super.initState();
    unawaited(_interceptWindowClose());
  }

  /// Closing has to be intercepted so a run in flight can be saved first (S9).
  ///
  /// Widget tests run without the desktop window plugin, so a failure here is
  /// downgraded to "no interception" rather than taking the app down.
  Future<void> _interceptWindowClose() async {
    try {
      await windowManager.setPreventClose(true);
      if (!mounted) return;
      windowManager.addListener(this);
      _listeningToWindow = true;
    } on MissingPluginException {
      // No window manager (tests, or a non-desktop host).
    }
  }

  @override
  void dispose() {
    if (_listeningToWindow) windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() {
    unawaited(_handleWindowClose());
  }

  Future<void> _handleWindowClose() async {
    final session = ref.read(projectSessionProvider);
    final translation = ref.read(translationControllerProvider);

    if (!session.isOpen && !translation.isActive) {
      await windowManager.destroy();
      return;
    }

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) =>
          CloseConfirmationDialog(isTranslating: translation.isActive),
    );
    if (confirmed != true) return;

    // Whatever finished is kept: the runner's cancel path leaves completed
    // entries alone and the session save point writes them out (AC-5.12).
    ref.read(translationControllerProvider.notifier).cancel();
    await ref.read(projectSessionProvider.notifier).closeProject();
    await windowManager.destroy();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(projectSessionProvider);
    return session.isOpen ? const ProjectWorkspace() : const StartScreen();
  }
}

/// S0 — start screen.
class StartScreen extends ConsumerWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recents = ref.watch(recentProjectsProvider);
    final session = ref.watch(projectSessionProvider);
    final notifier = ref.read(projectSessionProvider.notifier);

    return Stack(
      children: [
        StartScreenView(
          recentProjects: recents.asData?.value ?? const [],
          onNewProject: () => unawaited(notifier.newProject()),
          onOpenProjectFile: () => unawaited(_pickAndOpen(context, ref)),
          onSelectRecentProject: (project) =>
              unawaited(_openAndReport(context, ref, project.path)),
        ),
        if (session.errorMessage != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: LfSpacing.standard.space10,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: _ErrorBanner(
                  message: session.errorMessage!,
                  onDismiss: notifier.dismissError,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickAndOpen(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['lfproj'],
    );
    final path = result?.paths.whereType<String>().firstOrNull;
    if (path == null) return;
    if (!context.mounted) return;
    await _openAndReport(context, ref, path);
  }

  Future<void> _openAndReport(
    BuildContext context,
    WidgetRef ref,
    String path,
  ) async {
    await ref.read(projectSessionProvider.notifier).openProject(path);
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LfColors>()!;
    final spacing = Theme.of(context).extension<LfSpacing>()!;
    final radii = Theme.of(context).extension<LfRadii>()!;
    final typography = Theme.of(context).extension<LfTypography>()!;
    final sizes = Theme.of(context).extension<LfSizes>()!;

    return Container(
      constraints: BoxConstraints(maxWidth: sizes.modalLg),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.space7,
        vertical: spacing.space5,
      ),
      decoration: BoxDecoration(
        color: colors.dangerSurface,
        borderRadius: radii.r2xl,
        border: Border.all(color: colors.dangerBorder, width: sizes.borderThin),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: typography.bodySm.copyWith(color: colors.dangerText),
            ),
          ),
          SizedBox(width: spacing.space5),
          TextButton(onPressed: onDismiss, child: const Text('닫기')),
        ],
      ),
    );
  }
}

/// The editor with a project loaded: S1 while empty, S2 once files are in.
class ProjectWorkspace extends ConsumerStatefulWidget {
  const ProjectWorkspace({super.key});

  @override
  ConsumerState<ProjectWorkspace> createState() => _ProjectWorkspaceState();
}

class _ProjectWorkspaceState extends ConsumerState<ProjectWorkspace> {
  final FocusNode _searchFocusNode = FocusNode();

  /// Last message announced, so the same one is not repeated.
  String? _announced;

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// Speaks translation progress to a screen reader (TECHNICAL.md 15).
  ///
  /// Only state changes are announced, not every throttled progress tick —
  /// a message every 100ms would make the app unusable with a reader on.
  void _announceRunState(
    TranslationUiState? previous,
    TranslationUiState next,
  ) {
    if (previous?.status == next.status) return;

    final message = switch (next.status) {
      RunnerStatus.running => '번역을 시작했습니다. 대상 ${next.totalCount}건.',
      RunnerStatus.paused => '번역을 일시정지했습니다.',
      RunnerStatus.error => next.message ?? '번역이 중단되었습니다.',
      RunnerStatus.idle =>
        previous == null || previous.status == RunnerStatus.idle
            ? null
            : '번역이 끝났습니다. 완료 ${next.completedCount}건 · 실패 ${next.failedCount}건.',
    };

    if (message == null || message == _announced) return;
    _announced = message;
    SemanticsService.sendAnnouncement(
      View.of(context),
      message,
      Directionality.of(context),
    );
  }

  ScanController get _scan => ref.read(scanControllerProvider.notifier);

  ProjectSessionController get _session =>
      ref.read(projectSessionProvider.notifier);

  bool get _isTranslating => ref.read(translationControllerProvider).isActive;

  Future<void> _addFiles() async {
    if (_isTranslating) return;
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const ['jar', 'zip'],
    );
    final paths = result?.paths.whereType<String>().toList() ?? const [];
    if (paths.isEmpty) return;
    await _scan.addFiles(paths);
  }

  Future<void> _addFolder() async {
    if (_isTranslating) return;
    final dir = await FilePicker.getDirectoryPath();
    if (dir == null) return;
    await _scan.addDirectory(dir);
  }

  Future<void> _rescan() async {
    if (_isTranslating) return;
    await _scan.rescanAll();
  }

  /// `Ctrl+S`. Runs the location dialog the first time (AC-10.8).
  Future<void> _save() async {
    final outcome = await _session.save();
    if (outcome != SaveOutcome.needsLocation) {
      if (mounted && outcome == SaveOutcome.saved) {
        _showMessage('프로젝트를 저장했습니다.');
      }
      return;
    }
    await _saveAs();
  }

  Future<void> _saveAs() async {
    final session = ref.read(projectSessionProvider);
    final defaultDir = await ProjectPaths.defaultProjectsDirectoryPath();

    final chosen = await FilePicker.saveFile(
      dialogTitle: '프로젝트 저장 위치 선택',
      fileName: '${session.name}${ProjectPaths.projectExtension}',
      initialDirectory: defaultDir,
      type: FileType.custom,
      allowedExtensions: const ['lfproj'],
    );
    if (chosen == null) return;

    // The default folder is only created once the user has committed to a
    // location (AC-10.8).
    Directory(p.dirname(chosen)).createSync(recursive: true);

    final outcome = await _session.saveAs(chosen);
    if (!mounted) return;
    _showMessage(
      outcome == SaveOutcome.saved ? '프로젝트를 저장했습니다.' : '프로젝트를 저장하지 못했습니다.',
    );
  }

  Future<void> _closeProject() async {
    final translating = _isTranslating;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) =>
          CloseConfirmationDialog(isTranslating: translating),
    );
    if (confirmed != true) return;

    ref.read(translationControllerProvider.notifier).cancel();
    await _session.closeProject();
  }

  Future<void> _newProject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) =>
          CloseConfirmationDialog(isTranslating: _isTranslating),
    );
    if (confirmed != true) return;
    ref.read(translationControllerProvider.notifier).cancel();
    await _session.newProject();
  }

  Future<void> _openProject() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['lfproj'],
    );
    final path = result?.paths.whereType<String>().firstOrNull;
    if (path == null) return;
    await _session.openProject(path);
  }

  Future<void> _renameProject() async {
    final session = ref.read(projectSessionProvider);
    final controller = TextEditingController(text: session.name);

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('프로젝트 이름 변경'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: '프로젝트 이름'),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('변경'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null) return;
    await _session.rename(name);
  }

  Future<void> _openGlossary() async {
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const GlossaryScreen()),
    );
  }

  /// `Ctrl+R`.
  void _startTranslation() {
    if (_isTranslating) return;
    final settings = ref.read(engineSettingsProvider);
    if (settings.missingFieldLabels.isNotEmpty) {
      ref.read(engineSettingsProvider.notifier).reportMissingFields();
      _showMessage('${settings.missingFieldLabels.join(' · ')} 항목이 비어 있습니다.');
      return;
    }

    unawaited(
      ref
          .read(translationControllerProvider.notifier)
          .start(
            provider: settings.provider,
            auth: settings.authValues,
            model: settings.model,
          ),
    );
  }

  void _focusSearch() => _searchFocusNode.requestFocus();

  void _clearSearch() {
    _scan.setSearchQuery(null);
    ref.read(entriesViewControllerProvider.notifier).setSearchText(null);
    _searchFocusNode.unfocus();
  }

  void _nextNamespace() {
    final namespaces = ref.read(_visibleNamespacesProvider);
    if (namespaces.isEmpty) return;

    final current = ref.read(scanControllerProvider).activeNamespaceId;
    final index = namespaces.indexWhere((ns) => ns.id == current);
    final next = namespaces[(index + 1) % namespaces.length];
    _selectNamespace(next.id);
  }

  void _selectNamespace(String id) {
    _scan.setActiveNamespace(id);
    ref.read(entriesViewControllerProvider.notifier).selectNamespace(id);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final scanState = ref.watch(scanControllerProvider);
    final translationState = ref.watch(translationControllerProvider);
    final session = ref.watch(projectSessionProvider);

    ref.listen<TranslationUiState>(
      translationControllerProvider,
      _announceRunState,
    );

    return LangForgeShortcuts(
      onAddFiles: _addFiles,
      onAddFolder: _addFolder,
      onRescan: _rescan,
      onStartTranslation: _startTranslation,
      onSave: _save,
      onExport: () => unawaited(_openExportModal()),
      onFocusSearch: _focusSearch,
      onEscape: _clearSearch,
      onNextNamespace: _nextNamespace,
      child: StreamBuilder<List<InputFile>>(
        stream: db.select(db.inputFiles).watch(),
        builder: (context, filesSnapshot) {
          final inputFiles = filesSnapshot.data ?? const <InputFile>[];

          if (inputFiles.isEmpty && !scanState.isScanning) {
            return EmptyProjectView(
              onFilesSelected: (paths) => unawaited(_scan.addFiles(paths)),
              onFolderSelected: (path) => unawaited(_scan.addDirectory(path)),
            );
          }

          return StreamBuilder<List<Namespace>>(
            stream: db.select(db.namespaces).watch(),
            builder: (context, nsSnapshot) {
              final namespaces = nsSnapshot.data ?? const <Namespace>[];

              return StreamBuilder<List<LanguageFile>>(
                stream: db.select(db.languageFiles).watch(),
                builder: (context, lfSnapshot) {
                  final languageFiles =
                      lfSnapshot.data ?? const <LanguageFile>[];

                  // Only the visible page is held in memory. A project can
                  // carry tens of thousands of entries (AGENTS.md 5.6).
                  final entriesPage =
                      ref.watch(entriesPageProvider).asData?.value ??
                      const <Entry>[];
                  final totalCount =
                      ref.watch(entriesTotalCountProvider).asData?.value ?? 0;
                  final statusCounts =
                      ref.watch(entryStatusCountsProvider).asData?.value ??
                      const <String, int>{};
                  final viewState = ref.watch(entriesViewControllerProvider);
                  final entriesNotifier = ref.read(
                    entriesViewControllerProvider.notifier,
                  );

                  final banners = <String>[
                    ...session.notices,
                    ...scanState.rejectedSummary,
                  ];

                  return EditorShell(
                    projectName: session.name,
                    isDirty: session.isDirty,
                    inputFiles: inputFiles,
                    namespaces: namespaces,
                    languageFiles: languageFiles,
                    entries: entriesPage,
                    totalEntryCount: totalCount,
                    statusCounts: statusCounts,
                    statusFilter: viewState.statusFilter,
                    hasMoreEntries: entriesPage.length < totalCount,
                    onLoadMoreEntries: entriesNotifier.loadMore,
                    onStatusFilterChanged: entriesNotifier.setStatusFilter,
                    selectedNamespaceId: scanState.activeNamespaceId,
                    onSelectNamespace: _selectNamespace,
                    onToggleNamespaceExclusion: (nsId, excluded) =>
                        unawaited(_scan.setNamespaceExcluded(nsId, excluded)),
                    onToggleInputFile: (fileId, enabled) =>
                        unawaited(_scan.setInputFileEnabled(fileId, enabled)),
                    onSelectSourceFile: (langFile) => unawaited(
                      _scan.setNamespaceSource(
                        langFile.namespaceId,
                        langFile.id,
                      ),
                    ),
                    onSearchChanged: (query) {
                      _scan.setSearchQuery(query);
                      entriesNotifier.setSearchText(query);
                    },
                    searchFocusNode: _searchFocusNode,
                    onStartTranslation: _startTranslation,
                    onPauseTranslation: ref
                        .read(translationControllerProvider.notifier)
                        .pause,
                    onResumeTranslation: ref
                        .read(translationControllerProvider.notifier)
                        .resume,
                    onCancelTranslation: ref
                        .read(translationControllerProvider.notifier)
                        .cancel,
                    isTranslating: translationState.isActive,
                    isPaused: translationState.isPaused,
                    translationMessage: translationState.message,
                    translationProgress: translationState.percent,
                    cacheHitRateLabel: translationState.cacheHitRateLabel,
                    onOpenGlossary: () => unawaited(_openGlossary()),
                    onAddFiles: () => unawaited(_addFiles()),
                    onAddFolder: () => unawaited(_addFolder()),
                    onRescan: () => unawaited(_rescan()),
                    onExport: () => unawaited(_openExportModal()),
                    onNewProject: () => unawaited(_newProject()),
                    onOpenProject: () => unawaited(_openProject()),
                    onSaveProject: () => unawaited(_save()),
                    onSaveProjectAs: () => unawaited(_saveAs()),
                    onCloseProject: () => unawaited(_closeProject()),
                    onRenameProject: () => unawaited(_renameProject()),
                    onCancelScan: _scan.cancelScan,
                    onUpdateUserTranslation: (id, text) =>
                        unawaited(_scan.updateUserTranslation(id, text)),
                    onResetEntryToWait: (id) =>
                        unawaited(_scan.resetEntryToWait(id)),
                    onKeepSourceText: (id) =>
                        unawaited(_scan.keepSourceText(id)),
                    onApproveConfirm: (id) =>
                        unawaited(_scan.approveConfirm(id)),
                    isScanning: scanState.isScanning,
                    scanMessage: scanState.currentStatusMessage,
                    rejectedSummary: banners,
                    onDismissBanner: () {
                      _session.dismissNotices();
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openExportModal() async {
    if (_isTranslating) {
      _showMessage('번역이 진행 중입니다. 완료 또는 취소 후 내보낼 수 있습니다.');
      return;
    }

    final db = ref.read(appDatabaseProvider);
    final scanState = ref.read(scanControllerProvider);
    final translationState = ref.read(translationControllerProvider);

    final mcVersionsJsonStr = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/data/mc_versions.json');
    final packIcon = await PackIconLoader.load();

    // Export is the one operation that legitimately needs every row.
    final inputFiles = await db.select(db.inputFiles).get();
    final namespaces = await db.select(db.namespaces).get();
    final entryRows = await db.select(db.entries).get();
    final engine = ref.read(engineSettingsProvider);
    final langs = await ProjectLanguagePair.fromDb(db);
    final hydrator = MergeHydrator(
      db: db,
      cacheStore: ref.read(translationCacheStoreProvider),
      glossaryStore: ref.read(glossaryStoreProvider),
      sourceLang: langs.sourceLang,
      targetLang: langs.targetLang,
      providerId: engine.providerId,
      modelId: engine.model,
    );
    final allEntries = await hydrator.hydrateAll(entryRows);
    final unresolvedConflicts = await (db.select(
      db.conflicts,
    )..where((t) => t.resolved.equals(false))).get();

    final domainNamespaces = namespaces.toDomain();
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (modalContext) => ExportModalView(
        namespaces: domainNamespaces,
        entries: allEntries,
        isTranslating: translationState.isActive,
        hasUnresolvedConflict: unresolvedConflicts.isNotEmpty,
        mcVersionsJsonStr: mcVersionsJsonStr,
        onExportConfirmed:
            (formatOption, mcVersion, packFormat, options) async {
              final outputDir = await FilePicker.getDirectoryPath();
              if (outputDir == null) return;

              final format = switch (formatOption) {
                ExportFormatOption.zipPack => ExportFormat.zipPack,
                ExportFormatOption.folderPack => ExportFormat.folderPack,
                ExportFormatOption.pathJson => ExportFormat.pathJson,
                ExportFormatOption.namespaceJson => ExportFormat.namespaceJson,
              };

              try {
                final outputPath = await ResourcePackExporter.export(
                  targetDirPath: outputDir,
                  format: format,
                  inputFiles: inputFiles.toDomain(),
                  namespaces: domainNamespaces,
                  entries: allEntries,
                  packFormat: packFormat,
                  providerName: engine.provider.displayName,
                  modelName: engine.model,
                  sourceLangCode: langs.sourceLang,
                  targetLangCode: langs.targetLang,
                  outputFileName: langs.outputFileName,
                  appVersion: appVersion,
                  staleKeysByNamespace: scanState.staleKeysByNamespace,
                  packIconBytes: packIcon,
                );
                _showMessage('내보내기 완료: $outputPath');
              } catch (error) {
                _showMessage('내보내기 실패: $error');
              }
            },
      ),
    );
  }
}

/// Namespaces in tree order, used by `Ctrl+Tab`.
final _namespaceListProvider = StreamProvider<List<Namespace>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.namespaces).watch();
});

final _visibleNamespacesProvider = Provider<List<Namespace>>((ref) {
  return ref.watch(_namespaceListProvider).asData?.value ?? const <Namespace>[];
});
