import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/core/app_scope.dart';
import 'package:langforge/core/theme.dart';
import 'package:langforge/features/lesson/lesson_screen.dart';
import 'package:langforge/models/exercise.dart';
import 'package:langforge/models/lesson.dart';
import 'package:langforge/state/app_state.dart';

const Lesson _lesson = Lesson(
  id: 'l1',
  title: 'Hello and thanks',
  subtitle: 'Test lesson',
  newWordIds: ['v_hello'],
  exercises: [
    MultipleChoiceExercise(
      id: 'e1',
      prompt: 'What does this mean?',
      question: '안녕하세요',
      vocabIds: ['v_hello'],
      options: ['Hello', 'Goodbye'],
      correctIndex: 0,
    ),
    MultipleChoiceExercise(
      id: 'e2',
      prompt: 'What does this mean?',
      question: '감사합니다',
      vocabIds: ['v_thanks'],
      options: ['Thank you', 'Sorry'],
      correctIndex: 0,
    ),
  ],
);

Future<AppState> pumpLesson(WidgetTester tester) async {
  final state = AppState();
  state.completeOnboarding(
    course: state.courses.firstWhere((c) => c.id == 'ko'),
    goal: DailyGoal.steady,
  );

  await tester.pumpWidget(
    AppScope(
      state: state,
      child: MaterialApp(
        theme: buildTheme(Brightness.light),
        home: const LessonScreen(lesson: _lesson),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return state;
}

/// Taps an option, checks it, then continues past the feedback.
Future<void> answer(WidgetTester tester, String option) async {
  await tester.tap(find.text(option));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Check'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Check stays disabled until an option is chosen', (tester) async {
    await pumpLesson(tester);

    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    expect(find.text('Nice.'), findsNothing, reason: 'nothing was answered');

    await tester.tap(find.text('Hello'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    expect(find.text('Nice.'), findsOneWidget);
  });

  testWidgets('a wrong answer explains itself and costs a heart', (
    tester,
  ) async {
    await pumpLesson(tester);

    await tester.tap(find.text('Goodbye'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();

    expect(find.text('Not quite.'), findsOneWidget);
    expect(find.text('Hello'), findsWidgets, reason: 'the right answer shows');
    expect(find.bySemanticsLabel('2 of 3 hearts left'), findsOneWidget);
  });

  testWidgets('finishing a lesson lands on the completion screen', (
    tester,
  ) async {
    final state = await pumpLesson(tester);

    await answer(tester, 'Hello');
    await answer(tester, 'Thank you');

    expect(find.text('Lesson forged'), findsOneWidget);
    expect(find.text('First try'), findsOneWidget);

    expect(state.isLessonComplete('l1'), isTrue);
    expect(state.totalXp, 20);
    expect(state.streakDays, 1);
  });

  testWidgets('a missed exercise is requeued before the lesson can end', (
    tester,
  ) async {
    final state = await pumpLesson(tester);

    await answer(tester, 'Goodbye'); // wrong
    await answer(tester, 'Thank you');

    // The lesson is not over — the missed exercise comes back.
    expect(find.text('Lesson forged'), findsNothing);
    expect(find.text('안녕하세요'), findsOneWidget);

    await answer(tester, 'Hello');

    expect(find.text('Lesson forged'), findsOneWidget);
    expect(state.totalXp, 10, reason: 'the requeued exercise earns nothing');
  });

  testWidgets('quitting asks for confirmation first', (tester) async {
    await pumpLesson(tester);

    await tester.tap(find.byTooltip('Quit lesson'));
    await tester.pumpAndSettle();

    expect(find.text('Quit lesson?'), findsOneWidget);

    await tester.tap(find.text('Keep going'));
    await tester.pumpAndSettle();

    expect(find.text('What does this mean?'), findsOneWidget);
  });

  testWidgets('the player fits a 360x640 screen', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpLesson(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Check'), findsOneWidget);
  });
}
