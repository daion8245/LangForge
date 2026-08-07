import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../core/ui.dart';
import '../../../models/exercise.dart';
import 'option_row.dart';

/// Grammar in context: the chosen token drops into an inline blank.
class FillBlankView extends StatefulWidget {
  const FillBlankView({
    required this.exercise,
    required this.locked,
    required this.onChanged,
    super.key,
  });

  final FillBlankExercise exercise;
  final bool locked;
  final ValueChanged<Object?> onChanged;

  @override
  State<FillBlankView> createState() => _FillBlankViewState();
}

class _FillBlankViewState extends State<FillBlankView> {
  int? _selected;

  void _select(int index) {
    if (widget.locked) return;
    setState(() => _selected = index);
    widget.onChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final e = widget.exercise;
    final filled = _selected == null ? null : e.options[_selected!];
    final blankState = switch ((widget.locked, _selected)) {
      (false, null) => LFAnswerState.idle,
      (false, _) => LFAnswerState.selected,
      (true, _) =>
        _selected == e.correctIndex
            ? LFAnswerState.correct
            : LFAnswerState.wrong,
    };
    final blankPalette = LFAnswerPalette.of(context, blankState);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExercisePrompt(text: e.prompt),
        Container(
          padding: const EdgeInsets.all(LFSpace.lg),
          decoration: BoxDecoration(
            color: c.surface,
            border: Border.all(color: c.hairline),
            borderRadius: BorderRadius.circular(LFRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (e.before.isNotEmpty)
                    Text(e.before, style: context.t.targetLarge),
                  AnimatedContainer(
                    duration: LFMotion.tile,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: LFSpace.md,
                      vertical: LFSpace.xs,
                    ),
                    constraints: const BoxConstraints(minWidth: 72),
                    decoration: BoxDecoration(
                      color: blankPalette.fill,
                      border: Border.all(color: blankPalette.border, width: 2),
                      borderRadius: BorderRadius.circular(LFRadius.sm),
                    ),
                    child: Text(
                      filled ?? '',
                      textAlign: TextAlign.center,
                      style: context.t.targetLarge,
                    ),
                  ),
                  if (e.after.isNotEmpty)
                    Text(e.after, style: context.t.targetLarge),
                ],
              ),
              const SizedBox(height: LFSpace.md),
              Text(e.translation, style: context.t.bodyMuted),
            ],
          ),
        ),
        const SizedBox(height: LFSpace.xl),
        for (var i = 0; i < e.options.length; i++)
          OptionRow(
            label: e.options[i],
            targetLanguage: true,
            state: optionStateFor(
              index: i,
              selected: _selected,
              correctIndex: e.correctIndex,
              locked: widget.locked,
            ),
            onTap: widget.locked ? null : () => _select(i),
          ),
      ],
    );
  }
}
