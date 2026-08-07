import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../models/exercise.dart';
import 'option_row.dart';

class MultipleChoiceView extends StatefulWidget {
  const MultipleChoiceView({
    required this.exercise,
    required this.locked,
    required this.onChanged,
    super.key,
  });

  final MultipleChoiceExercise exercise;
  final bool locked;
  final ValueChanged<Object?> onChanged;

  @override
  State<MultipleChoiceView> createState() => _MultipleChoiceViewState();
}

class _MultipleChoiceViewState extends State<MultipleChoiceView> {
  int? _selected;

  void _select(int index) {
    if (widget.locked) return;
    setState(() => _selected = index);
    widget.onChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.exercise;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExercisePrompt(text: e.prompt),
        Text(e.question, style: context.t.targetLarge),
        if (e.note != null) ...[
          const SizedBox(height: LFSpace.xs),
          Text(e.note!, style: context.t.bodyMuted),
        ],
        const SizedBox(height: LFSpace.xl),
        for (var i = 0; i < e.options.length; i++)
          OptionRow(
            label: e.options[i],
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
