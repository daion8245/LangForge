import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/state/app_state.dart';
import 'package:langforge/state/lesson_session.dart';

LessonResult _pass(
  String lessonId, {
  int xp = 60,
  Set<String> correct = const {},
  Set<String> wrong = const {},
}) => LessonResult(
  lessonId: lessonId,
  passed: true,
  xpEarned: xp,
  correctFirstTry: 6,
  totalExercises: 6,
  elapsed: const Duration(minutes: 3),
  vocabCorrect: correct,
  vocabWrong: wrong,
);

AppState _onboarded() {
  final state = AppState();
  final korean = state.courses.firstWhere((c) => c.id == 'ko');
  state.completeOnboarding(course: korean, goal: DailyGoal.steady);
  return state;
}

void main() {
  group('onboarding', () {
    test('starts empty', () {
      final state = AppState();
      expect(state.onboarded, isFalse);
      expect(state.course, isNull);
      expect(state.vault, isEmpty);
      expect(state.totalXp, 0);
    });

    test('only Korean is playable', () {
      final state = AppState();
      final playable = state.courses.where((c) => c.available).toList();
      expect(playable, hasLength(1));
      expect(playable.single.id, 'ko');
      expect(playable.single.units, isNotEmpty);
    });
  });

  group('progression', () {
    test('the first lesson is current and the rest are locked', () {
      final state = _onboarded();
      expect(state.currentLessonId, 'l1');
      expect(state.statusOf('l1'), LessonStatus.current);
      expect(state.statusOf('l2'), LessonStatus.locked);
    });

    test('completing a lesson unlocks the next one', () {
      final state = _onboarded();
      state.applyResult(_pass('l1'), isReview: false);

      expect(state.statusOf('l1'), LessonStatus.complete);
      expect(state.statusOf('l2'), LessonStatus.current);
      expect(state.currentLessonId, 'l2');
      expect(state.lessonsCompleted, 1);
    });

    test('replaying a lesson does not double-count it', () {
      final state = _onboarded();
      state.applyResult(_pass('l1'), isReview: false);
      state.applyResult(_pass('l1'), isReview: false);

      expect(state.lessonsCompleted, 1);
    });

    test('a locked lesson names its blocker', () {
      final state = _onboarded();
      expect(state.blockerTitleFor('l3'), 'Hello and thanks');
    });
  });

  group('vault', () {
    test('words arrive only when their lesson is finished', () {
      final state = _onboarded();
      expect(state.vault, isEmpty);

      state.applyResult(_pass('l1'), isReview: false);

      final ids = state.vault.map((e) => e.id).toSet();
      expect(ids, containsAll(['v_hello', 'v_thanks', 'v_yes', 'v_no']));
      expect(ids, isNot(contains('v_coffee')));
    });

    test('correct answers strengthen, wrong answers weaken', () {
      final state = _onboarded();
      state.applyResult(
        _pass('l1', correct: {'v_hello'}, wrong: {'v_no'}),
        isReview: false,
      );

      final hello = state.vault.firstWhere((e) => e.id == 'v_hello');
      final no = state.vault.firstWhere((e) => e.id == 'v_no');
      expect(hello.strength, 1);
      expect(no.strength, 0);
    });

    test('a review session draws from the weak words', () {
      final state = _onboarded();
      state.applyResult(_pass('l1'), isReview: false);

      expect(state.canReview, isTrue);
      final session = state.buildReviewSession();
      expect(session.lessonId, 'review');
      expect(session.total, greaterThan(0));
      expect(session.xpPerCorrect, 5);
    });

    test('reviews do not complete lessons', () {
      final state = _onboarded();
      state.applyResult(
        LessonResult(
          lessonId: 'review',
          passed: true,
          xpEarned: 10,
          correctFirstTry: 2,
          totalExercises: 2,
          elapsed: Duration.zero,
          vocabCorrect: const {},
          vocabWrong: const {},
        ),
        isReview: true,
      );

      expect(state.lessonsCompleted, 0);
      expect(state.currentLessonId, 'l1');
      expect(state.totalXp, 10);
    });
  });

  group('xp and streak', () {
    test('the first XP of the day advances the streak once', () {
      final state = _onboarded();
      expect(state.streakDays, 0);

      state.applyResult(_pass('l1', xp: 30), isReview: false);
      expect(state.streakDays, 1);
      expect(state.xpToday, 30);

      state.applyResult(_pass('l2', xp: 30), isReview: false);
      expect(state.streakDays, 1, reason: 'same day, not a new streak day');
      expect(state.xpToday, 60);
    });

    test('level tracks total XP', () {
      final state = _onboarded();
      expect(state.level, 1);

      state.applyResult(_pass('l1', xp: 60), isReview: false);
      state.applyResult(_pass('l2', xp: 60), isReview: false);
      expect(state.totalXp, 120);
      expect(state.level, 2);
      expect(state.levelProgress, closeTo(0.2, 0.001));
    });

    test('daily goal progress caps at one', () {
      final state = _onboarded();
      state.applyResult(_pass('l1', xp: 500), isReview: false);
      expect(state.dailyGoalProgress, 1.0);
    });
  });

  test('reset clears everything, including banked word strength', () {
    final state = _onboarded();
    state.applyResult(_pass('l1', correct: {'v_hello'}), isReview: false);
    state.resetProgress();

    expect(state.onboarded, isFalse);
    expect(state.course, isNull);
    expect(state.vault, isEmpty);
    expect(state.totalXp, 0);
    expect(state.streakDays, 0);

    // Re-earning the word on the same instance must start it back at zero
    // strength: the catalogue must not have been mutated in place.
    final korean = state.courses.firstWhere((c) => c.id == 'ko');
    state.completeOnboarding(course: korean, goal: DailyGoal.steady);
    state.applyResult(_pass('l1'), isReview: false);

    expect(state.vault.firstWhere((e) => e.id == 'v_hello').strength, 0);
  });
}
