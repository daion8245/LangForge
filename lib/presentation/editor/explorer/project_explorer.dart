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
  });

  final List<InputFile> inputFiles;
  final List<Namespace> namespaces;
  final List<LanguageFile> languageFiles;
  final String? selectedNamespaceId;
  final ValueChanged<String>? onSelectNamespace;
  final void Function(String nsId, bool excluded)? onToggleNamespaceExclusion;

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

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: colors.bgSurface,
        border: Border(right: BorderSide(color: colors.borderPanel, width: 1)),
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
                bottom: BorderSide(color: colors.borderDefault, width: 1),
              ),
            ),
            child: Row(
              children: [
                Text(
                  '프로젝트 탐색기',
                  style: typography.overline.copyWith(color: colors.textFaint),
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
                        height: 28,
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.space5,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isExpanded
                                  ? LucideIcons.chevronDown
                                  : LucideIcons.chevronRight,
                              size: 14,
                              color: colors.textMuted,
                            ),
                            SizedBox(width: spacing.space3),
                            Icon(
                              file.kind == 'jar'
                                  ? LucideIcons.archive
                                  : LucideIcons.folder,
                              size: 14,
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
                        final isSelected = ns.id == widget.selectedNamespaceId;

                        Color statusDotColor;
                        Widget? statusIcon;

                        switch (ns.state) {
                          case 'ok':
                            statusDotColor = colors.statusDoneFg;
                            break;
                          case 'no_source':
                            statusDotColor = colors.warning;
                            break;
                          case 'json_error':
                            statusDotColor = colors.danger;
                            statusIcon = Icon(
                              LucideIcons.alertTriangle,
                              size: 12,
                              color: colors.danger,
                            );
                            break;
                          default:
                            statusDotColor = colors.statusWaitFg;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(left: 18),
                          child: InkWell(
                            onTap: () => widget.onSelectNamespace?.call(ns.id),
                            child: Container(
                              height: 26,
                              margin: const EdgeInsets.symmetric(vertical: 1),
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
                                    value: !ns.excluded,
                                    onChanged: ns.state == 'json_error'
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
                                      width: 6,
                                      height: 6,
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
    );
  }
}
