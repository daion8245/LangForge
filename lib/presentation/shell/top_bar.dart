import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../app/theme/theme_extensions.dart';
import '../common/lf_button.dart';

/// S6 file menu entries. Values are the menu's own identifiers, not shortcuts.
enum _FileMenuAction {
  newProject,
  openProject,
  saveProject,
  saveProjectAs,
  renameProject,
  addFiles,
  addFolder,
  rescan,
  openSettings,
  openConflicts,
  closeProject,
}

class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    this.projectName = 'Untitled Project',
    this.isDirty = false,
    this.breadcrumbPath,
    this.onAddFiles,
    this.onAddFolder,
    this.onRescan,
    this.onExport,
    this.onNewProject,
    this.onOpenProject,
    this.onSaveProject,
    this.onSaveProjectAs,
    this.onCloseProject,
    this.onRenameProject,
    this.onOpenSettings,
    this.onOpenConflicts,
    this.onSearchChanged,
    this.searchFocusNode,
    this.onToggleRightPanel,
    this.onToggleLeftPanel,
    this.showLeftToggle = false,
    this.showRightToggle = false,
    this.isLocked = false,
  });

  final String projectName;

  /// Unsaved changes exist. Shown as a marker next to the name rather than a
  /// timestamp, per EXPERIENCE.md 6.5.
  final bool isDirty;

  final String? breadcrumbPath;
  final VoidCallback? onAddFiles;
  final VoidCallback? onAddFolder;
  final VoidCallback? onRescan;
  final VoidCallback? onExport;
  final VoidCallback? onNewProject;
  final VoidCallback? onOpenProject;
  final VoidCallback? onSaveProject;
  final VoidCallback? onSaveProjectAs;
  final VoidCallback? onCloseProject;
  final VoidCallback? onRenameProject;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onOpenConflicts;
  final ValueChanged<String>? onSearchChanged;
  final FocusNode? searchFocusNode;
  final VoidCallback? onToggleRightPanel;
  final VoidCallback? onToggleLeftPanel;
  final bool showLeftToggle;
  final bool showRightToggle;

  /// A run is in flight, so the file and export actions are disabled and say
  /// why (EXPERIENCE.md 6.4).
  final bool isLocked;

  static const String _lockedTooltip = '번역이 진행 중입니다';

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final spacing = context.s;
    final typography = context.t;
    final sizes = context.d;

    // At 768px the bar has to hold the same controls in two thirds of the
    // width, so the decorative parts go first (DESIGN.md 6.2 · 14).
    final isTight = MediaQuery.sizeOf(context).width < sizes.breakpointNarrow;

    // Same reasoning as the status bar: DESIGN.md 6.1 fixes this bar's height,
    // so its own text stops scaling at a point the layout can hold. The editor
    // below still honours the full OS setting (TECHNICAL.md 15).
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: _maxChromeTextScale,
      child: Container(
        height: context.d.topBar,
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
            if (showLeftToggle) ...[
              IconButton(
                icon: Icon(LucideIcons.menu, size: sizes.iconLg),
                onPressed: onToggleLeftPanel,
                tooltip: '탐색기 열기',
              ),
              SizedBox(width: spacing.space4),
            ],

            if (!isTight) ...[
              Text(
                'LANGFORGE',
                style: typography.overline.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: spacing.space8),
            ],

            _buildFileMenu(context),

            SizedBox(width: spacing.space6),

            // Project name. Double-clicking is not discoverable on its own, so
            // renaming also lives in the file menu.
            Flexible(
              child: Tooltip(
                message: onRenameProject == null
                    ? projectName
                    : '$projectName — 이름 변경',
                child: InkWell(
                  onTap: onRenameProject,
                  borderRadius: context.r.md,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.space4,
                      vertical: spacing.space3,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            projectName,
                            style: typography.bodySm.copyWith(
                              color: colors.textStrong,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isDirty) ...[
                          SizedBox(width: spacing.space3),
                          // Text, not just a dot: state is never colour-only
                          // (DESIGN.md 14).
                          Text(
                            '저장 안 됨',
                            style: typography.caption.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(width: spacing.space6),

            if (breadcrumbPath != null && !isTight)
              Expanded(
                child: Text(
                  breadcrumbPath!,
                  style: typography.codeSm.copyWith(color: colors.textTertiary),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else
              const Spacer(),

            // Flexible so the search box is the last thing to give up width;
            // everything to its right is a control the user must be able to
            // reach at any window size.
            Flexible(
              child: SizedBox(
                width: isTight ? sizes.searchField / 2 : sizes.searchField,
                height: sizes.buttonSecondary,
                child: TextField(
                  focusNode: searchFocusNode,
                  onChanged: onSearchChanged,
                  style: typography.bodySm.copyWith(color: colors.textPrimary),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: isTight ? '검색' : 'key 또는 원문 검색... (Ctrl+F)',
                    hintStyle: typography.bodySm.copyWith(
                      color: colors.textMuted,
                    ),
                    prefixIcon: Icon(LucideIcons.search, size: sizes.iconSm),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: spacing.space2,
                    ),
                    filled: true,
                    fillColor: colors.bgInputAlt,
                    border: OutlineInputBorder(
                      borderRadius: context.r.md,
                      borderSide: BorderSide(color: colors.borderControl),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: context.r.md,
                      borderSide: BorderSide(color: colors.accent),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(width: spacing.space6),

            LfButton(
              onPressed: onExport,
              label: isTight ? null : '내보내기...',
              tooltip: isLocked ? _lockedTooltip : '내보내기 (Ctrl+E)',
              icon: Icon(LucideIcons.download, size: sizes.iconSm),
              style: LfButtonStyle.primary,
            ),

            if (showRightToggle) ...[
              SizedBox(width: spacing.space4),
              IconButton(
                icon: Icon(LucideIcons.panelRight, size: sizes.iconLg),
                onPressed: onToggleRightPanel,
                tooltip: '작업 설정 열기',
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Fixed-height chrome stops scaling here (TECHNICAL.md 15).
  static const double _maxChromeTextScale = 1.3;

  Widget _buildFileMenu(BuildContext context) {
    final colors = context.c;
    final spacing = context.s;
    final typography = context.t;

    return PopupMenuButton<_FileMenuAction>(
      tooltip: '파일 메뉴',
      color: colors.bgOverlay,
      shape: RoundedRectangleBorder(
        borderRadius: context.r.r2xl,
        side: BorderSide(
          color: colors.borderStrong,
          width: context.d.borderThin,
        ),
      ),
      onSelected: (action) {
        switch (action) {
          case _FileMenuAction.newProject:
            onNewProject?.call();
          case _FileMenuAction.openProject:
            onOpenProject?.call();
          case _FileMenuAction.saveProject:
            onSaveProject?.call();
          case _FileMenuAction.saveProjectAs:
            onSaveProjectAs?.call();
          case _FileMenuAction.renameProject:
            onRenameProject?.call();
          case _FileMenuAction.addFiles:
            onAddFiles?.call();
          case _FileMenuAction.addFolder:
            onAddFolder?.call();
          case _FileMenuAction.rescan:
            onRescan?.call();
          case _FileMenuAction.openSettings:
            onOpenSettings?.call();
          case _FileMenuAction.openConflicts:
            onOpenConflicts?.call();
          case _FileMenuAction.closeProject:
            onCloseProject?.call();
        }
      },
      itemBuilder: (context) => [
        _menuItem(
          context,
          _FileMenuAction.newProject,
          LucideIcons.filePlus2,
          '새 프로젝트',
          enabled: onNewProject != null,
        ),
        _menuItem(
          context,
          _FileMenuAction.openProject,
          LucideIcons.folderOpen,
          '프로젝트 열기...',
          enabled: onOpenProject != null,
        ),
        const PopupMenuDivider(),
        _menuItem(
          context,
          _FileMenuAction.addFiles,
          LucideIcons.filePlus,
          'JAR / ZIP 추가...',
          shortcut: 'Ctrl+O',
          enabled: onAddFiles != null,
        ),
        _menuItem(
          context,
          _FileMenuAction.addFolder,
          LucideIcons.folderPlus,
          'mods 폴더 추가...',
          shortcut: 'Ctrl+Shift+O',
          enabled: onAddFolder != null,
        ),
        _menuItem(
          context,
          _FileMenuAction.rescan,
          LucideIcons.refreshCw,
          '다시 검사',
          shortcut: 'Ctrl+Shift+R',
          enabled: onRescan != null,
        ),
        const PopupMenuDivider(),
        _menuItem(
          context,
          _FileMenuAction.saveProject,
          LucideIcons.save,
          '프로젝트 저장',
          shortcut: 'Ctrl+S',
          enabled: onSaveProject != null,
        ),
        _menuItem(
          context,
          _FileMenuAction.saveProjectAs,
          LucideIcons.copy,
          '다른 이름으로 저장...',
          enabled: onSaveProjectAs != null,
        ),
        _menuItem(
          context,
          _FileMenuAction.renameProject,
          LucideIcons.pencil,
          '프로젝트 이름 변경...',
          enabled: onRenameProject != null,
        ),
        const PopupMenuDivider(),
        _menuItem(
          context,
          _FileMenuAction.openConflicts,
          LucideIcons.gitCompareArrows,
          '충돌 해결...',
          enabled: onOpenConflicts != null,
        ),
        _menuItem(
          context,
          _FileMenuAction.openSettings,
          LucideIcons.settings,
          '환경설정',
          shortcut: 'Ctrl+,',
          enabled: onOpenSettings != null,
        ),
        const PopupMenuDivider(),
        _menuItem(
          context,
          _FileMenuAction.closeProject,
          LucideIcons.x,
          '프로젝트 닫기',
          enabled: onCloseProject != null,
        ),
      ],
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.space6,
          vertical: spacing.space4,
        ),
        decoration: BoxDecoration(
          color: colors.bgRaised,
          borderRadius: context.r.r2xl,
          border: Border.all(
            color: colors.borderControl,
            width: context.d.borderThin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.fileText, size: context.d.iconSm),
            SizedBox(width: spacing.space4),
            Text('파일 ▾', style: typography.bodySm),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<_FileMenuAction> _menuItem(
    BuildContext context,
    _FileMenuAction value,
    IconData icon,
    String label, {
    String? shortcut,
    bool enabled = true,
  }) {
    final colors = context.c;
    final spacing = context.s;
    final typography = context.t;

    return PopupMenuItem<_FileMenuAction>(
      value: value,
      enabled: enabled,
      child: Row(
        children: [
          Icon(
            icon,
            size: context.d.iconSm,
            color: enabled ? colors.textSecondary : colors.textDisabled,
          ),
          SizedBox(width: spacing.space5),
          // The label yields before the shortcut does: a truncated shortcut
          // would be unreadable, a truncated label is still recognisable.
          Flexible(
            child: Text(
              label,
              style: typography.bodySm.copyWith(
                color: enabled ? colors.textPrimary : colors.textDisabled,
              ),
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
          if (shortcut != null) ...[
            SizedBox(width: spacing.space8),
            Text(
              shortcut,
              style: typography.codeSm.copyWith(color: colors.textDisabled),
            ),
          ],
        ],
      ),
    );
  }
}
