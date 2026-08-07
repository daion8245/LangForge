import 'package:flutter/material.dart';

@immutable
class LfRadii extends ThemeExtension<LfRadii> {
  const LfRadii({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.r2xl,
    required this.r3xl,
    required this.r4xl,
    required this.full,
  });

  final BorderRadius xs; // 4px
  final BorderRadius sm; // 5px
  final BorderRadius md; // 6px
  final BorderRadius lg; // 7px
  final BorderRadius xl; // 8px
  final BorderRadius r2xl; // 9px (default)
  final BorderRadius r3xl; // 12px
  final BorderRadius r4xl; // 16px
  final BorderRadius full; // 999px

  static final standard = LfRadii(
    xs: BorderRadius.circular(4),
    sm: BorderRadius.circular(5),
    md: BorderRadius.circular(6),
    lg: BorderRadius.circular(7),
    xl: BorderRadius.circular(8),
    r2xl: BorderRadius.circular(9),
    r3xl: BorderRadius.circular(12),
    r4xl: BorderRadius.circular(16),
    full: BorderRadius.circular(999),
  );

  @override
  LfRadii copyWith({
    BorderRadius? xs,
    BorderRadius? sm,
    BorderRadius? md,
    BorderRadius? lg,
    BorderRadius? xl,
    BorderRadius? r2xl,
    BorderRadius? r3xl,
    BorderRadius? r4xl,
    BorderRadius? full,
  }) {
    return LfRadii(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      r2xl: r2xl ?? this.r2xl,
      r3xl: r3xl ?? this.r3xl,
      r4xl: r4xl ?? this.r4xl,
      full: full ?? this.full,
    );
  }

  @override
  LfRadii lerp(ThemeExtension<LfRadii>? other, double t) {
    if (other is! LfRadii) return this;
    return LfRadii(
      xs: BorderRadius.lerp(xs, other.xs, t)!,
      sm: BorderRadius.lerp(sm, other.sm, t)!,
      md: BorderRadius.lerp(md, other.md, t)!,
      lg: BorderRadius.lerp(lg, other.lg, t)!,
      xl: BorderRadius.lerp(xl, other.xl, t)!,
      r2xl: BorderRadius.lerp(r2xl, other.r2xl, t)!,
      r3xl: BorderRadius.lerp(r3xl, other.r3xl, t)!,
      r4xl: BorderRadius.lerp(r4xl, other.r4xl, t)!,
      full: BorderRadius.lerp(full, other.full, t)!,
    );
  }
}
