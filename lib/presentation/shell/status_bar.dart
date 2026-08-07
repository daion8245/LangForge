import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/theme_extensions.dart';
import '../common/lf_button.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({
    super.key,
    this.fileCount = 0,
    this.namespaceCount = 0,
    this.totalEntryCount = 0,
    this.statusMessage,
    this.isProgress = false,
    this.progressRatio,
    this.onCancel,
    this.cancelTooltip = '취소',
  });

  final int fileCount;
  final int namespaceCount;
  final int totalEntryCount;
  final String? statusMessage;
  final bool isProgress;
  final double? progressRatio;

  /// Shown only while something is running. Long scans and translation runs
  /// must be interruptible (ROADMAP Phase 1 · 3 완료 조건).
  final VoidCallback? onCancel;
  final String cancelTooltip;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final spacing = context.s;
    final typography = context.t;

    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: colors.bgBar,
        border: Border(top: BorderSide(color: colors.borderDefault, width: 1)),
      ),
      padding: EdgeInsets.symmetric(horizontal: spacing.space7),
      child: Row(
        children: [
          // Counts summary
          Text(
            '파일 $fileCount개  |  namespace $namespaceCount개  |  항목 ${_formatNumber(totalEntryCount)}개',
            style: typography.caption.copyWith(color: colors.textSecondary),
          ),

          const Spacer(),

          if (isProgress) ...[
            SizedBox(
              width: 120,
              height: 4,
              child: LinearProgressIndicator(
                value: progressRatio,
                backgroundColor: colors.bgRaised,
                valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
              ),
            ),
            SizedBox(width: spacing.space5),
            if (onCancel != null) ...[
              LfButton(
                onPressed: onCancel,
                icon: const Icon(LucideIcons.x),
                style: LfButtonStyle.tertiary,
                tooltip: cancelTooltip,
              ),
              SizedBox(width: spacing.space5),
            ],
          ],

          if (statusMessage != null)
            Text(
              statusMessage!,
              style: typography.caption.copyWith(color: colors.textMuted),
            )
          else
            Text(
              '준비됨',
              style: typography.caption.copyWith(color: colors.textMuted),
            ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}
