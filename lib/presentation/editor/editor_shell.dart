import 'package:flutter/material.dart';
import '../../app/theme/theme_extensions.dart';
import '../../domain/provider/translation_provider.dart';
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
    this.onAddFiles,
    this.onAddFolder,
    this.onRescan,
    this.onExport,
    this.onSearchChanged,
    this.onStartTranslation,
    this.onPauseTranslation,
    this.onResumeTranslation,
    this.onCancelScan,
    this.onCancelTranslation,
    this.onUpdateUserTranslation,
    this.onResetEntryToWait,
    this.onKeepSourceText,
    this.isScanning = false,
    this.isTranslating = false,
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
  final VoidCallback? onAddFiles;
  final VoidCallback? onAddFolder;
  final VoidCallback? onRescan;
  final VoidCallback? onExport;
  final ValueChanged<String>? onSearchChanged;
  final void Function(
    TranslationProvider provider,
    AuthValues auth,
    String model,
  )?
  onStartTranslation;
  final VoidCallback? onPauseTranslation;
  final VoidCallback? onResumeTranslation;
  final VoidCallback? onCancelScan;
  final VoidCallback? onCancelTranslation;
  final void Function(String entryId, String newText)? onUpdateUserTranslation;
  final void Function(String entryId)? onResetEntryToWait;
  final void Function(String entryId)? onKeepSourceText;

  final bool isScanning;
  final bool isTranslating;
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
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;

    final isWide = width >= 1300;
    final isNarrow = width < 1024;

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
            height: 34,
            decoration: BoxDecoration(
              color: colors.bgBar,
              border: Border(
                bottom: BorderSide(color: colors.borderDefault, width: 1),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                if (selectedNs != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.bgTabActive,
                      border: Border(
                        top: BorderSide(color: colors.accent, width: 2),
                      ),
                    ),
                    child: Text(
                      '${selectedNs.name}/ko_kr.json',
                      style: context.t.codeSm.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  )
                else
                  Text(
                    '전체 항목 목록 (${widget.totalEntryCount})',
                    style: context.t.caption.copyWith(color: colors.textMuted),
                  ),
                const Spacer(),
                // View Mode Switcher
                Row(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _activeViewMode = 'entries'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
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
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => setState(() => _activeViewMode = 'preview'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
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
                  ),
          ),
        ],
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.bgBase,
      drawer: isNarrow
          ? Drawer(
              width: 300,
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
              ),
            )
          : null,
      body: Column(
        children: [
          // Top Bar
          TopBar(
            breadcrumbPath: breadcrumbPath,
            onAddFiles: widget.onAddFiles,
            onAddFolder: widget.onAddFolder,
            onRescan: widget.onRescan,
            onExport: widget.onExport,
            onSearchChanged: widget.onSearchChanged,
            showLeftToggle: isNarrow,
            showRightToggle: !isWide,
            onToggleLeftPanel: () => _scaffoldKey.currentState?.openDrawer(),
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
                      ),

                    // Center View
                    Expanded(
                      child: Container(
                        color: colors.bgBase,
                        child: centerWidget,
                      ),
                    ),

                    // Right Settings Panel (visible if >= 1300px)
                    if (isWide)
                      SettingsPanel(
                        waitCount: waitCount,
                        isTranslating: widget.isTranslating,
                        onStartTranslation: (provider, auth, model) {
                          widget.onStartTranslation?.call(
                            provider,
                            auth,
                            model,
                          );
                        },
                        onPauseTranslation: () {
                          widget.onPauseTranslation?.call();
                        },
                      ),
                  ],
                ),

                // Notification Banner
                if (widget.rejectedSummary.isNotEmpty)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 12,
                    child: Center(
                      child: BottomBanner(
                        title: '${widget.rejectedSummary.length}개 항목 거부됨',
                        description: widget.rejectedSummary.join('\n'),
                        type: BannerType.error,
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
            statusMessage: widget.scanMessage,
            isProgress: widget.isScanning || widget.isTranslating,
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
