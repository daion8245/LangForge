import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/models/exercise.dart';
import 'package:langforge/state/lesson_session.dart';

MultipleChoiceExercise _mc(String id, {List<String> vocabIds = const []}) =>
    MultipleChoiceExercise(
      id: id,
      prompt: 'What does this mean?',
      question: 'q-$id',
      vocabIds: vocabIds,
      options: const ['right', 'wrong'],
      correctIndex: 0,
    );

/// Answers the current exercise and continues past the feedback state.
void answer(LessonSession session, {required bool correctly}) {
  session.setAnswer(correctly ? 0 : 1);
  session.submit();
  session.advance();
}

void main() {
  group('queue', () {
    test('starts at the first exercise with full hearts', () {
      final session = LessonSession(
        lessonId: 'l1',
        title: 'Test',
        exercises: [_mc('a'), _mc('b')],
      );

      expect(session.current.id, 'a');
      expect(session.hearts, 3);
      expect(session.total, 2);
      expect(session.position, 1);
      expect(session.status, SessionStatus.inProgress);
    });

    test('completes after the last exercise', () {
      final session = LessonSession(
        lessonId: 'l1',
        title: 'Test',
        exercises: [_mc('a'), _mc('b')],
      );

      answer(session, correctly: true);
      expect(session.status, SessionStatus.inProgress);
      answer(session, correctly: true);
      expect(session.status, SessionStatus.completed);
    });
  });

  group('checking', () {
    test('submit does not advance — feedback stays until continue', () {
      final session = LessonSession(
        lessonId: 'l1',
        title: 'Test',
        exercises: [_mc('a'), _mc('b')],
      );

      session.setAnswer(0);
      session.submit();

      expect(session.outcome?.correct, isTrue);
      expect(session.isLocked, isTrue);
      expect(session.current.id, 'a', reason: 'still on the same exercise');

      session.advance();
      expect(session.outcome, isNull);
      expect(session.current.id, 'b');
    });

    test('submit is a no-op without an answer', () {
      final session = LessonSession(
        lessonId: 'l1',
        title: 'Test',
        exercises: [_mc('a')],
      );

      expect(session.hasAnswer, isFalse);
      session.submit();
      expect(session.outcome, isNull);
    });

    test('a wrong answer costs a heart and reveals the right one', () {
      final session = LessonSession(
        lessonId: 'l1',
        title: 'Test',
        exercises: [_mc('a')],
      );

      session.setAnswer(1);
      session.submit();

      expect(session.hearts, 2);
      expect(session.outcome?.correct, isFalse);
      expect(session.outcome?.correctAnswerText, 'right');
    });
  });

  group('requeue', () {
    test('a missed exercise comes back once, at the end', () {
      final session = LessonSession(
        lessonId: 'l1',
        title: 'Test',
        exercises: [_mc('a'), _mc('b')],
      );

      answer(session, correctly: false);
      expect(session.total, 3, reason: 'a is appended');
      expect(session.current.id, 'b');

      answer(session, correctly: true);
      expect(session.current.id, 'a', reason: 'the miss returns');

      // Missing it again must not grow the queue a second time.
      answer(session, correctly: false);
      expect(session.total, 3);
    });

    test('clearing a requeued exercise earns no XP', () {
      final session = LessonSession(
        lessonId: 'l1',
        title: 'Test',
        exercises: [_mc('a')],
      );

      answer(session, correctly: false);
      expect(session.xpEarned, 0);

      answer(session, correctly: true);
      expect(session.xpEarned, 0, reason: 'requeues cannot farm XP');
    });

    test('first-try correct answers earn XP', () {
      final session = LessonSession(
        lessonId: 'l1',
        title: 'Test',
        exercises: [_mc('a'), _mc('b')],
      );

      answer(session, correctly: true);
      answer(session, correctly: true);
      expect(session.xpEarned, 20);
    });
  });

  group('hearts', () {
    test('running out fails the session', () {
      final session = LessonSession(
        lessonId: 'l1',
        title: 'Test',
        exercises: [_mc('a'), _mc('b'), _mc('c'), _mc('d')],
      );

      answer(session, correctly: false);
      answer(session, correctly: false);
      expect(session.status, SessionStatus.inProgress);

      session.setAnswer(1);
      session.submit();

      expect(session.hearts, 0);
      expect(session.status, SessionStatus.failed);
    });

    test('advancing past a fatal miss keeps the session failed', () {
      final session = LessonSession(
        lessonId: 'l1',
        title: 'Test',
        exercises: [_mc('a'), _mc('b'), _mc('c'), _mc('d')],
      );

      answer(session, correctly: false);
      answer(session, correctly: false);
      answer(session, correctly: false);

      expect(session.status, SessionStatus.failed);
      expect(session.result.passed, isFalse);
    });
  });

  group('result', () {
    test('reports first-try accuracy against the original length', () {
      final session = LessonSession(
        lessonId: 'l1',
        title: 'Test',
        exercises: [_mc('a'), _mc('b')],
      );

      answer(session, correctly: true);
      answer(session, correctly: false);
      answer(session, correctly: true); // the requeued 'b'

      final result = session.result;
      expect(result.passed, isTrue);
      expect(result.totalExercises, 2, reason: 'requeues do not inflate this');
      expect(result.correctFirstTry, 1);
      expect(result.accuracy, 0.5);
      expect(result.xpEarned, 10);
    });

    test('tracks vocabulary hit and missed', () {
      final session = LessonSession(
        lessonId: 'l1',
        title: 'Test',
        exercises: [
          _mc('a', vocabIds: ['v_one']),
          _mc('b', vocabIds: ['v_two']),
        ],
      );

      answer(session, correctly: true);
      answer(session, correctly: false);
      answer(session, correctly: true);

      final result = session.result;
      expect(result.vocabCorrect, containsAll(['v_one', 'v_two']));
      expect(result.vocabWrong, contains('v_two'));
    });

    test('review sessions award reduced XP', () {
      final session = LessonSession(
        lessonId: 'review',
        title: 'Review',
        exercises: [_mc('a')],
        xpPerCorrect: 5,
      );

      answer(session, correctly: true);
      expect(session.xpEarned, 5);
    });
  });

  group('answer validation', () {
    test('word bank requires the exact token order', () {
      const exercise = WordBankExercise(
        id: 'w',
        prompt: 'Build the sentence',
        source: 'Yes, thank you.',
        bank: ['네', '감사합니다', '아니요'],
        solution: ['네', '감사합니다'],
      );

      expect(exercise.isCorrect(['네', '감사합니다']), isTrue);
      expect(exercise.isCorrect(['감사합니다', '네']), isFalse);
      expect(exercise.isCorrect(['네']), isFalse);
      expect(exercise.isCorrect(['네', '감사합니다', '아니요']), isFalse);
      expect(exercise.isCorrect(0), isFalse);
    });

    test('match pairs is correct only when reported complete', () {
      const exercise = MatchPairsExercise(
        id: 'm',
        prompt: 'Tap the matching pairs',
        pairs: [MatchPair(source: 'hello', target: '안녕하세요')],
      );

      expect(exercise.isCorrect(true), isTrue);
      expect(exercise.isCorrect(false), isFalse);
    });
  });
}
