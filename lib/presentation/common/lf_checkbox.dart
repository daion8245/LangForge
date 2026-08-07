import 'package:flutter/material.dart';
import '../../app/theme/theme_extensions.dart';

class LfCheckbox extends StatelessWidget {
  const LfCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.tristate = false,
  });

  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final bool tristate;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final radii = context.r;

    final isChecked = value == true;
    final isIndeterminate = value == null && tristate;

    return InkWell(
      onTap: onChanged == null
          ? null
          : () {
              if (tristate) {
                if (value == false) {
                  onChanged!(true);
                } else if (value == true) {
                  onChanged!(null);
                } else {
                  onChanged!(false);
                }
              } else {
                onChanged!(!isChecked);
              }
            },
      borderRadius: radii.xs,
      child: Container(
        alignment: Alignment.center,
        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            color: (isChecked || isIndeterminate)
                ? colors.accent
                : colors.bgRaised,
            borderRadius: radii.xs,
            border: Border.all(
              color: (isChecked || isIndeterminate)
                  ? colors.accent
                  : colors.borderControl,
              width: 1,
            ),
          ),
          child: isChecked
              ? Icon(Icons.check, size: 11, color: colors.accentOn)
              : isIndeterminate
              ? Icon(Icons.remove, size: 11, color: colors.accentOn)
              : null,
        ),
      ),
    );
  }
}
