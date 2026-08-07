import 'package:flutter/material.dart';

import 'theme.dart';

/// Visual state shared by option rows, word-bank tokens and match tiles.
enum LFAnswerState { idle, selected, correct, wrong }

/// Fill/border/text colours for an answer surface in a given state.
@immutable
class LFAnswerPalette {
  const LFAnswerPalette({
    required this.fill,
    required this.border,
    required this.text,
  });

  final Color fill;
  final Color border;
  final Color text;

  factory LFAnswerPalette.of(BuildContext context, LFAnswerState state) {
    final c = context.c;
    return switch (state) {
      LFAnswerState.idle => LFAnswerPalette(
        fill: c.surface,
        border: c.hairline,
        text: c.ink,
      ),
      LFAnswerState.selected => LFAnswerPalette(
        fill: c.emberDim,
        border: c.ember,
        text: c.ink,
      ),
      LFAnswerState.correct => LFAnswerPalette(
        fill: c.mintDim,
        border: c.mint,
        text: c.ink,
      ),
      LFAnswerState.wrong => LFAnswerPalette(
        fill: c.crimsonDim,
        border: c.crimson,
        text: c.ink,
      ),
    };
  }
}

enum LFButtonTone { ember, mint, crimson, neutral }

/// The primary action control. Fixed 52pt height so the lesson action bar
/// never shifts between states.
class LFButton extends StatelessWidget {
  const LFButton({
    required this.label,
    required this.onPressed,
    this.tone = LFButtonTone.ember,
    this.expand = true,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final LFButtonTone tone;
  final bool expand;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final enabled = onPressed != null;
    final (Color fill, Color fg) = switch (tone) {
      LFButtonTone.ember => (c.ember, c.onEmber),
      LFButtonTone.mint => (c.mint, c.onEmber),
      LFButtonTone.crimson => (c.crimson, c.onEmber),
      LFButtonTone.neutral => (c.surface, c.ink),
    };

    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: enabled ? fg : c.inkMuted),
          const SizedBox(width: LFSpace.sm),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: enabled ? fg : c.inkMuted,
          ),
        ),
      ],
    );

    return SizedBox(
      height: 52,
      width: expand ? double.infinity : null,
      child: Material(
        color: enabled ? fill : c.hairline,
        borderRadius: BorderRadius.circular(LFRadius.pill),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: LFSpace.xl),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

/// Rounded progress track. Animates over [LFMotion.progress].
class LFProgressBar extends StatelessWidget {
  const LFProgressBar({
    required this.value,
    this.height = 8,
    this.color,
    super.key,
  });

  final double value;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ClipRRect(
      borderRadius: BorderRadius.circular(LFRadius.pill),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: c.hairline)),
            LayoutBuilder(
              builder: (context, constraints) => AnimatedContainer(
                duration: LFMotion.progress,
                curve: Curves.easeOutCubic,
                width: constraints.maxWidth * value.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  color: color ?? c.ember,
                  borderRadius: BorderRadius.circular(LFRadius.pill),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Five bars showing a Vault entry's strength. Strength 0 shows the first
/// bar in crimson so decay is legible at a glance.
class LFStrengthMeter extends StatelessWidget {
  const LFStrengthMeter({required this.strength, this.max = 5, super.key});

  final int strength;
  final int max;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < max; i++)
          Padding(
            padding: EdgeInsets.only(right: i == max - 1 ? 0 : 3),
            child: Container(
              width: 10,
              height: 3,
              decoration: BoxDecoration(
                color: i < strength
                    ? c.ember
                    : (strength == 0 && i == 0 ? c.crimson : c.hairline),
                borderRadius: BorderRadius.circular(LFRadius.pill),
              ),
            ),
          ),
      ],
    );
  }
}

/// Surface container used for cards and sheets.
class LFCard extends StatelessWidget {
  const LFCard({
    required this.child,
    this.padding = const EdgeInsets.all(LFSpace.lg),
    this.onTap,
    this.borderColor,
    this.fill,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Material(
      color: fill ?? c.surface,
      borderRadius: BorderRadius.circular(LFRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor ?? c.hairline),
            borderRadius: BorderRadius.circular(LFRadius.lg),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Small rounded label — counts, "coming soon", parts of speech.
class LFPill extends StatelessWidget {
  const LFPill({
    required this.label,
    this.color,
    this.background,
    this.icon,
    super.key,
  });

  final String label;
  final Color? color;
  final Color? background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final fg = color ?? c.inkMuted;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LFSpace.md,
        vertical: LFSpace.xs + 2,
      ),
      decoration: BoxDecoration(
        color: background ?? c.hairline.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(LFRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: LFSpace.xs + 2),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// A number with a caption, used on the Profile grid and completion screen.
class LFStatTile extends StatelessWidget {
  const LFStatTile({
    required this.icon,
    required this.value,
    required this.label,
    this.accent,
    super.key,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final tint = accent ?? c.ember;
    return LFCard(
      padding: const EdgeInsets.symmetric(
        horizontal: LFSpace.md,
        vertical: LFSpace.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: tint),
          const SizedBox(height: LFSpace.md),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: c.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: context.t.labelMuted),
        ],
      ),
    );
  }
}

/// Section heading with an optional trailing widget.
class LFSectionHeader extends StatelessWidget {
  const LFSectionHeader({required this.title, this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: context.t.subtitle)),
        ?trailing,
      ],
    );
  }
}

/// Centred illustration + copy for empty lists.
class LFEmptyState extends StatelessWidget {
  const LFEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LFSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: c.hairline.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: c.inkMuted),
            ),
            const SizedBox(height: LFSpace.lg),
            Text(title, style: context.t.subtitle),
            const SizedBox(height: LFSpace.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.t.bodyMuted,
            ),
            if (action != null) ...[
              const SizedBox(height: LFSpace.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
