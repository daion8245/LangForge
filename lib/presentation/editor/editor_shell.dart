import 'package:flutter/material.dart';
import '../../app/theme/theme_extensions.dart';
import '../../infrastructure/db/app_database.dart';
import '../shell/bottom_banner.dart';
import '../shell/status_bar.dart';
import '../shell/top_bar.dart';
import 'entries/entries_list_view.dart';
import 'explorer/project_explorer.dart';
import 'json_error_view.dart';
import 'preview/output_preview_view.dart';
import 'settings/settings_panel.dart';
import 'source_lang_picker_view.dart';

class EditorShell extends StatefulWidget {
  const EditorShell({
    super.key,
    required this.inputFiles,
    required this.namespaces,
    required this.languageFiles,
    required this.entries,
    this.totalEntryCount = 0,
    this.statusCounts = const {},
    this.statusFilter,
    this.hasMoreEntries = false,
    this.onLoadMoreEntries,
    this.onStatusFilterChanged,
    this.selectedNamespaceId,
    this.onSelectNamespace,
    this.onToggleNamespaceExclusion,
    this.onSelectSourceFile,
    this.onToggleInputFile,
    this.onAddFiles,
    this.onAddFolder,
    this.onRescan,
    this.onExport,
    this.onSearchChanged,
    this.searchFocusNode,
    this.onStartTranslation,
    this.onPauseTranslation,
    this.onResumeTranslation,
    this.onCancelScan,
    this.onCancelTranslation,
    this.onUpdateUserTranslation,
    this.onResetEntryToWait,
    this.onKeepSourceText,
    this.projectName = 'Untitled Project',
    this.isDirty = false,
    this.onNewProject,
    this.onOpenProject,
    this.onSaveProject,
    this.onSaveProjectAs,
    this.onCloseProject,
    this.onRenameProject,
    this.onDismissBanner,
    this.isScanning = false,
    this.isTranslating = false,
    this.isPaused = false,
    this.translationMessage,
    this.translationProgress,
    this.scanMessage,
    this.rejectedSummary = const [],
  });

  final List<InputFile> inputFiles;
  final List<Namespace> namespaces;
  final List<LanguageFile> languageFiles;

  /// The currently loaded page, already filtered by namespace and status.
  final List<Entry> entries;

  /// Row count for the active filter, counted in SQL.
  final int totalEntryCount;

  /// `status -> count` for the selected namespace, counted in SQL.
  final Map<String, int> statusCounts;

  final String? statusFilter;
  final bool hasMoreEntries;
  final VoidCallback? onLoadMoreEntries;
  final ValueChanged<String?>? onStatusFilterChanged;

  final String? selectedNamespaceId;
  final ValueChanged<String>? onSelectNamespace;
  final void Function(String nsId, bool excluded)? onToggleNamespaceExclusion;
  final ValueChanged<LanguageFile>? onSelectSourceFile;

  /// Turning a JAR off takes all of its namespaces with it (AC-8.2).
  final void Function(String inputFileId, bool enabled)? onToggleInputFile;

  final VoidCallback? onAddFiles;
  final VoidCallback? onAddFolder;
  final VoidCallback? onRescan;
  final VoidCallback? onExport;
  final ValueChanged<String>? onSearchChanged;

  /// Owned by the workspace so `Ctrl+F` can move focus here.
  final FocusNode? searchFocusNode;

  final VoidCallback? onStartTranslation;
  final VoidCallback? onPauseTranslation;
  final VoidCallback? onResumeTranslation;
  final VoidCallback? onCancelScan;
  final VoidCallback? onCancelTranslation;
  final void Function(String entryId, String newText)? onUpdateUserTranslation;
  final void Function(String entryId)? onResetEntryToWait;
  final void Function(String entryId)? onKeepSourceText;

  /// Shown in the top bar and used as the default save file name (AC-10.9).
  final String projectName;

  final bool isDirty;
  final VoidCallback? onNewProject;
  final VoidCallback? onOpenProject;
  final VoidCallback? onSaveProject;
  final VoidCallback? onSaveProjectAs;
  final VoidCallback? onCloseProject;
  final VoidCallback? onRenameProject;
  final VoidCallback? onDismissBanner;

  final bool isScanning;

  /// True while a run holds the queue, paused runs included. Drives the locks
  /// of EXPERIENCE.md 6.4.
  final bool isTranslating;

  final bool isPaused;
  final String? translationMessage;

  /// 0..1, or null while the total is unknown.
  final double? translationProgress;
  final String? scanMessage;
  final List<String> rejectedSummary;

  @override
  State<EditorShell> createState() => _EditorShellState();
}

