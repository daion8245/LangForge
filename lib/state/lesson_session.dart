import 'package:flutter/foundation.dart';

import '../models/exercise.dart';

enum SessionStatus { inProgress, completed, failed }

/// The result of one answered exercise, held until the learner taps Continue.
@immutable
class AnswerOutcome {
  const AnswerOutcome({
    required this.correct,
    required this.correctAnswerText,
    this.note,
  });

  final bool correct;
  final String correctAnswerText;

  /// Extra context shown under the feedback title, when the exercise has any.
  final String? note;
}

/// What a finished session hands back to `AppState`.
@immutable
class LessonResult {
  const LessonResult({
    required this.lessonId,
    required this.passed,
    required this.xpEarned,
    required this.correctFirstTry,
    required this.totalExercises,
    required this.elapsed,
    required this.vocabCorrect,
    required this.vocabWrong,
  });

  final String lessonId;
  final bool passed;
  final int xpEarned;

  /// Exercises cleared without a prior mistake.
  final int correctFirstTry;
  final int totalExercises;
  final Duration elapsed;

  /// Vocabulary ids answered right / wrong at least once.
  final Set<String> vocabCorrect;
  final Set<String> vocabWrong;

  double get accuracy =>
      totalExercises == 0 ? 0 : correctFirstTry / totalExercises;
}

/// Drives a single lesson or review session.
///
/// Deliberately knows nothing about `AppState`: it is a pure engine, and the
/// only write to global state happens once when the session ends. See
/// `docs/architecture.md`.
class LessonSession extends ChangeNotifier {
  LessonSession({
    required this.lessonId,
    required this.title,
    required List<Exercise> exercises,
    this.xpPerCorrect = 10,
    this.maxHearts = 3,
  }) : assert(exercises.isNotEmpty, 'a session needs at least one exercise'),
       _queue = List<Exercise>.of(exercises),
       _originalCount = exercises.length,
       _hearts = maxHearts,
       _startedAt = DateTime.now();

  final String lessonId;
  final String title;
  final int xpPerCorrect;
  final int maxHearts;

  final List<Exercise> _queue;
  final int _originalCount;
  final DateTime _startedAt;

  /// Exercises missed at least once — they neither earn XP nor requeue twice.
  final Set<String> _missed = <String>{};
  final Set<String> _requeued = <String>{};

  /// Exercises answered correctly at least once.
  final Set<String> _cleared = <String>{};
  final Set<String> _vocabCorrect = <String>{};
  final Set<String> _vocabWrong = <String>{};

  int _index = 0;
  int _hearts;
  int _xpEarned = 0;
  SessionStatus _status = SessionStatus.inProgress;
  AnswerOutcome? _outcome;
  Object? _draftAnswer;

  Exercise get current => _queue[_index];
  int get hearts => _hearts;
  int get xpEarned => _xpEarned;
  SessionStatus get status => _status;

  /// Non-null once the learner has checked and before they continue.
  AnswerOutcome? get outcome => _outcome;

  /// Whether Check should be enabled.
  bool get hasAnswer => _draftAnswer != null;

  /// Whether the body should stop accepting input.
  bool get isLocked => _outcome != null;

  double get progress => _queue.isEmpty ? 0 : _index / _queue.length;

  int get position => _index + 1;
  int get total => _queue.length;

  /// Called by exercise views as the learner builds an answer. Passing null
  /// (e.g. emptying the word-bank tray) disables Check again.
  void setAnswer(Object? answer) {
    if (_outcome != null) return;
    if (_draftAnswer == answer) return;
    _draftAnswer = answer;
    notifyListeners();
  }

  /// Validates the draft answer. Never advances — see `docs/architecture.md`.
  void submit() {
    final answer = _draftAnswer;
    if (answer == null || _outcome != null) return;

    final exercise = current;
    final correct = exercise.isCorrect(answer);

    if (correct) {
      if (!_missed.contains(exercise.id)) {
        _xpEarned += xpPerCorrect;
      }
      _cleared.add(exercise.id);
      _vocabCorrect.addAll(exercise.vocabIds);
    } else {
      _hearts--;
      _missed.add(exercise.id);
      _vocabWrong.addAll(exercise.vocabIds);
      // Requeue once, at the tail, so the lesson never ends on a miss.
      if (_requeued.add(exercise.id)) {
        _queue.add(exercise);
      }
    }

    _outcome = AnswerOutcome(
      correct: correct,
      correctAnswerText: exercise.correctAnswerText,
      note: switch (exercise) {
        MultipleChoiceExercise(:final note) => note,
        ListeningExercise(:final gloss) => gloss,
        FillBlankExercise(:final translation) => translation,
        WordBankExercise(:final source) => source,
        MatchPairsExercise() => null,
      },
    );

    if (_hearts <= 0) {
      _status = SessionStatus.failed;
    }
    notifyListeners();
  }

  /// Moves to the next exercise, or ends the session.
  void advance() {
    if (_outcome == null) return;
    _outcome = null;
    _draftAnswer = null;

    if (_status == SessionStatus.failed) {
      notifyListeners();
      return;
    }
    if (_index + 1 >= _queue.length) {
      _status = SessionStatus.completed;
    } else {
      _index++;
    }
    notifyListeners();
  }

  /// Distinct exercises cleared — shown on the out-of-hearts screen.
  int get clearedCount => _cleared.length;

  LessonResult get result => LessonResult(
    lessonId: lessonId,
    passed: _status == SessionStatus.completed,
    xpEarned: _xpEarned,
    correctFirstTry: _cleared.difference(_missed).length,
    totalExercises: _originalCount,
    elapsed: DateTime.now().difference(_startedAt),
    vocabCorrect: Set.unmodifiable(_vocabCorrect),
    vocabWrong: Set.unmodifiable(_vocabWrong),
  );
}
