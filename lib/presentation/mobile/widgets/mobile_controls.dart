import 'package:flutter/material.dart';

import '../../../app/theme/theme_extensions.dart';

/// Wraps anything small in the 44×44 minimum of DESIGN.md 6.3.
///
/// The visual size stays whatever the mockup says; only the area that responds
/// to a finger grows. Every tappable thing in the mobile shell goes through
/// this, so the rule is enforced in one place instead of being remembered at
/// thirty call sites.
class MobileTapTarget extends StatelessWidget {
  const MobileTapTarget({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.borderRadius,
    this.padding,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final minimum = context.m.minTapTarget;
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      enabled: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? context.r.md,
        child: Container(
          alignment: Alignment.center,
          padding: padding,
          constraints: BoxConstraints(minWidth: minimum, minHeight: minimum),
          child: child,
        ),
      ),
    );
  }
}

/// 19×19 checkbox — DESIGN.md 6.3 widens the desktop 15px for touch.
class MobileCheckbox extends StatelessWidget {
  const MobileCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  /// Dimmed but still readable, matching the mockup's `opacity: .5`.
  final bool enabled;

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final sizes = context.m;
    final active = onChanged != null && enabled;

    final box = Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Container(
        width: sizes.checkbox,
        height: sizes.checkbox,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: value ? colors.accent : Colors.transparent,
          borderRadius: context.r.sm,
          border: Border.all(
            color: value ? colors.accent : colors.borderCheckbox,
            width: context.d.borderThin,
          ),
        ),
        child: value
            ? Icon(
                Icons.check,
                size: sizes.checkbox * 0.7,
                color: colors.accentOn,
              )
            : null,
      ),
    );

    return MergeSemantics(
      child: Semantics(
        label: semanticLabel,
        checked: value,
        enabled: active,
        onTap: active ? () => onChanged!(!value) : null,
        child: MobileTapTarget(
          onTap: active ? () => onChanged!(!value) : null,
          borderRadius: context.r.sm,
          child: box,
        ),
      ),
    );
  }
}

/// 16px radio — DESIGN.md 7.5. The whole row is the tap target, so this only
/// draws the dot.
class MobileRadioDot extends StatelessWidget {
  const MobileRadioDot({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final size = context.m.radio;
    return SizedBox(
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? colors.accent : colors.borderRadio,
            width: context.d.borderThin,
          ),
        ),
        child: selected
            ? Center(
                child: Container(
                  width: size * 0.56,
                  height: size * 0.56,
                  decoration: BoxDecoration(
                    color: colors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

/// 40×23 toggle with a 19px knob — DESIGN.md 6.3.
class MobileToggle extends StatelessWidget {
  const MobileToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  /// The mockup's `transition: background .18s ease`.
  static const Duration _transition = Duration(milliseconds: 180);

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final sizes = context.m;
    final enabled = onChanged != null;
    final duration = context.prefersReducedMotion ? Duration.zero : _transition;

    return MergeSemantics(
      child: Semantics(
        label: semanticLabel,
        toggled: value,
        enabled: enabled,
        onTap: enabled ? () => onChanged!(!value) : null,
        child: MobileTapTarget(
          onTap: enabled ? () => onChanged!(!value) : null,
          borderRadius: context.r.full,
          child: AnimatedContainer(
            duration: duration,
            curve: Curves.ease,
            width: sizes.toggleTrackW,
            height: sizes.toggleTrackH,
            padding: EdgeInsets.all(
              (sizes.toggleTrackH - sizes.toggleKnob) / 2,
            ),
            decoration: BoxDecoration(
              color: value ? colors.accent : colors.borderDashed,
              borderRadius: context.r.full,
            ),
            child: AnimatedAlign(
              duration: duration,
              curve: Curves.ease,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: sizes.toggleKnob,
                height: sizes.toggleKnob,
                decoration: BoxDecoration(
                  color: value ? colors.accentOn : colors.textMuted,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The option row of MOBILE.md 2.2 — radius 12, padding 14, radio on the left.
class MobileOptionRow extends StatelessWidget {
  const MobileOptionRow({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.hint,
  });

  final String label;
  final String? hint;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final spacing = context.s;
    final typography = context.t;

    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: context.r.r3xl,
        child: Container(
          constraints: BoxConstraints(minHeight: context.m.minTapTarget),
          padding: EdgeInsets.all(spacing.space7),
          decoration: BoxDecoration(
            color: selected
                ? colors.accent.withValues(alpha: 0.06)
                : colors.bgSelected,
            borderRadius: context.r.r3xl,
            border: Border.all(
              color: selected ? colors.borderAccent : colors.borderPanel,
              width: context.d.borderThin,
            ),
          ),
          child: Row(
            children: [
              MobileRadioDot(selected: selected),
              SizedBox(width: spacing.space7 - 2),
              Expanded(
                child: Text(
                  label,
                  style: typography.body.copyWith(color: colors.textStrong),
                ),
              ),
              if (hint != null) ...[
                SizedBox(width: spacing.space5),
                Text(
                  hint!,
                  style: typography.codeSm.copyWith(color: colors.textFaint),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
