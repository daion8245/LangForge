import 'package:flutter/material.dart';
import 'lf_colors.dart';
import 'lf_radii.dart';
import 'lf_sizes.dart';
import 'lf_spacing.dart';
import 'lf_typography.dart';

extension LfThemeContextExtension on BuildContext {
  LfColors get c => Theme.of(this).extension<LfColors>() ?? LfColors.dark;
  LfSpacing get s =>
      Theme.of(this).extension<LfSpacing>() ?? LfSpacing.standard;
  LfRadii get r => Theme.of(this).extension<LfRadii>() ?? LfRadii.standard;
  LfTypography get t =>
      Theme.of(this).extension<LfTypography>() ?? LfTypography.standard;

  /// Fixed dimensions and breakpoints — DESIGN.md 5.5.
  LfSizes get d => Theme.of(this).extension<LfSizes>() ?? LfSizes.standard;

  /// True when the OS asks for reduced motion (TECHNICAL.md 15).
  ///
  /// Animations are skipped rather than shortened: the app has no animation
  /// that carries meaning on its own.
  bool get prefersReducedMotion => MediaQuery.disableAnimationsOf(this);
}
