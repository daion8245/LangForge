import 'package:flutter/material.dart';
import '../../app/theme/theme_extensions.dart';

class LfTextField extends StatelessWidget {
  const LfTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.placeholder,
    this.onChanged,
    this.obscureText = false,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final bool readOnly;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final radii = context.r;
    final spacing = context.s;
    final typography = context.t;

    return Container(
      decoration: BoxDecoration(
        color: colors.bgRaised,
        borderRadius: radii.r2xl,
        border: Border.all(
          color: colors.borderControl,
          width: context.d.borderThin,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.space5,
        vertical: maxLines == 1 ? spacing.space3 : spacing.space4,
      ),
      child: Row(
        children: [
          if (prefixIcon != null) ...[
            IconTheme(
              data: IconThemeData(
                color: colors.textTertiary,
                size: context.d.iconMd,
              ),
              child: prefixIcon!,
            ),
            SizedBox(width: spacing.space4),
          ],
          Expanded(
            child: TextFormField(
              controller: controller,
              initialValue: initialValue,
              onChanged: onChanged,
              obscureText: obscureText,
              readOnly: readOnly,
              maxLines: maxLines,
              style: typography.bodySm.copyWith(color: colors.textPrimary),
              cursorColor: colors.accent,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: placeholder,
                hintStyle: typography.bodySm.copyWith(color: colors.textMuted),
              ),
            ),
          ),
          if (suffixIcon != null) ...[
            SizedBox(width: spacing.space4),
            IconTheme(
              data: IconThemeData(
                color: colors.textTertiary,
                size: context.d.iconMd,
              ),
              child: suffixIcon!,
            ),
          ],
        ],
      ),
    );
  }
}
