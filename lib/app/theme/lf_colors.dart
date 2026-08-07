import 'package:flutter/material.dart';

@immutable
class LfColors extends ThemeExtension<LfColors> {
  const LfColors({
    required this.bgBase,
    required this.bgSurface,
    required this.bgBar,
    required this.bgRaised,
    required this.bgRaisedHover,
    required this.bgOverlay,
    required this.bgSelected,
    required this.bgTabActive,
    required this.bgInputAlt,
    required this.bgDisabled,
    required this.bgScrim,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderPanel,
    required this.borderControl,
    required this.borderStrong,
    required this.borderHover,
    required this.borderDashed,
    required this.borderAccent,
    required this.textPrimary,
    required this.textStrong,
    required this.textSecondary,
    required this.textTertiary,
    required this.textMuted,
    required this.textFaint,
    required this.textDisabled,
    required this.accent,
    required this.accentOn,
    required this.accentHover,
    required this.danger,
    required this.dangerText,
    required this.dangerSurface,
    required this.dangerBorder,
    required this.warning,
    required this.info,
    required this.special,
    required this.successText,
    required this.successSurface,
    required this.successBorder,
    required this.loadingSurface,
    required this.loadingText,
    required this.statusWaitFg,
    required this.statusWaitBg,
    required this.statusRunningFg,
    required this.statusRunningBg,
    required this.statusDoneFg,
    required this.statusDoneBg,
    required this.statusKeptFg,
    required this.statusKeptBg,
    required this.statusCacheFg,
    required this.statusCacheBg,
    required this.statusInvalidFg,
    required this.statusInvalidBg,
    required this.statusFallbackFg,
    required this.statusFallbackBg,
    required this.statusConfirmFg,
    required this.statusConfirmBg,
    required this.statusEmptyFg,
    required this.statusEmptyBg,
  });

  final Color bgBase;
  final Color bgSurface;
  final Color bgBar;
  final Color bgRaised;
  final Color bgRaisedHover;
  final Color bgOverlay;
  final Color bgSelected;
  final Color bgTabActive;
  final Color bgInputAlt;
  final Color bgDisabled;
  final Color bgScrim;

  final Color borderSubtle;
  final Color borderDefault;
  final Color borderPanel;
  final Color borderControl;
  final Color borderStrong;
  final Color borderHover;
  final Color borderDashed;
  final Color borderAccent;

  final Color textPrimary;
  final Color textStrong;
  final Color textSecondary;
  final Color textTertiary;
  final Color textMuted;
  final Color textFaint;
  final Color textDisabled;

  final Color accent;
  final Color accentOn;
  final Color accentHover;
  final Color danger;
  final Color dangerText;
  final Color dangerSurface;
  final Color dangerBorder;
  final Color warning;
  final Color info;
  final Color special;
  final Color successText;
  final Color successSurface;
  final Color successBorder;
  final Color loadingSurface;
  final Color loadingText;

  final Color statusWaitFg;
  final Color statusWaitBg;
  final Color statusRunningFg;
  final Color statusRunningBg;
  final Color statusDoneFg;
  final Color statusDoneBg;
  final Color statusKeptFg;
  final Color statusKeptBg;
  final Color statusCacheFg;
  final Color statusCacheBg;
  final Color statusInvalidFg;
  final Color statusInvalidBg;
  final Color statusFallbackFg;
  final Color statusFallbackBg;
  final Color statusConfirmFg;
  final Color statusConfirmBg;
  final Color statusEmptyFg;
  final Color statusEmptyBg;

