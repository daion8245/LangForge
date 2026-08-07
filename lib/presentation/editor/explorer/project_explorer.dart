import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/theme_extensions.dart';
import '../../../infrastructure/db/app_database.dart';
import '../../common/lf_checkbox.dart';

class ProjectExplorer extends StatefulWidget {
  const ProjectExplorer({
    super.key,
    required this.inputFiles,
    required this.namespaces,
    required this.languageFiles,
    this.selectedNamespaceId,
    this.onSelectNamespace,
    this.onToggleNamespaceExclusion,
    this.onToggleInputFile,
    this.isLocked = false,
  });

  final List<InputFile> inputFiles;
  final List<Namespace> namespaces;
  final List<LanguageFile> languageFiles;
  final String? selectedNamespaceId;
  final ValueChanged<String>? onSelectNamespace;
  final void Function(String nsId, bool excluded)? onToggleNamespaceExclusion;

  /// Toggling a JAR takes every namespace under it with it (AC-8.2).
  final void Function(String inputFileId, bool enabled)? onToggleInputFile;

  /// Selection is locked while a run is in flight (EXPERIENCE.md 6.4).
  final bool isLocked;

  @override
  State<ProjectExplorer> createState() => _ProjectExplorerState();
}

class _ProjectExplorerState extends State<ProjectExplorer> {
  final Set<String> _expandedFileIds = {};

  @override
  void initState() {
    super.initState();
    // Expand all files by default
    _expandedFileIds.addAll(widget.inputFiles.map((f) => f.id));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final spacing = context.s;
    final typography = context.t;
    final sizes = context.d;

    // Tab moves through the tree as one group before leaving the panel
    // (TECHNICAL.md 15).
    return FocusTraversalGroup(
      child: Container(
        width: sizes.explorerPanel,
        decoration: BoxDecoration(
          color: colors.bgSurface,
          border: Border(
            right: BorderSide(
              color: colors.borderPanel,
              width: sizes.borderThin,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.space7,
                vertical: spacing.space5,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colors.borderDefault,
                    width: sizes.borderThin,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      '프로젝트 탐색기',
                      style: typography.overline.copyWith(
                        color: colors.textFaint,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${widget.namespaces.length} ns',
                    style: typography.caption.copyWith(color: colors.textMuted),
                  ),
                ],
              ),
            ),

            // Tree List
            Expanded(
              child: ListView.builder(
                itemCount: widget.inputFiles.length,
                itemBuilder: (context, index) {
                  final file = widget.inputFiles[index];
                  final isExpanded = _expandedFileIds.contains(file.id);
                  final fileNamespaces = widget.namespaces
                      .where((ns) => ns.inputFileId == file.id)
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Level 1: Input File Row
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedFileIds.remove(file.id);
                            } else {
                              _expandedFileIds.add(file.id);
                            }
                          });
                        },
                        child: Container(
                          height: sizes.treeRowFile,
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing.space5,
                          ),
                          child: Row(
                            children: [
                              LfCheckbox(
                                semanticLabel: '${file.originalName} 포함',
                                value: fileNamespaces.isEmpty
                                    ? file.enabled
                                    : fileNamespaces.any((ns) => !ns.excluded),
                                onChanged: widget.isLocked
                                    ? null
                                    : (val) => widget.onToggleInputFile?.call(
                                        file.id,
                                        val ?? false,
                                      ),
                              ),
                              SizedBox(width: spacing.space3),
                              Icon(
                                isExpanded
                                    ? LucideIcons.chevronDown
                                    : LucideIcons.chevronRight,
                                size: sizes.iconSm,
                                color: colors.textMuted,
                              ),
                              SizedBox(width: spacing.space3),
                              Icon(
                                file.kind == 'jar'
                                    ? LucideIcons.archive
                                    : LucideIcons.folder,
                                size: sizes.iconSm,
                                color: colors.textSecondary,
                              ),
                              SizedBox(width: spacing.space4),
                              Expanded(
                                child: Text(
                                  file.originalName,
                                  style: typography.bodySm.copyWith(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Level 2: Namespaces
                      if (isExpanded)
                        ...fileNamespaces.map((ns) {
                          final isSelected =
                              ns.id == widget.selectedNamespaceId;

                          Color statusDotColor;
                          Widget? statusIcon;

                          switch (ns.state) {
                            case 'ok':
                              statusDotColor = colors.statusDoneFg;
                              break;
                            case 'noSource':
                              statusDotColor = colors.warning;
                              break;
                            case 'jsonError':
                              statusDotColor = colors.danger;
                              statusIcon = Icon(
                                LucideIcons.alertTriangle,
                                size: sizes.iconSm,
                                color: colors.danger,
                              );
                              break;
                            default:
                              statusDotColor = colors.statusWaitFg;
                          }

                          return Padding(
                            padding: EdgeInsets.only(left: spacing.space9),
                            child: InkWell(
                              onTap: () =>
                                  widget.onSelectNamespace?.call(ns.id),
                              child: Container(
                                height: sizes.treeRowNamespace,
                                margin: EdgeInsets.symmetric(
                                  vertical: spacing.space1 / 2,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: spacing.space3,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colors.bgSelected
                                      : Colors.transparent,
                                  borderRadius: context.r.md,
                                ),
                                child: Row(
                                  children: [
                                    LfCheckbox(
                                      semanticLabel: 'namespace ${ns.name} 포함',
                                      value: !ns.excluded,
                                      onChanged:
                                          ns.state == 'jsonError' ||
                                              widget.isLocked
                                          ? null
                                          : (val) => widget
                                                .onToggleNamespaceExclusion
                                                ?.call(ns.id, val == false),
                                    ),
                                    SizedBox(width: spacing.space3),
                                    if (statusIcon != null)
                                      statusIcon
                                    else
                                      Container(
                                        width: sizes.statusDot,
                                        height: sizes.statusDot,
                                        decoration: BoxDecoration(
                                          color: statusDotColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    SizedBox(width: spacing.space4),
                                    Expanded(
                                      child: Text(
                                        ns.name,
                                        style: typography.bodySm.copyWith(
                                          color: ns.excluded
                                              ? colors.textDisabled
                                              : colors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '${ns.keyCount}',
                                      style: typography.codeSm.copyWith(
                                        color: colors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
