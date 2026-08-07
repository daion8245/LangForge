import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/app.dart';

/// Walks the demo script from `docs/prototype-scope.md` far enough to prove
/// there are no dead ends between launch and the lesson player.
///
/// Note: once the Path is on screen its current node pulses forever, so
/// `pumpAndSettle` would never return. Everything past onboarding advances a
/// fixed number of frames instead.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

/// Runs onboarding and lands on the Path.
Future<void> onboard(WidgetTester tester, {String goal = 'Steady'}) async {
  await tester.pumpWidget(const LangForgeApp());
  await tester.pumpAndSettle();

  await tester.tap(find.text('Korean'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(goal));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Start forging'));
  await settle(tester);
}

void main() {
  testWidgets('a course must be chosen before onboarding continues', (
    tester,
  ) async {
    await tester.pumpWidget(const LangForgeApp());
    await tester.pumpAndSettle();

    expect(find.text('What are you forging?'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(
      find.text('What are you forging?'),
      findsOneWidget,
      reason: 'Next is disabled until a course is selected',
    );

    await tester.tap(find.text('Korean'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('How much per day?'), findsOneWidget);
  });

  testWidgets('unavailable courses cannot be selected', (tester) async {
    await tester.pumpWidget(const LangForgeApp());
    await tester.pumpAndSettle();

    expect(find.text('Coming soon'), findsNWidgets(2));

    await tester.tap(find.text('Japanese'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(
      find.text('What are you forging?'),
      findsOneWidget,
      reason: 'tapping a coming-soon course selects nothing',
    );
  });

  testWidgets('onboarding leads to the path and into a lesson', (tester) async {
    await onboard(tester, goal: 'Serious');

    expect(find.text('First words'), findsOneWidget);
    expect(find.text('Daily goal'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Hello and thanks, current'));
    await settle(tester);

    expect(find.text('6 exercises'), findsOneWidget);
    await tester.tap(find.text('Start'));
    await settle(tester);

    expect(find.text('Tap the matching pairs'), findsOneWidget);
    expect(find.text('Check'), findsOneWidget);
    expect(find.bySemanticsLabel('3 of 3 hearts left'), findsOneWidget);
  });

  testWidgets('a locked lesson names what is blocking it', (tester) async {
    await onboard(tester);

    await tester.tap(find.bySemanticsLabel('Introducing yourself, locked'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Finish "Hello and thanks" first.'), findsOneWidget);
  });

  testWidgets('an empty vault explains how to fill it', (tester) async {
    await onboard(tester);

    await tester.tap(find.text('Vault'));
    await settle(tester);

    expect(find.text('Nothing forged yet'), findsOneWidget);
  });

  testWidgets('the profile reflects a fresh account', (tester) async {
    await onboard(tester);

    await tester.tap(find.text('Profile'));
    await settle(tester);

    expect(find.text('Day streak'), findsOneWidget);
    expect(find.text('Total XP'), findsOneWidget);
    expect(find.text('Words forged'), findsOneWidget);
    expect(find.text('0 / 100 XP to level 2'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Achievements'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    expect(find.text('First forge'), findsOneWidget);
  });

  testWidgets('theme can be switched to dark from the profile', (tester) async {
    await onboard(tester);

    await tester.tap(find.text('Profile'));
    await settle(tester);

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.system,
    );

    await tester.scrollUntilVisible(
      find.byIcon(Icons.dark_mode_outlined),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.dark_mode_outlined));
    await settle(tester);

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });

  testWidgets('resetting progress returns to onboarding', (tester) async {
    await onboard(tester);

    await tester.tap(find.text('Profile'));
    await settle(tester);

    await tester.scrollUntilVisible(
      find.text('Reset progress'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    await tester.tap(find.text('Reset progress'));
    await settle(tester);

    await tester.tap(find.text('Reset'));
    await settle(tester);

    expect(find.text('What are you forging?'), findsOneWidget);
  });
}
