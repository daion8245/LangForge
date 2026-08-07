import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/theme_extensions.dart';
import '../../infrastructure/db/registry_database.dart';
import '../common/lf_button.dart';

class StartScreenView extends StatelessWidget {
  const StartScreenView({
    super.key,
    required this.recentProjects,
    required this.onNewProject,
    required this.onOpenProjectFile,
    required this.onSelectRecentProject,
  });

  final List<RecentProject> recentProjects;
  final VoidCallback onNewProject;
  final VoidCallback onOpenProjectFile;
  final ValueChanged<RecentProject> onSelectRecentProject;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final radii = context.r;
    final spacing = context.s;
    final typography = context.t;

    return Scaffold(
      backgroundColor: colors.bgBase,
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: context.d.modalXl),
          padding: EdgeInsets.all(spacing.space8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo Header
              Text(
                'LANGFORGE',
                style: typography.display.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: spacing.space4),
              Text(
                'Minecraft 모드 번역 및 리소스팩 생성 도구',
                style: typography.body.copyWith(color: colors.textSecondary),
              ),
              SizedBox(height: spacing.space10),

              // Recent Projects Section
              Text(
                '최근 프로젝트',
                style: typography.overline.copyWith(color: colors.textFaint),
              ),
              SizedBox(height: spacing.space4),

              Container(
                constraints: BoxConstraints(maxHeight: context.d.recentList),
                decoration: BoxDecoration(
                  color: colors.bgSurface,
                  borderRadius: radii.r2xl,
                  border: Border.all(
                    color: colors.borderPanel,
                    width: context.d.borderThin,
                  ),
                ),
                child: recentProjects.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(spacing.space8),
                          child: Text(
                            '저장된 최근 프로젝트가 없습니다.',
                            style: typography.bodySm.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: recentProjects.length,
                        separatorBuilder: (context, index) => Divider(
                          height: context.d.borderThin,
                          color: colors.borderSubtle,
                        ),
                        itemBuilder: (context, index) {
                          final proj = recentProjects[index];
                          final timeStr = _formatTime(proj.lastOpenedAt);

                          return ListTile(
                            onTap: () => onSelectRecentProject(proj),
                            title: Row(
                              children: [
                                Text(
                                  proj.name,
                                  style: typography.body.copyWith(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (proj.hasMissingFiles) ...[
                                  SizedBox(width: spacing.space3),
                                  Icon(
                                    LucideIcons.triangleAlert,
                                    size: context.d.iconSm,
                                    color: colors.warning,
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Text(
                              proj.path,
                              style: typography.codeSm.copyWith(
                                color: colors.textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              timeStr,
                              style: typography.caption.copyWith(
                                color: colors.textTertiary,
                              ),
                            ),
                          );
                        },
                      ),
              ),

              SizedBox(height: spacing.space8),

              // Bottom Action Buttons
              Row(
                children: [
                  LfButton(
                    onPressed: onNewProject,
                    label: '+ 새 프로젝트',
                    style: LfButtonStyle.primary,
                  ),
                  SizedBox(width: spacing.space4),
                  LfButton(
                    onPressed: onOpenProjectFile,
                    label: '프로젝트 파일 열기...',
                    style: LfButtonStyle.secondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }
}
