import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/app/theme/lf_colors.dart';
import 'package:langforge/app/theme/lf_radii.dart';
import 'package:langforge/app/theme/lf_sizes.dart';
import 'package:langforge/app/theme/lf_spacing.dart';
import 'package:langforge/app/theme/lf_typography.dart';
import 'package:langforge/presentation/common/lf_button.dart';
import 'package:langforge/presentation/common/lf_checkbox.dart';
import 'package:langforge/presentation/shell/status_bar.dart';
import 'package:langforge/presentation/shell/top_bar.dart';

ThemeData theme() => ThemeData.dark().copyWith(
  extensions: [
    LfColors.dark,
    LfSpacing.standard,
    LfRadii.standard,
    LfTypography.standard,
    LfSizes.standard,
  ],
);

/// Wraps [child] in the app's theme, optionally at a given text scale, window
/// size, or with reduced motion requested (TECHNICAL.md 15).
Widget host(
  Widget child, {
  double textScale = 1.0,
  Size size = const Size(1400, 900),
  bool reduceMotion = false,
}) {
  return MaterialApp(
    theme: theme(),
    home: MediaQuery(
      data: MediaQueryData(
        size: size,
        textScaler: TextScaler.linear(textScale),
        disableAnimations: reduceMotion,
      ),
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  group('Semantics', () {
    setUp(() => WidgetsFlutterBinding.ensureInitialized());

    testWidgets('A checkbox reports its label and checked state', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          LfCheckbox(
            value: true,
            semanticLabel: 'namespace quark 포함',
            onChanged: (_) {},
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(LfCheckbox)),
        matchesSemantics(
          label: 'namespace quark 포함',
          hasCheckedState: true,
          isChecked: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
    });

    testWidgets('A disabled checkbox says so rather than just looking grey', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const LfCheckbox(
            value: false,
            semanticLabel: 'namespace quark 포함',
            onChanged: null,
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(LfCheckbox)),
        matchesSemantics(
          label: 'namespace quark 포함',
          hasCheckedState: true,
          isChecked: false,
          hasEnabledState: true,
          isEnabled: false,
        ),
      );
    });

    testWidgets('An icon-only button carries a label for readers', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          LfButton(
            onPressed: () {},
            icon: const Icon(Icons.download),
            style: LfButtonStyle.icon,
            tooltip: '내보내기',
          ),
        ),
      );

      // The label lives on the button's own semantics node, which sits below
      // the widget itself — matching by label is what a reader would do.
      expect(find.bySemanticsLabel('내보내기'), findsOneWidget);

      expect(
        tester.getSemantics(find.bySemanticsLabel('내보내기')),
        matchesSemantics(
          label: '내보내기',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
    });
  });

  group('Tap targets', () {
    testWidgets('A checkbox is at least 24x24 despite its 15px box', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(LfCheckbox(value: false, onChanged: (_) {})),
      );

      final size = tester.getSize(find.byType(LfCheckbox));
      expect(size.width, greaterThanOrEqualTo(LfSizes.standard.minTapTarget));
      expect(size.height, greaterThanOrEqualTo(LfSizes.standard.minTapTarget));
    });
  });

  group('Reduced motion', () {
    testWidgets('The checkbox transition is dropped, not shortened', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(LfCheckbox(value: false, onChanged: (_) {}), reduceMotion: true),
      );

      final animated = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(animated.duration, equals(Duration.zero));
    });

    testWidgets('The transition runs when motion is not restricted', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(LfCheckbox(value: false, onChanged: (_) {})),
      );

      final animated = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(animated.duration, greaterThan(Duration.zero));
      // DESIGN.md 14 — nothing animates for longer than 200ms.
      expect(
        animated.duration,
        lessThanOrEqualTo(const Duration(milliseconds: 200)),
      );
    });
  });

  group('Text scaling', () {
    testWidgets('The status bar survives 2.0x text', (tester) async {
      await tester.pumpWidget(
        host(
          const Align(
            alignment: Alignment.bottomCenter,
            child: StatusBar(
              fileCount: 180,
              namespaceCount: 214,
              totalEntryCount: 48312,
              isProgress: true,
              progressRatio: 0.5,
            ),
          ),
          textScale: 2.0,
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('The top bar survives 2.0x text', (tester) async {
      await tester.pumpWidget(
        host(
          const Align(
            alignment: Alignment.topCenter,
            child: TopBar(projectName: 'MyPack'),
          ),
          textScale: 2.0,
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('Responsive', () {
    testWidgets('The top bar fits at the 768px step', (tester) async {
      tester.view.physicalSize = const Size(768, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        host(
          const Align(
            alignment: Alignment.topCenter,
            child: TopBar(
              projectName: 'A Very Long Project Name That Would Overflow',
              breadcrumbPath: 'assets/exalpha/lang/en_us.json',
              showLeftToggle: true,
              showRightToggle: true,
            ),
          ),
          size: const Size(768, 800),
        ),
      );

      expect(tester.takeException(), isNull);
      // The wordmark is the first thing dropped when space runs out.
      expect(find.text('LANGFORGE'), findsNothing);
    });

    testWidgets('The top bar keeps the wordmark at full width', (tester) async {
      await tester.pumpWidget(
        host(
          const Align(
            alignment: Alignment.topCenter,
            child: TopBar(projectName: 'MyPack'),
          ),
        ),
      );

      expect(find.text('LANGFORGE'), findsOneWidget);
    });
  });

  group('Zero values', () {
    testWidgets('An unknown progress total shows — rather than NaN%', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const Align(
            alignment: Alignment.bottomCenter,
            child: StatusBar(isProgress: true),
          ),
        ),
      );

      expect(find.text('—'), findsOneWidget);
      expect(find.textContaining('NaN'), findsNothing);
      expect(find.textContaining('Infinity'), findsNothing);
    });

    testWidgets('A known ratio is shown as a percentage', (tester) async {
      await tester.pumpWidget(
        host(
          const Align(
            alignment: Alignment.bottomCenter,
            child: StatusBar(isProgress: true, progressRatio: 0.42),
          ),
        ),
      );

      expect(find.text('42%'), findsOneWidget);
    });
  });
}
