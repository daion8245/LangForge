import 'package:flutter/material.dart';

import '../../models/exercise.dart';
import 'widgets/fill_blank_view.dart';
import 'widgets/listening_view.dart';
import 'widgets/match_pairs_view.dart';
import 'widgets/multiple_choice_view.dart';
import 'widgets/word_bank_view.dart';

/// Renders the current exercise.
///
/// The switch is exhaustive on purpose — [Exercise] is sealed and there is no
/// `default` arm, so adding a kind breaks the build here. See
/// `docs/architecture.md`.
class ExerciseView extends StatelessWidget {
  const ExerciseView({
    required this.exercise,
    required this.locked,
    required this.wasCorrect,
    required this.onChanged,
    super.key,
  });

  final Exercise exercise;

  /// True once the answer has been checked; views stop accepting input.
  final bool locked;

  /// Null until checked.
  final bool? wasCorrect;

  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) => switch (exercise) {
    MultipleChoiceExercise e => MultipleChoiceView(
      exercise: e,
      locked: locked,
      onChanged: onChanged,
    ),
    WordBankExercise e => WordBankView(
      exercise: e,
      locked: locked,
      wasCorrect: wasCorrect,
      onChanged: onChanged,
    ),
    ListeningExercise e => ListeningView(
      exercise: e,
      locked: locked,
      onChanged: onChanged,
    ),
    MatchPairsExercise e => MatchPairsView(
      exercise: e,
      locked: locked,
      onChanged: onChanged,
    ),
    FillBlankExercise e => FillBlankView(
      exercise: e,
      locked: locked,
      onChanged: onChanged,
    ),
  };
}
