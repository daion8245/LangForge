import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../app/theme/theme_extensions.dart';

enum BannerType { success, error, info }

class BottomBanner extends StatefulWidget {
  const BottomBanner({
    super.key,
    required this.title,
    this.description,
    this.type = BannerType.info,
    this.onDismiss,
  });

  final String title;
  final String? description;
  final BannerType type;
  final VoidCallback? onDismiss;

  @override
  State<BottomBanner> createState() => _BottomBannerState();
}

class _BottomBannerState extends State<BottomBanner> {
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    if (widget.type == BannerType.success) {
      _autoDismissTimer = Timer(const Duration(seconds: 5), () {
        widget.onDismiss?.call();
      });
    }
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final radii = context.r;
    final spacing = context.s;
    final typography = context.t;

    Color bg;
    Color border;
    Color titleColor;

    switch (widget.type) {
      case BannerType.success:
        bg = colors.successSurface;
        border = colors.successBorder;
        titleColor = colors.successText;
        break;
      case BannerType.error:
        bg = colors.dangerSurface;
        border = colors.dangerBorder;
        titleColor = colors.dangerText;
        break;
      case BannerType.info:
        bg = colors.bgRaised;
        border = colors.borderControl;
        titleColor = colors.textPrimary;
        break;
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 560),
      margin: EdgeInsets.only(bottom: spacing.space6),
      padding: EdgeInsets.all(spacing.space7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radii.r3xl,
        border: Border.all(color: border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: typography.bodySm.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.description != null) ...[
                  SizedBox(height: spacing.space1),
                  Text(
                    widget.description!,
                    style: typography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: spacing.space5),
          InkWell(
            onTap: widget.onDismiss,
            borderRadius: radii.xs,
            child: Icon(LucideIcons.x, size: 16, color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}
