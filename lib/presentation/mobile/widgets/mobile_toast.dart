import 'package:flutter/material.dart';

import '../../../app/theme/theme_extensions.dart';
import '../../../application/mobile/mobile_ui_controller.dart';
import 'mobile_controls.dart';

/// Toast — ROADMAP 13.7 · MOBILE.md 2.4.
///
/// A toast, not a snackbar: it sits above the bottom tab bar rather than over
/// it, so the tabs stay reachable while it is up. It never auto-dismisses when
/// it reports a failure — a message the user did not see is the same as no
/// message.
class MobileToastView extends StatelessWidget {
  const MobileToastView({
    super.key,
    required this.toast,
    required this.onDismiss,
  });

  final MobileToast toast;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final spacing = context.s;
    final typography = context.t;
    final sizes = context.m;

    final tint = toast.isError ? colors.danger : colors.accent;
    final tintBg = toast.isError ? colors.statusInvalidBg : colors.statusDoneBg;

    return Positioned(
      left: spacing.space8,
      right: spacing.space8,
      bottom: sizes.toastBottom,
      child: Semantics(
        liveRegion: true,
        container: true,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.space8 - 1,
              vertical: spacing.space7 - 1,
            ),
            decoration: BoxDecoration(
              color: colors.bgOverlay,
              borderRadius: context.r.r3xl,
              border: Border.all(
                color: colors.borderStrong,
                width: context.d.borderThin,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x80000000),
                  blurRadius: 34,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: sizes.toastIcon,
                  height: sizes.toastIcon,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tintBg,
                    borderRadius: context.r.lg,
                  ),
                  child: Text(
                    toast.isError ? '!' : '✓',
                    style: typography.label.copyWith(color: tint),
                  ),
                ),
                SizedBox(width: spacing.space6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        toast.title,
                        style: typography.bodySm.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: spacing.space1 + 1),
                      Text(
                        toast.body,
                        style: typography.caption.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: spacing.space2),
                MobileTapTarget(
                  onTap: onDismiss,
                  semanticLabel: '알림 닫기',
                  borderRadius: context.r.lg,
                  child: Container(
                    width: sizes.toastClose,
                    height: sizes.toastClose,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.bgSelected,
                      borderRadius: context.r.lg,
                    ),
                    child: Text(
                      '×',
                      style: typography.body.copyWith(color: colors.textMuted),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
