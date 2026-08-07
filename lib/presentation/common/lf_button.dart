import 'package:flutter/material.dart';

import '../../app/theme/lf_colors.dart';
import '../../app/theme/lf_radii.dart';
import '../../app/theme/theme_extensions.dart';

/// Button kinds from DESIGN.md 7.1. Each kind fixes its own height, radius and
/// colour pair — callers pick a kind, never a size.
enum LfButtonStyle {
  /// Start translation, export. One per screen.
  primary,

  /// File menu, connection test.
  secondary,

  /// View switches, filters.
  tertiary,

  /// Retry failed entries.
  danger,

  /// Square icon-only control, e.g. the settings gear.
  icon,
}

class LfButton extends StatefulWidget {
  const LfButton({
    super.key,
    required this.onPressed,
    this.label,
    this.icon,
    this.style = LfButtonStyle.secondary,
    this.tooltip,
    this.isLoading = false,
    this.loadingLabel,
  }) : assert(
         label != null || icon != null,
         'LfButton must have a label or an icon',
       ),
       assert(
         label != null || tooltip != null,
         'An icon-only button needs a tooltip (DESIGN.md 8.3)',
       );

  final VoidCallback? onPressed;
  final String? label;
  final Widget? icon;
  final LfButtonStyle style;

  /// Required when there is no visible label. Also used to explain why the
  /// button is disabled.
  final String? tooltip;
  final bool isLoading;

  /// Replaces [label] while loading, e.g. '번역 진행 중…'.
  final String? loadingLabel;

  @override
  State<LfButton> createState() => _LfButtonState();
}

class _LfButtonState extends State<LfButton> {
  bool _hovered = false;
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final radii = context.r;
    final spacing = context.s;
    final typography = context.t;

    final spec = _LfButtonSpec.of(widget.style, colors, radii);
    final isIconOnly = widget.label == null;

    Color background = spec.background;
    Color border = spec.border;
    Color foreground = spec.foreground;

    if (widget.isLoading) {
      background = colors.loadingSurface;
      border = Colors.transparent;
      foreground = colors.loadingText;
    } else if (!_enabled) {
      background = colors.bgDisabled;
      border = spec.border == Colors.transparent
          ? Colors.transparent
          : colors.borderControl;
      foreground = colors.textDisabled;
    } else if (_pressed) {
      background = Color.alphaBlend(
        colors.bgScrim.withValues(alpha: 0.18),
        background,
      );
    } else if (_hovered) {
      background = spec.hoverBackground;
      border = spec.hoverBorder;
    }

