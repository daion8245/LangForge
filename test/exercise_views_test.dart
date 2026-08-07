import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/core/theme.dart';
import 'package:langforge/features/lesson/exercise_view.dart';
import 'package:langforge/models/exercise.dart';

/// Hosts a view and records what it reports upward.
Future<List<Object?>> pumpExercise(
  WidgetTester tester,
  Exercise exercise, {
  bool locked = false,
  bool? wasCorrect,
}) async {
  final reported = <Object?>[];
  await tester.pumpWidget(
    MaterialApp(
      theme: buildTheme(Brightness.light),
      home: Scaffold(
        body: SingleChildScrollView(
          child: ExerciseView(
            exercise: exercise,
            locked: locked,
            wasCorrect: wasCorrect,
            onChanged: reported.add,
          ),
        ),
      ),
    ),
  );
  return reported;
}

void main() {
  testWidgets('multiple choice reports the tapped index', (tester) async {
    const exercise = MultipleChoiceExercise(
      id: 'e',
      prompt: 'What does this mean?',
      question: '안녕하세요',
      options: ['Hello', 'Goodbye'],
      correctIndex: 0,
    );

    final reported = await pumpExercise(tester, exercise);

    await tester.tap(find.text('Goodbye'));
    await tester.pump();

    expect(reported, [1]);
  });

  testWidgets('multiple choice ignores taps once locked', (tester) async {
    const exercise = MultipleChoiceExercise(
      id: 'e',
      prompt: 'What does this mean?',
      question: '안녕하세요',
      options: ['Hello', 'Goodbye'],
      correctIndex: 0,
    );

    final reported = await pumpExercise(tester, exercise, locked: true);

    await tester.tap(find.text('Goodbye'));
    await tester.pump();

    expect(reported, isEmpty);
  });

  testWidgets('word bank reports tokens in the order tapped', (tester) async {
    const exercise = WordBankExercise(
      id: 'e',
      prompt: 'Build the sentence',
      source: 'Yes, thank you.',
      bank: ['감사합니다', '네'],
      solution: ['네', '감사합니다'],
    );

    final reported = await pumpExercise(tester, exercise);

    await tester.tap(find.text('네'));
    await tester.pump();
    await tester.tap(find.text('감사합니다').first);
    await tester.pump();

    expect(reported.last, ['네', '감사합니다']);
  });

  testWidgets('word bank reports null when the tray is emptied', (
    tester,
  ) async {
    const exercise = WordBankExercise(
      id: 'e',
      prompt: 'Build the sentence',
      source: 'Yes.',
      bank: ['네'],
      solution: ['네'],
    );

    final reported = await pumpExercise(tester, exercise);

    await tester.tap(find.text('네'));
    await tester.pump();
    expect(reported.last, ['네']);

    // The tray copy is the visible one; the bank slot is hollow.
    await tester.tap(find.text('네').first);
    await tester.pump();
    expect(reported.last, isNull);
  });

  testWidgets('listening hides the spoken text until played', (tester) async {
    const exercise = ListeningExercise(
      id: 'e',
      prompt: 'What did you hear?',
      spoken: '감사합니다',
      gloss: 'thank you',
      options: ['감사합니다', '안녕하세요'],
      correctIndex: 0,
    );

    await pumpExercise(tester, exercise);

    expect(find.text('no audio in prototype'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Play audio'));
    await tester.pumpAndSettle();

    expect(find.text('no audio in prototype'), findsOneWidget);
  });

  testWidgets('match pairs reports true only when every pair is locked', (
    tester,
  ) async {
    const exercise = MatchPairsExercise(
      id: 'e',
      prompt: 'Tap the matching pairs',
      pairs: [
        MatchPair(source: 'hello', target: '안녕하세요'),
        MatchPair(source: 'thank you', target: '감사합니다'),
      ],
    );

    final reported = await pumpExercise(tester, exercise);

    await tester.tap(find.text('안녕하세요'));
    await tester.pump();
    await tester.tap(find.text('hello'));
    await tester.pump();

    expect(reported, isEmpty, reason: 'one pair down, one to go');
    expect(find.text('1 of 2 matched'), findsOneWidget);

    await tester.tap(find.text('감사합니다'));
    await tester.pump();
    await tester.tap(find.text('thank you'));
    await tester.pump();

    expect(reported, [true]);
  });

  testWidgets('match pairs clears a wrong pairing', (tester) async {
    const exercise = MatchPairsExercise(
      id: 'e',
      prompt: 'Tap the matching pairs',
      pairs: [
        MatchPair(source: 'hello', target: '안녕하세요'),
        MatchPair(source: 'thank you', target: '감사합니다'),
      ],
    );

    final reported = await pumpExercise(tester, exercise);

    await tester.tap(find.text('안녕하세요'));
    await tester.pump();
    await tester.tap(find.text('thank you'));
    await tester.pump();

    expect(reported, isEmpty);
    await tester.pumpAndSettle();
    expect(find.text('0 of 2 matched'), findsOneWidget);
  });

  testWidgets('fill blank drops the chosen token into the blank', (
    tester,
  ) async {
    const exercise = FillBlankExercise(
      id: 'e',
      prompt: 'Fill in the blank',
      before: '',
      after: ' 주세요.',
      translation: 'Water, please.',
      options: ['물', '차'],
      correctIndex: 0,
    );

    final reported = await pumpExercise(tester, exercise);

    expect(find.text('물'), findsOneWidget, reason: 'only the option row');

    await tester.tap(find.text('물'));
    await tester.pump();

    expect(reported, [0]);
    expect(find.text('물'), findsNWidgets(2), reason: 'now in the blank too');
  });
}