  static const dark = LfColors(
    bgBase: Color(0xFF161616),
    bgSurface: Color(0xFF1B1B1B),
    bgBar: Color(0xFF1E1E1E),
    bgRaised: Color(0xFF242424),
    bgRaisedHover: Color(0xFF2C2C2C),
    bgOverlay: Color(0xFF252525),
    bgSelected: Color(0xFF2B2B2B),
    bgTabActive: Color(0xFF181818),
    bgInputAlt: Color(0xFF1F1F1F),
    bgDisabled: Color(0xFF2A2A2A),
    bgScrim: Color(0xB30A0A0A),

    borderSubtle: Color(0xFF202020),
    borderDefault: Color(0xFF262626),
    borderPanel: Color(0xFF272727),
    borderControl: Color(0xFF333333),
    borderStrong: Color(0xFF383838),
    borderHover: Color(0xFF3D3D3D),
    borderDashed: Color(0xFF3A3A3A),
    borderAccent: Color(0xFF3D4F4A),

    textPrimary: Color(0xFFF3F3F3),
    textStrong: Color(0xFFE8E8E8),
    textSecondary: Color(0xFFC0C0C0),
    textTertiary: Color(0xFF9A9A9A),
    textMuted: Color(0xFF8A8A8A),
    textFaint: Color(0xFF7A7A7A),
    textDisabled: Color(0xFF6F6F6F),

    accent: Color(0xFF4FC0A1),
    accentOn: Color(0xFF10231E),
    accentHover: Color(0xFF79DCC1),
    danger: Color(0xFFE0876F),
    dangerText: Color(0xFFE0A893),
    dangerSurface: Color(0xFF2A1C19),
    dangerBorder: Color(0xFF4A2D27),
    warning: Color(0xFFD9B25F),
    info: Color(0xFF7FB4D9),
    special: Color(0xFFA99AD6),
    successText: Color(0xFF9FD5C3),
    successSurface: Color(0xFF1C2422),
    successBorder: Color(0xFF2C3A35),
    loadingSurface: Color(0xFF2F3F3A),
    loadingText: Color(0xFF8FC9B8),

    statusWaitFg: Color(0xFF868686),
    statusWaitBg: Color(0x0FFFFFFF),
    statusRunningFg: Color(0xFF7FB4D9),
    statusRunningBg: Color(0x247FB4D9),
    statusDoneFg: Color(0xFF4FC0A1),
    statusDoneBg: Color(0x214FC0A1),
    statusKeptFg: Color(0xFF7FB4D9),
    statusKeptBg: Color(0x1F7FB4D9),
    statusCacheFg: Color(0xFFA99AD6),
    statusCacheBg: Color(0x21A99AD6),
    statusInvalidFg: Color(0xFFE0876F),
    statusInvalidBg: Color(0x24E0876F),
    statusFallbackFg: Color(0xFFD9B25F),
    statusFallbackBg: Color(0x21D9B25F),
    statusConfirmFg: Color(0xFFD9B25F),
    statusConfirmBg: Color(0x21D9B25F),
    statusEmptyFg: Color(0xFF868686),
    statusEmptyBg: Color(0x0FFFFFFF),
  );

