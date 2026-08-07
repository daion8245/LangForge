import 'package:flutter/material.dart';

import '../../app/theme/theme_extensions.dart';

/// Toggle switch from DESIGN.md 7.6.
class LfToggle extends StatelessWidget {
  const LfToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  static const Duration _transition = Duration(milliseconds: 180);

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final sizes = context.d;
    final enabled = onChanged != null;

    void toggle() {
      if (!enabled) return;
      onChanged!(!value);
    }

    final trackColor = value ? colors.accent : colors.borderDashed;
    final knobColor = value ? colors.accentOn : colors.textMuted;

    return MergeSemantics(
      child: Semantics(
        label: semanticLabel,
        toggled: value,
        enabled: enabled,
        onTap: enabled ? toggle : null,
        child: Focus(
          canRequestFocus: enabled,
          child: Builder(
            builder: (context) {
              final focused = Focus.of(context).hasFocus;
              return InkWell(
                onTap: enabled ? toggle : null,
                borderRadius: context.r.full,
                child: Container(
                  alignment: Alignment.center,
                  constraints: BoxConstraints(
                    minWidth: sizes.minTapTarget,
                    minHeight: sizes.minTapTarget,
                  ),
                  decoration: focused
                      ? BoxDecoration(
                          borderRadius: context.r.full,
                          border: Border.all(
                            color: colors.accent,
                            width: sizes.borderThin,
                          ),
                        )
                      : null,
                  child: AnimatedContainer(
                    duration: context.prefersReducedMotion
                        ? Duration.zero
                        : _transition,
                    curve: Curves.ease,
                    width: sizes.toggleTrackW,
                    height: sizes.toggleTrackH,
                    padding: EdgeInsets.all(
                      (sizes.toggleTrackH - sizes.toggleKnob) / 2,
                    ),
                    decoration: BoxDecoration(
                      color: enabled
                          ? trackColor
                          : trackColor.withValues(alpha: 0.5),
                      borderRadius: context.r.full,
                    ),
                    child: AnimatedAlign(
                      duration: context.prefersReducedMotion
                          ? Duration.zero
                          : _transition,
                      curve: Curves.ease,
                      alignment: value
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: sizes.toggleKnob,
                        height: sizes.toggleKnob,
                        decoration: BoxDecoration(
                          color: enabled
                              ? knobColor
                              : knobColor.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
