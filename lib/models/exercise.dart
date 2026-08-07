/// Exercise types for the lesson player.
///
/// [Exercise] is `sealed`: every renderer pattern-matches over the subtypes
/// without a `default` arm, so adding a kind breaks the build at each call
/// site instead of silently falling through.
///
/// No Flutter imports in this layer — see `docs/architecture.md`.
library;

sealed class Exercise {
  const Exercise({
    required this.id,
    required this.prompt,
    this.vocabIds = const <String>[],
  });

  /// Stable within a lesson. Used to dedupe requeues.
  final String id;

  /// Instruction shown above the interaction, e.g. "Build the sentence".
  final String prompt;

  /// Vocabulary this exercise practises, for Vault strength updates.
  final List<String> vocabIds;

  /// Whether [answer] — whatever the matching view reports — is right.
  bool isCorrect(Object answer);

  /// Shown in the feedback bar when the learner gets it wrong.
  String get correctAnswerText;
}

/// Pick one of several options. The cheapest check of meaning.
final class MultipleChoiceExercise extends Exercise {
  const MultipleChoiceExercise({
    required super.id,
    required super.prompt,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.note,
    super.vocabIds,
  });

  /// The term or phrase being asked about.
  final String question;

  /// Romanization or gloss shown under [question]; omitted when not useful.
  final String? note;

  final List<String> options;
  final int correctIndex;

  @override
  bool isCorrect(Object answer) => answer is int && answer == correctIndex;

  @override
  String get correctAnswerText => options[correctIndex];
}

/// Assemble a translation from a bank of tokens. The core exercise —
/// see `docs/product-brief.md`.
final class WordBankExercise extends Exercise {
  const WordBankExercise({
    required super.id,
    required super.prompt,
    required this.source,
    required this.bank,
    required this.solution,
    super.vocabIds,
  });

  /// The sentence to translate, in the learner's language.
  final String source;

  /// Tokens offered, including distractors. Shuffled at render time.
  final List<String> bank;

  /// The expected token sequence.
  final List<String> solution;

  @override
  bool isCorrect(Object answer) {
    if (answer is! List<String> || answer.length != solution.length) {
      return false;
    }
    for (var i = 0; i < solution.length; i++) {
      if (answer[i] != solution[i]) return false;
    }
    return true;
  }

  @override
  String get correctAnswerText => solution.join(' ');
}

/// Decode spoken language. The prototype has no audio: the view reveals
/// [spoken] as explicitly-marked scaffolding. See `docs/screens.md`.
final class ListeningExercise extends Exercise {
  const ListeningExercise({
    required super.id,
    required super.prompt,
    required this.spoken,
    required this.gloss,
    required this.options,
    required this.correctIndex,
    super.vocabIds,
  });

  /// What is "said".
  final String spoken;

  /// Translation, revealed with the feedback.
  final String gloss;

  final List<String> options;
  final int correctIndex;

  @override
  bool isCorrect(Object answer) => answer is int && answer == correctIndex;

  @override
  String get correctAnswerText => options[correctIndex];
}

/// One source/target pairing inside a [MatchPairsExercise].
class MatchPair {
  const MatchPair({required this.source, required this.target});

  final String source;
  final String target;
}

/// Tap-to-match grid. Completes only when every pair is locked in, so the
/// view reports `true` and nothing else.
final class MatchPairsExercise extends Exercise {
  const MatchPairsExercise({
    required super.id,
    required super.prompt,
    required this.pairs,
    super.vocabIds,
  });

  final List<MatchPair> pairs;

  @override
  bool isCorrect(Object answer) => answer == true;

  @override
  String get correctAnswerText =>
      pairs.map((p) => '${p.target} = ${p.source}').join(', ');
}

/// Grammar in context: choose the token that fills an inline blank.
final class FillBlankExercise extends Exercise {
  const FillBlankExercise({
    required super.id,
    required super.prompt,
    required this.before,
    required this.after,
    required this.translation,
    required this.options,
    required this.correctIndex,
    super.vocabIds,
  });

  /// Sentence fragment before the blank.
  final String before;

  /// Sentence fragment after the blank. May be empty.
  final String after;

  /// Full-sentence meaning, shown as context.
  final String translation;

  final List<String> options;
  final int correctIndex;

  @override
  bool isCorrect(Object answer) => answer is int && answer == correctIndex;

  @override
  String get correctAnswerText => options[correctIndex];
}
