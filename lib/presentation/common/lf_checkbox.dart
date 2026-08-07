import 'package:flutter/material.dart';
import '../../app/theme/theme_extensions.dart';

class LfCheckbox extends StatelessWidget {
  const LfCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.tristate = false,
    this.semanticLabel,
  });

  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final bool tristate;

  /// What this checkbox controls, for screen readers (TECHNICAL.md 15). The
  /// visible label usually sits next to the box rather than inside it.
  final String? semanticLabel;

  /// DESIGN.md 13 — no transition runs longer than this, and none runs at all
  /// when the OS asks for reduced motion.
  static const Duration _transition = Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final radii = context.r;
    final sizes = context.d;

    final isChecked = value == true;
    final isIndeterminate = value == null && tristate;
    final enabled = onChanged != null;

    void toggle() {
      if (!enabled) return;
      if (!tristate) {
        onChanged!(!isChecked);
        return;
      }
      if (value == false) {
        onChanged!(true);
      } else if (value == true) {
        onChanged!(null);
      } else {
        onChanged!(false);
      }
    }

    // Merged and given the tap action directly: without it a reader announces
    // a checkbox it cannot activate, because the gesture lives on a separate
    // node below (TECHNICAL.md 15).
    return MergeSemantics(
      child: Semantics(
        label: semanticLabel,
        checked: isChecked,
        mixed: isIndeterminate,
        enabled: enabled,
        onTap: enabled ? toggle : null,
        child: Focus(
          canRequestFocus: enabled,
          child: Builder(
            builder: (context) {
              final focused = Focus.of(context).hasFocus;
              return InkWell(
                onTap: enabled ? toggle : null,
                borderRadius: radii.xs,
                child: Container(
                  alignment: Alignment.center,
                  // The visual box is smaller than the area that responds, so a
                  // 15px checkbox still clears the 24px minimum (DESIGN.md 14).
                  constraints: BoxConstraints(
                    minWidth: sizes.minTapTarget,
                    minHeight: sizes.minTapTarget,
                  ),
                  child: AnimatedContainer(
                    duration: context.prefersReducedMotion
                        ? Duration.zero
                        : _transition,
                    width: sizes.checkbox,
                    height: sizes.checkbox,
                    decoration: BoxDecoration(
                      color: (isChecked || isIndeterminate)
                          ? colors.accent
                          : colors.bgRaised,
                      borderRadius: radii.xs,
                      // DESIGN.md 7.1 — focus is a 2px accent outline.
                      border: Border.all(
                        color: (focused || isChecked || isIndeterminate)
                            ? colors.accent
                            : colors.borderControl,
                        width: focused ? sizes.borderThick : sizes.borderThin,
                      ),
                    ),
                    child: isChecked
                        ? Icon(
                            Icons.check,
                            size: sizes.checkbox * 0.72,
                            color: colors.accentOn,
                          )
                        : isIndeterminate
                        ? Icon(
                            Icons.remove,
                            size: sizes.checkbox * 0.72,
                            color: colors.accentOn,
                          )
                        : null,
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