    final labelText = widget.isLoading
        ? (widget.loadingLabel ?? widget.label)
        : widget.label;

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          SizedBox(
            width: _iconSize,
            height: _iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foreground),
            ),
          )
        else if (widget.icon != null)
          IconTheme(
            data: IconThemeData(color: foreground, size: _iconSize),
            child: widget.icon!,
          ),
        if (labelText != null) ...[
          if (widget.isLoading || widget.icon != null)
            SizedBox(width: spacing.space4),
          Text(
            labelText,
            style: typography.bodySm.copyWith(
              color: foreground,
              fontWeight: spec.fontWeight,
            ),
          ),
        ],
      ],
    );

    Widget button = Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label ?? widget.tooltip,
      child: Focus(
        canRequestFocus: _enabled,
        child: Builder(
          builder: (context) {
            final focused = Focus.of(context).hasFocus;
            return MouseRegion(
              cursor: _enabled
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.basic,
              onEnter: (_) => setState(() => _hovered = true),
              onExit: (_) => setState(() => _hovered = false),
              child: GestureDetector(
                onTapDown: _enabled
                    ? (_) => setState(() => _pressed = true)
                    : null,
                onTapCancel: _enabled
                    ? () => setState(() => _pressed = false)
                    : null,
                onTapUp: _enabled
                    ? (_) => setState(() => _pressed = false)
                    : null,
                onTap: _enabled ? widget.onPressed : null,
                child: AnimatedContainer(
                  duration: _pressed
                      ? Duration.zero
                      : const Duration(milliseconds: 150),
                  height: spec.height,
                  width: isIconOnly && widget.style == LfButtonStyle.icon
                      ? spec.height
                      : null,
                  constraints: const BoxConstraints(
                    minWidth: _minTouchTarget,
                    minHeight: _minTouchTarget,
                  ),
                  alignment: Alignment.center,
                  padding: widget.style == LfButtonStyle.icon
                      // The square already centres the glyph; padding on top of
                      // a fixed width would squeeze it.
                      ? EdgeInsets.zero
                      : EdgeInsets.symmetric(
                          horizontal: isIconOnly
                              ? spacing.space4
                              : spacing.space6,
                        ),
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: spec.radius,
                    border: Border.all(
                      color: focused ? colors.accent : border,
                      width: focused ? _focusRingWidth : _borderWidth,
                    ),
                  ),
                  child: content,
                ),
              ),
            );
          },
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }

  /// DESIGN.md 8.1 — icons render at 16px inside controls.
  static const double _iconSize = 16;

  /// DESIGN.md 3 — click targets are never smaller than 24×24.
  static const double _minTouchTarget = 24;

  /// DESIGN.md 5.4 — every control border is 1px; focus uses a 2px accent ring.
  static const double _borderWidth = 1;
  static const double _focusRingWidth = 2;
}

/// Per-kind geometry and colours, straight from the DESIGN.md 7.1 table.
class _LfButtonSpec {
  const _LfButtonSpec({
    required this.height,
    required this.radius,
    required this.background,
    required this.hoverBackground,
    required this.border,
    required this.hoverBorder,
    required this.foreground,
    required this.fontWeight,
  });

  final double height;
  final BorderRadius radius;
  final Color background;
  final Color hoverBackground;
  final Color border;
  final Color hoverBorder;
  final Color foreground;
  final FontWeight fontWeight;

  static _LfButtonSpec of(LfButtonStyle style, LfColors colors, LfRadii radii) {
    switch (style) {
      case LfButtonStyle.primary:
        return _LfButtonSpec(
          height: 38,
          radius: radii.r2xl,
          background: colors.accent,
          hoverBackground: colors.accentHover,
          border: Colors.transparent,
          hoverBorder: Colors.transparent,
          foreground: colors.accentOn,
          fontWeight: FontWeight.w600,
        );
      case LfButtonStyle.secondary:
        return _LfButtonSpec(
          height: 28,
          radius: radii.lg,
          background: colors.bgRaised,
          hoverBackground: colors.bgRaisedHover,
          border: colors.borderControl,
          hoverBorder: colors.borderHover,
          foreground: colors.textStrong,
          fontWeight: FontWeight.w500,
        );
      case LfButtonStyle.tertiary:
        return _LfButtonSpec(
          height: 25,
          radius: radii.md,
          background: Colors.transparent,
          hoverBackground: colors.bgRaised,
          border: Colors.transparent,
          hoverBorder: Colors.transparent,
          foreground: colors.textTertiary,
          fontWeight: FontWeight.w400,
        );
      case LfButtonStyle.danger:
        return _LfButtonSpec(
          height: 32,
          radius: radii.xl,
          background: colors.dangerSurface,
          hoverBackground: colors.dangerSurface,
          border: colors.dangerBorder,
          hoverBorder: colors.danger,
          foreground: colors.dangerText,
          fontWeight: FontWeight.w500,
        );
      case LfButtonStyle.icon:
        return _LfButtonSpec(
          height: 28,
          radius: radii.lg,
          background: colors.bgRaised,
          hoverBackground: colors.bgRaisedHover,
          border: colors.borderControl,
          hoverBorder: colors.borderHover,
          foreground: colors.textSecondary,
          fontWeight: FontWeight.w400,
        );
    }
  }
}