class _EditorShellState extends State<EditorShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _activeViewMode = 'entries'; // 'entries' | 'preview'

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final spacing = context.s;
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;

    final sizes = context.d;
    final isWide = width >= sizes.breakpointWide;
    final isNarrow = width < sizes.breakpointNarrow;

    final selectedNs = widget.namespaces
        .where((ns) => ns.id == widget.selectedNamespaceId)
        .firstOrNull;
    final breadcrumbPath = selectedNs != null
        ? 'assets/${selectedNs.name}/lang/en_us.json'
        : null;

    final waitCount = widget.statusCounts['wait'] ?? 0;

    Widget centerWidget;

    if (selectedNs != null && selectedNs.state == 'jsonError') {
      centerWidget = JsonErrorView(namespace: selectedNs);
    } else if (selectedNs != null && selectedNs.state == 'noSource') {
      final availableFiles = widget.languageFiles
          .where((lf) => lf.namespaceId == selectedNs.id)
          .toList();
      centerWidget = SourceLangPickerView(
        namespace: selectedNs,
        availableLanguageFiles: availableFiles,
        onSelectSourceFile: (langFile) =>
            widget.onSelectSourceFile?.call(langFile),
        onExcludeNamespace: () =>
            widget.onToggleNamespaceExclusion?.call(selectedNs.id, true),
      );
    } else {
      centerWidget = Column(
        children: [
          // Tab Bar header with view mode switcher
          Container(
            height: sizes.tabBar,
            decoration: BoxDecoration(
              color: colors.bgBar,
              border: Border(
                bottom: BorderSide(
                  color: colors.borderDefault,
                  width: sizes.borderThin,
                ),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: spacing.space7),
            child: Row(
              children: [
                // The tab label yields before the view switcher, which the
                // user must always be able to reach.
                if (selectedNs != null)
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.space7,
                        vertical: spacing.space3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.bgTabActive,
                        border: Border(
                          top: BorderSide(
                            color: colors.accent,
                            width: sizes.borderThick,
                          ),
                        ),
                      ),
                      child: Text(
                        '${selectedNs.name}/ko_kr.json',
                        style: context.t.codeSm.copyWith(
                          color: colors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: Text(
                      '전체 항목 목록 (${widget.totalEntryCount})',
                      style: context.t.caption.copyWith(
                        color: colors.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const Spacer(),
                // View Mode Switcher
                Row(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _activeViewMode = 'entries'),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.space6,
                          vertical: spacing.space1,
                        ),
                        decoration: BoxDecoration(
                          color: _activeViewMode == 'entries'
                              ? colors.bgRaised
                              : Colors.transparent,
                          borderRadius: context.r.xs,
                        ),
                        child: Text(
                          '대조 편집',
                          style: context.t.caption.copyWith(
                            color: _activeViewMode == 'entries'
                                ? colors.textPrimary
                                : colors.textMuted,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: spacing.space1),
                    InkWell(
                      onTap: () => setState(() => _activeViewMode = 'preview'),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.space6,
                          vertical: spacing.space1,
                        ),
                        decoration: BoxDecoration(
                          color: _activeViewMode == 'preview'
                              ? colors.bgRaised
                              : Colors.transparent,
                          borderRadius: context.r.xs,
                        ),
                        child: Text(
                          '출력 구조',
                          style: context.t.caption.copyWith(
                            color: _activeViewMode == 'preview'
                                ? colors.textPrimary
                                : colors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main View Content
          Expanded(
            child: _activeViewMode == 'preview'
                ? OutputPreviewView(
                    namespaces: widget.namespaces,
                    entries: widget.entries,
                  )
                : EntriesListView(
                    entries: widget.entries,
                    totalCount: widget.totalEntryCount,
                    statusCounts: widget.statusCounts,
                    statusFilter: widget.statusFilter,
                    hasMore: widget.hasMoreEntries,
                    onLoadMore: widget.onLoadMoreEntries,
                    onStatusFilterChanged: widget.onStatusFilterChanged,
                    onUpdateUserTranslation: widget.onUpdateUserTranslation,
                    onResetEntryToWait: widget.onResetEntryToWait,
                    onKeepSourceText: widget.onKeepSourceText,
                    isTranslating: widget.isTranslating,
                  ),
          ),
        ],
      );
    }

    // One instance, shown either docked or in the end drawer — the collapsed
    // layout must not lose access to the engine settings (DESIGN.md 6.2).
    SettingsPanel buildSettingsPanel({required bool isDocked}) => SettingsPanel(
      isDocked: isDocked,
      waitCount: waitCount,
      isTranslating: widget.isTranslating,
      isPaused: widget.isPaused,
      onStartTranslation: () => widget.onStartTranslation?.call(),
      onPauseTranslation: () => widget.onPauseTranslation?.call(),
      onResumeTranslation: widget.onResumeTranslation,
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.bgBase,
      endDrawer: isWide
          ? null
          : Drawer(
              width: sizes.settingsPanel,
              backgroundColor: colors.bgSurface,
              child: buildSettingsPanel(isDocked: false),
            ),
      drawer: isNarrow
          ? Drawer(
              width: sizes.explorerPanel,
              backgroundColor: colors.bgSurface,
              child: ProjectExplorer(
                inputFiles: widget.inputFiles,
                namespaces: widget.namespaces,
                languageFiles: widget.languageFiles,
                selectedNamespaceId: widget.selectedNamespaceId,
                onSelectNamespace: (id) {
                  widget.onSelectNamespace?.call(id);
                  Navigator.of(context).pop();
                },
                onToggleNamespaceExclusion: widget.onToggleNamespaceExclusion,
                onToggleInputFile: widget.onToggleInputFile,
                isLocked: widget.isTranslating,
              ),
            )
          : null,
      body: Column(
        children: [
          // Top Bar
          // 파일 추가·제거와 내보내기는 번역 실행 중 잠깁니다 (EXPERIENCE.md 6.4).
          TopBar(
            projectName: widget.projectName,
            isDirty: widget.isDirty,
            breadcrumbPath: breadcrumbPath,
            onAddFiles: widget.isTranslating ? null : widget.onAddFiles,
            onAddFolder: widget.isTranslating ? null : widget.onAddFolder,
            onRescan: widget.isTranslating ? null : widget.onRescan,
            onExport: widget.isTranslating ? null : widget.onExport,
            onNewProject: widget.onNewProject,
            onOpenProject: widget.onOpenProject,
            onSaveProject: widget.onSaveProject,
            onSaveProjectAs: widget.onSaveProjectAs,
            onCloseProject: widget.onCloseProject,
            onRenameProject: widget.isTranslating
                ? null
                : widget.onRenameProject,
            isLocked: widget.isTranslating,
            onSearchChanged: widget.onSearchChanged,
            searchFocusNode: widget.searchFocusNode,
            showLeftToggle: isNarrow,
            showRightToggle: !isWide,
            onToggleLeftPanel: () => _scaffoldKey.currentState?.openDrawer(),
            onToggleRightPanel: () =>
                _scaffoldKey.currentState?.openEndDrawer(),
          ),

          // Main 3-Panel Content
          Expanded(
            child: Stack(
              children: [
                Row(
                  children: [
                    // Left Explorer Panel (visible if >= 1024px)
                    if (!isNarrow)
                      ProjectExplorer(
                        inputFiles: widget.inputFiles,
                        namespaces: widget.namespaces,
                        languageFiles: widget.languageFiles,
                        selectedNamespaceId: widget.selectedNamespaceId,
                        onSelectNamespace: widget.onSelectNamespace,
                        onToggleNamespaceExclusion:
                            widget.onToggleNamespaceExclusion,
                        onToggleInputFile: widget.onToggleInputFile,
                        isLocked: widget.isTranslating,
                      ),

                    // Center View
                    Expanded(
                      child: Container(
                        color: colors.bgBase,
                        child: centerWidget,
                      ),
                    ),

                    // Right Settings Panel (visible if >= 1300px)
                    if (isWide) buildSettingsPanel(isDocked: true),
                  ],
                ),

                // Notification Banner
                if (widget.rejectedSummary.isNotEmpty)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: spacing.space6,
                    child: Center(
                      child: BottomBanner(
                        title: '확인이 필요한 항목 ${widget.rejectedSummary.length}건',
                        description: widget.rejectedSummary.join('\n'),
                        type: BannerType.error,
                        onDismiss: widget.onDismissBanner,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Status Bar
          StatusBar(
            fileCount: widget.inputFiles.length,
            namespaceCount: widget.namespaces.length,
            totalEntryCount: widget.totalEntryCount,
            statusMessage: widget.isTranslating
                ? widget.translationMessage
                : widget.scanMessage,
            isProgress: widget.isScanning || widget.isTranslating,
            progressRatio: widget.isTranslating
                ? widget.translationProgress
                : null,
            onCancel: widget.isScanning
                ? widget.onCancelScan
                : (widget.isTranslating ? widget.onCancelTranslation : null),
            cancelTooltip: widget.isScanning ? '탐색 취소' : '번역 취소',
          ),
        ],
      ),
    );
  }
}
