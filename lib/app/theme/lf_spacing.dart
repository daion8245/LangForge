import 'package:flutter/material.dart';

@immutable
class LfSpacing extends ThemeExtension<LfSpacing> {
  const LfSpacing({
    required this.space1,
    required this.space2,
    required this.space3,
    required this.space4,
    required this.space5,
    required this.space6,
    required this.space7,
    required this.space8,
    required this.space9,
    required this.space10,
    required this.space11,
    required this.space12,
  });

  final double space1; // 2px
  final double space2; // 5px
  final double space3; // 6px
  final double space4; // 7px
  final double space5; // 9px
  final double space6; // 11px
  final double space7; // 14px
  final double space8; // 16px
  final double space9; // 18px
  final double space10; // 24px
  final double space11; // 30px
  final double space12; // 44px

  static const standard = LfSpacing(
    space1: 2,
    space2: 5,
    space3: 6,
    space4: 7,
    space5: 9,
    space6: 11,
    space7: 14,
    space8: 16,
    space9: 18,
    space10: 24,
    space11: 30,
    space12: 44,
  );

  @override
  LfSpacing copyWith({
    double? space1,
    double? space2,
    double? space3,
    double? space4,
    double? space5,
    double? space6,
    double? space7,
    double? space8,
    double? space9,
    double? space10,
    double? space11,
    double? space12,
  }) {
    return LfSpacing(
      space1: space1 ?? this.space1,
      space2: space2 ?? this.space2,
      space3: space3 ?? this.space3,
      space4: space4 ?? this.space4,
      space5: space5 ?? this.space5,
      space6: space6 ?? this.space6,
      space7: space7 ?? this.space7,
      space8: space8 ?? this.space8,
      space9: space9 ?? this.space9,
      space10: space10 ?? this.space10,
      space11: space11 ?? this.space11,
      space12: space12 ?? this.space12,
    );
  }

  @override
  LfSpacing lerp(ThemeExtension<LfSpacing>? other, double t) {
    if (other is! LfSpacing) return this;
    return LfSpacing(
      space1: lerpDouble(space1, other.space1, t),
      space2: lerpDouble(space2, other.space2, t),
      space3: lerpDouble(space3, other.space3, t),
      space4: lerpDouble(space4, other.space4, t),
      space5: lerpDouble(space5, other.space5, t),
      space6: lerpDouble(space6, other.space6, t),
      space7: lerpDouble(space7, other.space7, t),
      space8: lerpDouble(space8, other.space8, t),
      space9: lerpDouble(space9, other.space9, t),
      space10: lerpDouble(space10, other.space10, t),
      space11: lerpDouble(space11, other.space11, t),
      space12: lerpDouble(space12, other.space12, t),
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
