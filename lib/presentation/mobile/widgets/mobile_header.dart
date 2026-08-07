import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/theme_extensions.dart';
import 'mobile_controls.dart';

/// Header of DESIGN.md 6.3 — app mark, title, subtitle, settings gear.
///
/// The subtitle is the mobile stand-in for the desktop breadcrumb and status
/// bar at once: on 편집 it is the source→target path, elsewhere it is the run
/// or project summary. Read-only, like the desktop breadcrumb (DESIGN.md 6.1).
class MobileHeader extends StatelessWidget {
  const MobileHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onOpenSettings,
  });

  final String title;
  final String subtitle;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final spacing = context.s;
    final typography = context.t;
    final sizes = context.m;

    return Container(
      height: sizes.header,
      padding: EdgeInsets.symmetric(horizontal: sizes.headerPadding),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.borderDefault,
            width: context.d.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: sizes.appMark,
            height: sizes.appMark,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.accent,
              borderRadius: context.r.md,
            ),
            child: Text(
              'L',
              style: typography.codeSm.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.accentOn,
              ),
            ),
          ),
          SizedBox(width: spacing.space6),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.heading.copyWith(color: colors.textPrimary),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.codeSm.copyWith(
                    fontSize: 10.5,
                    color: colors.textFaint,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: spacing.space5),
          MobileTapTarget(
            onTap: onOpenSettings,
            semanticLabel: '설정 열기',
            borderRadius: context.r.r2xl,
            child: Container(
              width: sizes.headerButton,
              height: sizes.headerButton,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.bgRaised,
                borderRadius: context.r.r2xl,
                border: Border.all(
                  color: colors.borderControl,
                  width: context.d.borderThin,
                ),
              ),
              child: Icon(
                LucideIcons.settings,
                size: context.d.iconMd - 1,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The 3px run progress bar directly under the header.
class MobileProgressBar extends StatelessWidget {
  const MobileProgressBar({super.key, required this.percent});

  /// 0..1, or null when nothing is running.
  final double? percent;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final height = context.m.progressBar;
    final value = (percent ?? 0).clamp(0.0, 1.0);

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: colors.borderDefault)),
          FractionallySizedBox(
            widthFactor: value,
            child: SizedBox(
              height: height,
              child: ColoredBox(color: colors.accent),
            ),
          ),
        ],
      ),
    );
  }
}
