import 'package:flutter/material.dart';

import '../../../app/theme/theme_extensions.dart';

/// Common frame for the three bottom sheets of ROADMAP 13.3 — MOBILE.md 2.3.
///
/// Drawn inside the shell's [Stack] rather than pushed with
/// `showModalBottomSheet` so it stays inside the phone frame, the scrim covers
/// exactly the app area, and the bottom tab bar keeps its own paint order.
class MobileSheetSurface extends StatelessWidget {
  const MobileSheetSurface({
    super.key,
    required this.child,
    this.fillFromTop = false,
    this.padded = true,
  });

  final Widget child;

  /// The 설정 sheet is pinned [LfMobileSizes.sheetTopInset] from the top and
  /// scrolls inside itself; the other two size to their content.
  final bool fillFromTop;

  /// The 설정 sheet supplies its own padding because its header is pinned and
  /// its body scrolls.
  final bool padded;

  static const Duration _rise = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final spacing = context.s;
    final sizes = context.m;

    final surface = Container(
      decoration: BoxDecoration(
        color: colors.bgBar,
        border: Border(
          top: BorderSide(
            color: colors.borderControl,
            width: context.d.borderThin,
          ),
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(spacing.space10 - 2),
        ),
      ),
      padding: padded
          ? EdgeInsets.fromLTRB(
              spacing.space9,
              spacing.space2 * 2,
              spacing.space9,
              spacing.space11 - 4,
            )
          : EdgeInsets.zero,
      child: child,
    );

    final panel = Material(
      color: Colors.transparent,
      child: SafeArea(top: false, child: surface),
    );

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      top: fillFromTop ? sizes.sheetTopInset : null,
      // The mockup's `animation: lf-up .2s cubic-bezier(.2,.8,.2,1)`.
      child: context.prefersReducedMotion
          ? panel
          : TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 1, end: 0),
              duration: _rise,
              curve: const Cubic(0.2, 0.8, 0.2, 1),
              builder: (context, value, child) => FractionalTranslation(
                translation: Offset(0, value),
                child: child,
              ),
              child: panel,
            ),
    );
  }
}

/// The 38×4 grab handle every sheet carries.
class MobileSheetHandle extends StatelessWidget {
  const MobileSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final sizes = context.m;
    return Center(
      child: Container(
        width: sizes.sheetHandleW,
        height: sizes.sheetHandleH,
        decoration: BoxDecoration(
          color: context.c.borderHover,
          borderRadius: context.r.xs,
        ),
      ),
    );
  }
}

/// Dimmed backdrop. Tapping it closes the sheet.
class MobileSheetScrim extends StatelessWidget {
  const MobileSheetScrim({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Semantics(
        label: '시트 닫기',
        button: true,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: ColoredBox(color: context.c.bgScrim),
        ),
      ),
    );
  }
}
