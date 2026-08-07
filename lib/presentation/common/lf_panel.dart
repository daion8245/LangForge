import 'package:flutter/material.dart';
import '../../app/theme/theme_extensions.dart';

class LfPanel extends StatelessWidget {
  const LfPanel({
    super.key,
    required this.child,
    this.title,
    this.headerAction,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
  });

  final Widget child;
  final String? title;
  final Widget? headerAction;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final radii = context.r;
    final spacing = context.s;
    final typography = context.t;

    final bg = backgroundColor ?? colors.bgSurface;
    final border = borderColor ?? colors.borderPanel;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radii.r2xl,
        border: Border.all(color: border, width: context.d.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null || headerAction != null) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.space7,
                vertical: spacing.space5,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: border,
                    width: context.d.borderThin,
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (title != null)
                    Expanded(
                      child: Text(
                        title!.toUpperCase(),
                        style: typography.overline.copyWith(
                          color: colors.textFaint,
                        ),
                      ),
                    ),
                  ?headerAction,
                ],
              ),
            ),
          ],
          Padding(
            padding: padding ?? EdgeInsets.all(spacing.space7),
            child: child,
          ),
        ],
      ),
    );
  }
}
