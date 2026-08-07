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
    this.cacheHitRateLabel = '—',
    this.statusMessage,
    this.isProgress = false,
    this.progressRatio,
    this.onCancel,
    this.cancelTooltip = '취소',
  });

  final int fileCount;
  final int namespaceCount;
  final int totalEntryCount;

  /// Pre-formatted (`25%` or `—`). Never pass a raw ratio (AGENTS.md 5.3).
  final String cacheHitRateLabel;
  final String? statusMessage;
  final bool isProgress;

  /// `null` means the total is not known yet, which draws an indeterminate
  /// bar. A ratio is never computed from a zero total (DESIGN.md 14).
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

    // The bar's height is fixed by DESIGN.md 6.1, so its text cannot grow
    // without bound. Chrome scales up to a point and then stops; the editing
    // surface below still honours the full setting (TECHNICAL.md 15).
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: _maxChromeTextScale,
      child: Container(
        height: context.d.statusBar,
        decoration: BoxDecoration(
          color: colors.bgBar,
          border: Border(
            top: BorderSide(
              color: colors.borderDefault,
              width: context.d.borderThin,
            ),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: spacing.space7),
        child: Row(
          children: [
            // Counts summary
            Flexible(
              child: Text(
                '파일 $fileCount개  |  namespace $namespaceCount개  |  항목 ${_formatNumber(totalEntryCount)}개',
                style: typography.caption.copyWith(color: colors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const Spacer(),

            Text(
              '캐시 $cacheHitRateLabel',
              style: typography.caption.copyWith(color: colors.textSecondary),
            ),

            SizedBox(width: spacing.space7),

            if (isProgress) ...[
              SizedBox(
                width: context.d.progressBarWidth,
                height: context.d.progressBarHeight,
                child: LinearProgressIndicator(
                  value: progressRatio,
                  backgroundColor: colors.bgRaised,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
                ),
              ),
              SizedBox(width: spacing.space5),
              // Numbers are never rendered as NaN% — an unknown total shows the
              // em dash instead (DESIGN.md 14 · AGENTS.md 5.3).
              Text(
                progressRatio == null
                    ? '—'
                    : '${(progressRatio! * 100).round()}%',
                style: typography.caption.copyWith(color: colors.textSecondary),
              ),
              SizedBox(width: spacing.space5),
              if (onCancel != null) ...[
                LfButton(
                  onPressed: onCancel,
                  icon: Icon(LucideIcons.x),
                  style: LfButtonStyle.tertiary,
                  tooltip: cancelTooltip,
                ),
                SizedBox(width: spacing.space5),
              ],
            ],

            Flexible(
              child: Text(
                statusMessage ?? '준비됨',
                style: typography.caption.copyWith(color: colors.textMuted),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fixed-height chrome stops scaling here (TECHNICAL.md 15).
  static const double _maxChromeTextScale = 1.3;

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}
