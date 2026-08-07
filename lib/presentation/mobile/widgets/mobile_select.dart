import 'package:flutter/material.dart';

import '../../../app/theme/theme_extensions.dart';

/// Labelled dropdown — 48px tall, radius 11, caret on the right.
///
/// Uses Flutter's own menu rather than a hand-rolled sheet so the platform's
/// text scaling and screen-reader handling come for free.
class MobileSelect<T> extends StatelessWidget {
  const MobileSelect({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabel,
    this.compact = false,
    this.helper,
  });

  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T>? onChanged;

  /// Defaults to `toString()`.
  final String Function(T value)? itemLabel;

  /// The 44px variant used inside the auth card.
  final bool compact;

  /// Shown under the field, e.g. why it is disabled.
  final String? helper;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final spacing = context.s;
    final typography = context.t;
    final height = compact ? context.m.authField : context.m.selectField;
    final enabled = onChanged != null && items.isNotEmpty;
    String text(T v) => itemLabel?.call(v) ?? '$v';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: typography.caption.copyWith(color: colors.textTertiary),
        ),
        SizedBox(height: spacing.space4 + 1),
        Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: spacing.space7 - 1),
          decoration: BoxDecoration(
            color: compact ? colors.bgBar : colors.bgRaisedHover,
            borderRadius: context.r.r3xl,
            border: Border.all(
              color: colors.borderDashed,
              width: context.d.borderThin,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: items.contains(value) ? value : null,
              isExpanded: true,
              isDense: false,
              dropdownColor: colors.bgOverlay,
              borderRadius: context.r.r3xl,
              iconEnabledColor: colors.textMuted,
              iconDisabledColor: colors.textDisabled,
              style: typography.body.copyWith(
                color: enabled ? colors.textPrimary : colors.textDisabled,
              ),
              onChanged: enabled ? (next) => onChanged!(next as T) : null,
              items: [
                for (final item in items)
                  DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      text(item),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (helper != null) ...[
          SizedBox(height: spacing.space3),
          Text(
            helper!,
            style: typography.micro.copyWith(color: colors.textFaint),
          ),
        ],
      ],
    );
  }
}

/// Read-only value box beside a select — used for `pack_format`.
class MobileReadout extends StatelessWidget {
  const MobileReadout({
    super.key,
    required this.label,
    required this.value,
    this.width,
  });

  final String label;
  final String value;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final spacing = context.s;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.t.caption.copyWith(color: colors.textTertiary),
          ),
          SizedBox(height: spacing.space4 + 1),
          Container(
            height: context.m.selectField,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.bgInputAlt,
              borderRadius: context.r.r3xl,
              border: Border.all(
                color: colors.borderDashed,
                width: context.d.borderThin,
              ),
            ),
            child: Text(
              value,
              style: context.t.codeBody.copyWith(
                fontSize: 16,
                color: colors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
