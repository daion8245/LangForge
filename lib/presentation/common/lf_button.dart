import 'package:flutter/material.dart';

import '../../app/theme/lf_colors.dart';
import '../../app/theme/lf_radii.dart';
import '../../app/theme/lf_sizes.dart';
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

    final sizes = context.d;
    final spec = _LfButtonSpec.of(widget.style, colors, radii, sizes);
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
            width: sizes.iconMd,
            height: sizes.iconMd,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foreground),
            ),
          )
        else if (widget.icon != null)
          IconTheme(
            data: IconThemeData(color: foreground, size: sizes.iconMd),
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

    // Merged so a reader announces one control, not a labelled wrapper and an
    // unlabelled tap target (TECHNICAL.md 15).
    Widget button = MergeSemantics(
      child: Semantics(
        button: true,
        enabled: _enabled,
        // An icon-only button has no visible text, so the tooltip is the only
        // thing a screen reader can read out (DESIGN.md 14 · TECHNICAL.md 15).
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
                    constraints: BoxConstraints(
                      minWidth: sizes.minTapTarget,
                      minHeight: sizes.minTapTarget,
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
                        width: focused ? sizes.borderThick : sizes.borderThin,
                      ),
                    ),
                    child: content,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        // The Semantics above already carries the label; letting the tooltip
        // add a second node would make readers say it twice.
        excludeFromSemantics: true,
        child: button,
      );
    }
    return button;
  }
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

  static _LfButtonSpec of(
    LfButtonStyle style,
    LfColors colors,
    LfRadii radii,
    LfSizes sizes,
  ) {
    switch (style) {
      case LfButtonStyle.primary:
        return _LfButtonSpec(
          height: sizes.buttonPrimary,
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
          height: sizes.buttonSecondary,
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
          height: sizes.buttonTertiary,
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
          height: sizes.buttonDanger,
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
          height: sizes.buttonSecondary,
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
