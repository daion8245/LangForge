import 'package:flutter/material.dart';

/// Design tokens. See `docs/design-system.md`.
///
/// Feature code reaches these through `context.c` / `context.t` and never
/// writes a raw `Color(0x…)` or a bare pixel number.
@immutable
class LFColors {
  const LFColors._({
    required this.ember,
    required this.emberDim,
    required this.onEmber,
    required this.mint,
    required this.mintDim,
    required this.crimson,
    required this.crimsonDim,
    required this.gold,
    required this.ink,
    required this.inkMuted,
    required this.surface,
    required this.canvas,
    required this.hairline,
  });

  /// Primary. CTAs, active nav, progress fill. Never signals success.
  final Color ember;
  final Color emberDim;
  final Color onEmber;

  /// Correct answers only.
  final Color mint;
  final Color mintDim;

  /// Wrong answers, heart loss.
  final Color crimson;
  final Color crimsonDim;

  /// XP, streak, achievements.
  final Color gold;

  final Color ink;
  final Color inkMuted;
  final Color surface;
  final Color canvas;
  final Color hairline;

  static const LFColors light = LFColors._(
    ember: Color(0xFFF0603A),
    emberDim: Color(0xFFFDEDE8),
    onEmber: Color(0xFFFFFFFF),
    mint: Color(0xFF12A87A),
    mintDim: Color(0xFFE4F6F0),
    crimson: Color(0xFFD93A3F),
    crimsonDim: Color(0xFFFCEAEA),
    gold: Color(0xFFE0A008),
    ink: Color(0xFF16181D),
    inkMuted: Color(0xFF6B7280),
    surface: Color(0xFFFFFFFF),
    canvas: Color(0xFFFBF8F5),
    hairline: Color(0xFFE6E2DD),
  );

  static const LFColors dark = LFColors._(
    ember: Color(0xFFFF7A55),
    emberDim: Color(0xFF3A241D),
    onEmber: Color(0xFF131418),
    mint: Color(0xFF2DD4A7),
    mintDim: Color(0xFF12312A),
    crimson: Color(0xFFF2686C),
    crimsonDim: Color(0xFF3A1D1F),
    gold: Color(0xFFFFC53D),
    ink: Color(0xFFF4F5F7),
    inkMuted: Color(0xFF9AA1AD),
    surface: Color(0xFF1C1E24),
    canvas: Color(0xFF131418),
    hairline: Color(0xFF2C2F37),
  );

  static LFColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

/// Spacing scale. Screen gutter is [lg]; section rhythm is [xl].
abstract final class LFSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Corner radii. Cards and tiles use [lg]; buttons and chips use [pill].
abstract final class LFRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
}

/// Motion durations, mirrored from `docs/design-system.md`.
abstract final class LFMotion {
  static const Duration tile = Duration(milliseconds: 120);
  static const Duration feedback = Duration(milliseconds: 220);
  static const Duration progress = Duration(milliseconds: 240);
  static const Duration pulse = Duration(milliseconds: 1600);
  static const Duration countUp = Duration(milliseconds: 900);
}

/// Pre-coloured text styles, so feature code never re-applies ink by hand.
@immutable
class LFTypography {
  const LFTypography._(this._c);

  final LFColors _c;

  static LFTypography of(BuildContext context) =>
      LFTypography._(LFColors.of(context));

  TextStyle get display => TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.1,
    color: _c.ink,
  );

  TextStyle get title => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: _c.ink,
  );

  TextStyle get subtitle => TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: _c.ink,
  );

  TextStyle get body => TextStyle(fontSize: 15, height: 1.45, color: _c.ink);

  TextStyle get bodyMuted =>
      TextStyle(fontSize: 15, height: 1.45, color: _c.inkMuted);

  TextStyle get label => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: _c.ink,
  );

  TextStyle get labelMuted => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: _c.inkMuted,
  );

  /// Target-language tokens. Never smaller than [subtitle] weight — the
  /// learner is decoding unfamiliar glyphs.
  TextStyle get target => TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: _c.ink,
  );

  TextStyle get targetLarge => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: _c.ink,
  );
}

extension LFThemeAccess on BuildContext {
  /// Design-system colours for the current brightness.
  LFColors get c => LFColors.of(this);

  /// Pre-coloured text styles.
  LFTypography get t => LFTypography.of(this);
}

ThemeData buildTheme(Brightness brightness) {
  final c = brightness == Brightness.dark ? LFColors.dark : LFColors.light;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: LFColors.light.ember,
        brightness: brightness,
      ).copyWith(
        primary: c.ember,
        onPrimary: c.onEmber,
        surface: c.surface,
        onSurface: c.ink,
        error: c.crimson,
      );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.canvas,
    splashFactory: InkSparkle.splashFactory,
    dividerColor: c.hairline,
    iconTheme: IconThemeData(color: c.ink),
    appBarTheme: AppBarTheme(
      backgroundColor: c.canvas,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: c.ink,
    ),
  );
}
