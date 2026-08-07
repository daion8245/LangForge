import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../app/theme/theme_extensions.dart';
import '../common/lf_button.dart';

class TopBar extends StatelessWidget {
  final String? breadcrumbPath;
  final VoidCallback? onAddFiles;
  final VoidCallback? onAddFolder;
  final VoidCallback? onRescan;
  final VoidCallback? onExport;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onToggleRightPanel;
  final VoidCallback? onToggleLeftPanel;
  final bool showLeftToggle;
  final bool showRightToggle;

  const TopBar({
    super.key,
    this.breadcrumbPath,
    this.onAddFiles,
    this.onAddFolder,
    this.onRescan,
    this.onExport,
    this.onSearchChanged,
    this.onToggleRightPanel,
    this.onToggleLeftPanel,
    this.showLeftToggle = false,
    this.showRightToggle = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final spacing = context.s;
    final typography = context.t;

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: colors.bgBar,
        border: Border(
          bottom: BorderSide(color: colors.borderDefault, width: 1),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: spacing.space7),
      child: Row(
        children: [
          if (showLeftToggle) ...[
            IconButton(
              icon: const Icon(LucideIcons.menu, size: 18),
              onPressed: onToggleLeftPanel,
              tooltip: '탐색기 열기',
            ),
            SizedBox(width: spacing.space4),
          ],

          // App Logo / Wordmark
          Text(
            'LANGFORGE',
            style: typography.overline.copyWith(
              color: colors.accent,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
              letterSpacing: 0.14 * 11.5,
            ),
          ),
          SizedBox(width: spacing.space8),

          // File Add Menu Button
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'files') onAddFiles?.call();
              if (value == 'folder') onAddFolder?.call();
              if (value == 'rescan') onRescan?.call();
            },
            color: colors.bgOverlay,
            shape: RoundedRectangleBorder(
              borderRadius: context.r.r2xl,
              side: BorderSide(color: colors.borderStrong, width: 1),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'files',
                child: Row(
                  children: [
                    const Icon(LucideIcons.filePlus, size: 14),
                    SizedBox(width: spacing.space5),
                    Text('JAR / ZIP 추가...', style: typography.bodySm),
                    const Spacer(),
                    Text(
                      'Ctrl+O',
                      style: typography.codeSm.copyWith(
                        color: colors.textDisabled,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'folder',
                child: Row(
                  children: [
                    const Icon(LucideIcons.folderPlus, size: 14),
                    SizedBox(width: spacing.space5),
                    Text('mods 폴더 추가...', style: typography.bodySm),
                    const Spacer(),
                    Text(
                      'Ctrl+Shift+O',
                      style: typography.codeSm.copyWith(
                        color: colors.textDisabled,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'rescan',
                child: Row(
                  children: [
                    const Icon(LucideIcons.refreshCw, size: 14),
                    SizedBox(width: spacing.space5),
                    Text('다시 검사', style: typography.bodySm),
                    const Spacer(),
                    Text(
                      'Ctrl+Shift+R',
                      style: typography.codeSm.copyWith(
                        color: colors.textDisabled,
                      ),
                    ),
                  ],
                ),
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
                border: Border.all(color: colors.borderControl, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.fileText, size: 14),
                  SizedBox(width: spacing.space4),
                  Text('파일 ▾', style: typography.bodySm),
                ],
              ),
            ),
          ),

          SizedBox(width: spacing.space8),

          // Breadcrumbs
          if (breadcrumbPath != null)
            Expanded(
              child: Text(
                breadcrumbPath!,
                style: typography.codeSm.copyWith(color: colors.textTertiary),
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            const Spacer(),

          // Search Field
          SizedBox(
            width: 200,
            height: 28,
            child: TextField(
              onChanged: onSearchChanged,
              style: typography.bodySm.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'key 또는 원문 검색...',
                hintStyle: typography.bodySm.copyWith(color: colors.textMuted),
                prefixIcon: const Icon(LucideIcons.search, size: 14),
                contentPadding: EdgeInsets.symmetric(vertical: spacing.space2),
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

          SizedBox(width: spacing.space6),

          // Export Button
          LfButton(
            onPressed: onExport,
            label: '내보내기...',
            icon: const Icon(LucideIcons.download, size: 14),
            style: LfButtonStyle.primary,
          ),

          SizedBox(width: spacing.space6),

          // Settings Action Button
          LfButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.settings),
            style: LfButtonStyle.icon,
            tooltip: '설정',
          ),

          if (showRightToggle) ...[
            SizedBox(width: spacing.space4),
            IconButton(
              icon: const Icon(LucideIcons.panelRight, size: 18),
              onPressed: onToggleRightPanel,
              tooltip: '작업 설정 열기',
            ),
          ],
        ],
      ),
    );
  }
}