  @override
  LfColors copyWith({
    Color? bgBase,
    Color? bgSurface,
    Color? bgBar,
    Color? bgRaised,
    Color? bgRaisedHover,
    Color? bgOverlay,
    Color? bgSelected,
    Color? bgTabActive,
    Color? bgInputAlt,
    Color? bgDisabled,
    Color? bgScrim,
    Color? borderSubtle,
    Color? borderDefault,
    Color? borderPanel,
    Color? borderControl,
    Color? borderStrong,
    Color? borderHover,
    Color? borderDashed,
    Color? borderAccent,
    Color? textPrimary,
    Color? textStrong,
    Color? textSecondary,
    Color? textTertiary,
    Color? textMuted,
    Color? textFaint,
    Color? textDisabled,
    Color? accent,
    Color? accentOn,
    Color? accentHover,
    Color? danger,
    Color? dangerText,
    Color? dangerSurface,
    Color? dangerBorder,
    Color? warning,
    Color? info,
    Color? special,
    Color? successText,
    Color? successSurface,
    Color? successBorder,
    Color? loadingSurface,
    Color? loadingText,
    Color? statusWaitFg,
    Color? statusWaitBg,
    Color? statusRunningFg,
    Color? statusRunningBg,
    Color? statusDoneFg,
    Color? statusDoneBg,
    Color? statusKeptFg,
    Color? statusKeptBg,
    Color? statusCacheFg,
    Color? statusCacheBg,
    Color? statusInvalidFg,
    Color? statusInvalidBg,
    Color? statusFallbackFg,
    Color? statusFallbackBg,
    Color? statusConfirmFg,
    Color? statusConfirmBg,
    Color? statusEmptyFg,
    Color? statusEmptyBg,
  }) {
    return LfColors(
      bgBase: bgBase ?? this.bgBase,
      bgSurface: bgSurface ?? this.bgSurface,
      bgBar: bgBar ?? this.bgBar,
      bgRaised: bgRaised ?? this.bgRaised,
      bgRaisedHover: bgRaisedHover ?? this.bgRaisedHover,
      bgOverlay: bgOverlay ?? this.bgOverlay,
      bgSelected: bgSelected ?? this.bgSelected,
      bgTabActive: bgTabActive ?? this.bgTabActive,
      bgInputAlt: bgInputAlt ?? this.bgInputAlt,
      bgDisabled: bgDisabled ?? this.bgDisabled,
      bgScrim: bgScrim ?? this.bgScrim,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderDefault: borderDefault ?? this.borderDefault,
      borderPanel: borderPanel ?? this.borderPanel,
      borderControl: borderControl ?? this.borderControl,
      borderStrong: borderStrong ?? this.borderStrong,
      borderHover: borderHover ?? this.borderHover,
      borderDashed: borderDashed ?? this.borderDashed,
      borderAccent: borderAccent ?? this.borderAccent,
      textPrimary: textPrimary ?? this.textPrimary,
      textStrong: textStrong ?? this.textStrong,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textMuted: textMuted ?? this.textMuted,
      textFaint: textFaint ?? this.textFaint,
      textDisabled: textDisabled ?? this.textDisabled,
      accent: accent ?? this.accent,
      accentOn: accentOn ?? this.accentOn,
      accentHover: accentHover ?? this.accentHover,
      danger: danger ?? this.danger,
      dangerText: dangerText ?? this.dangerText,
      dangerSurface: dangerSurface ?? this.dangerSurface,
      dangerBorder: dangerBorder ?? this.dangerBorder,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      special: special ?? this.special,
      successText: successText ?? this.successText,
      successSurface: successSurface ?? this.successSurface,
      successBorder: successBorder ?? this.successBorder,
      loadingSurface: loadingSurface ?? this.loadingSurface,
      loadingText: loadingText ?? this.loadingText,
      statusWaitFg: statusWaitFg ?? this.statusWaitFg,
      statusWaitBg: statusWaitBg ?? this.statusWaitBg,
      statusRunningFg: statusRunningFg ?? this.statusRunningFg,
      statusRunningBg: statusRunningBg ?? this.statusRunningBg,
      statusDoneFg: statusDoneFg ?? this.statusDoneFg,
      statusDoneBg: statusDoneBg ?? this.statusDoneBg,
      statusKeptFg: statusKeptFg ?? this.statusKeptFg,
      statusKeptBg: statusKeptBg ?? this.statusKeptBg,
      statusCacheFg: statusCacheFg ?? this.statusCacheFg,
      statusCacheBg: statusCacheBg ?? this.statusCacheBg,
      statusInvalidFg: statusInvalidFg ?? this.statusInvalidFg,
      statusInvalidBg: statusInvalidBg ?? this.statusInvalidBg,
      statusFallbackFg: statusFallbackFg ?? this.statusFallbackFg,
      statusFallbackBg: statusFallbackBg ?? this.statusFallbackBg,
      statusConfirmFg: statusConfirmFg ?? this.statusConfirmFg,
      statusConfirmBg: statusConfirmBg ?? this.statusConfirmBg,
      statusEmptyFg: statusEmptyFg ?? this.statusEmptyFg,
      statusEmptyBg: statusEmptyBg ?? this.statusEmptyBg,
    );
  }

