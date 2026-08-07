import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../core/ui.dart';

/// Full-width selectable row, shared by the multiple-choice, listening and
/// fill-blank views.
///
/// Correct/wrong is never signalled by colour alone — a glyph always
/// accompanies it (see `docs/design-system.md`).
class OptionRow extends StatelessWidget {
  const OptionRow({
    required this.label,
    required this.state,
    required this.onTap,
    this.targetLanguage = false,
    super.key,
  });

  final String label;
  final LFAnswerState state;
  final VoidCallback? onTap;

  /// Renders the label in the target-language style.
  final bool targetLanguage;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final palette = LFAnswerPalette.of(context, state);
    final glyph = switch (state) {
      LFAnswerState.correct => (Icons.check_circle_rounded, c.mint),
      LFAnswerState.wrong => (Icons.cancel_rounded, c.crimson),
      _ => null,
    };

    return Semantics(
      button: true,
      selected: state == LFAnswerState.selected,
      child: AnimatedContainer(
        duration: LFMotion.tile,
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: LFSpace.md),
        decoration: BoxDecoration(
          color: palette.fill,
          border: Border.all(color: palette.border, width: 1.5),
          borderRadius: BorderRadius.circular(LFRadius.lg),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(LFRadius.lg),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: LFSpace.lg,
                vertical: LFSpace.lg,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: targetLanguage
                          ? context.t.target
                          : context.t.body.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                    ),
                  ),
                  if (glyph != null) ...[
                    const SizedBox(width: LFSpace.md),
                    Icon(glyph.$1, size: 20, color: glyph.$2),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Visual state for option [index] given the current selection.
///
/// Once locked, the correct option is always shown as correct — so a learner
/// who guessed wrong sees what they should have picked.
LFAnswerState optionStateFor({
  required int index,
  required int? selected,
  required int correctIndex,
  required bool locked,
}) {
  if (!locked) {
    return index == selected ? LFAnswerState.selected : LFAnswerState.idle;
  }
  if (index == correctIndex) return LFAnswerState.correct;
  if (index == selected) return LFAnswerState.wrong;
  return LFAnswerState.idle;
}

/// The instruction line above every exercise body.
class ExercisePrompt extends StatelessWidget {
  const ExercisePrompt({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: LFSpace.lg),
    child: Text(text, style: context.t.title),
  );
}