  @override
  LfColors lerp(ThemeExtension<LfColors>? other, double t) {
    if (other is! LfColors) return this;
    return LfColors(
      bgBase: Color.lerp(bgBase, other.bgBase, t)!,
      bgSurface: Color.lerp(bgSurface, other.bgSurface, t)!,
      bgBar: Color.lerp(bgBar, other.bgBar, t)!,
      bgRaised: Color.lerp(bgRaised, other.bgRaised, t)!,
      bgRaisedHover: Color.lerp(bgRaisedHover, other.bgRaisedHover, t)!,
      bgOverlay: Color.lerp(bgOverlay, other.bgOverlay, t)!,
      bgSelected: Color.lerp(bgSelected, other.bgSelected, t)!,
      bgTabActive: Color.lerp(bgTabActive, other.bgTabActive, t)!,
      bgInputAlt: Color.lerp(bgInputAlt, other.bgInputAlt, t)!,
      bgDisabled: Color.lerp(bgDisabled, other.bgDisabled, t)!,
      bgScrim: Color.lerp(bgScrim, other.bgScrim, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderPanel: Color.lerp(borderPanel, other.borderPanel, t)!,
      borderControl: Color.lerp(borderControl, other.borderControl, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      borderHover: Color.lerp(borderHover, other.borderHover, t)!,
      borderDashed: Color.lerp(borderDashed, other.borderDashed, t)!,
      borderAccent: Color.lerp(borderAccent, other.borderAccent, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textStrong: Color.lerp(textStrong, other.textStrong, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textFaint: Color.lerp(textFaint, other.textFaint, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentOn: Color.lerp(accentOn, other.accentOn, t)!,
      accentHover: Color.lerp(accentHover, other.accentHover, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerText: Color.lerp(dangerText, other.dangerText, t)!,
      dangerSurface: Color.lerp(dangerSurface, other.dangerSurface, t)!,
      dangerBorder: Color.lerp(dangerBorder, other.dangerBorder, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      special: Color.lerp(special, other.special, t)!,
      successText: Color.lerp(successText, other.successText, t)!,
      successSurface: Color.lerp(successSurface, other.successSurface, t)!,
      successBorder: Color.lerp(successBorder, other.successBorder, t)!,
      loadingSurface: Color.lerp(loadingSurface, other.loadingSurface, t)!,
      loadingText: Color.lerp(loadingText, other.loadingText, t)!,
      statusWaitFg: Color.lerp(statusWaitFg, other.statusWaitFg, t)!,
      statusWaitBg: Color.lerp(statusWaitBg, other.statusWaitBg, t)!,
      statusRunningFg: Color.lerp(statusRunningFg, other.statusRunningFg, t)!,
      statusRunningBg: Color.lerp(statusRunningBg, other.statusRunningBg, t)!,
      statusDoneFg: Color.lerp(statusDoneFg, other.statusDoneFg, t)!,
      statusDoneBg: Color.lerp(statusDoneBg, other.statusDoneBg, t)!,
      statusKeptFg: Color.lerp(statusKeptFg, other.statusKeptFg, t)!,
      statusKeptBg: Color.lerp(statusKeptBg, other.statusKeptBg, t)!,
      statusCacheFg: Color.lerp(statusCacheFg, other.statusCacheFg, t)!,
      statusCacheBg: Color.lerp(statusCacheBg, other.statusCacheBg, t)!,
      statusInvalidFg: Color.lerp(statusInvalidFg, other.statusInvalidFg, t)!,
      statusInvalidBg: Color.lerp(statusInvalidBg, other.statusInvalidBg, t)!,
      statusFallbackFg: Color.lerp(
        statusFallbackFg,
        other.statusFallbackFg,
        t,
      )!,
      statusFallbackBg: Color.lerp(
        statusFallbackBg,
        other.statusFallbackBg,
        t,
      )!,
      statusConfirmFg: Color.lerp(statusConfirmFg, other.statusConfirmFg, t)!,
      statusConfirmBg: Color.lerp(statusConfirmBg, other.statusConfirmBg, t)!,
      statusEmptyFg: Color.lerp(statusEmptyFg, other.statusEmptyFg, t)!,
      statusEmptyBg: Color.lerp(statusEmptyBg, other.statusEmptyBg, t)!,
    );
  }
}
