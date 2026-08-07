import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/app/theme/lf_colors.dart';
import 'package:langforge/app/theme/lf_radii.dart';
import 'package:langforge/app/theme/lf_spacing.dart';
import 'package:langforge/app/theme/lf_typography.dart';
import 'package:langforge/presentation/common/lf_button.dart';
import 'package:langforge/presentation/common/lf_checkbox.dart';
import 'package:langforge/presentation/common/lf_panel.dart';
import 'package:langforge/presentation/common/lf_status_chip.dart';
import 'package:langforge/presentation/common/lf_text_field.dart';

Widget buildTestApp(Widget child) {
  return MaterialApp(
    theme: ThemeData.dark().copyWith(
      extensions: [
        LfColors.dark,
        LfSpacing.standard,
        LfRadii.standard,
        LfTypography.standard,
      ],
    ),
    home: Scaffold(body: Center(child: child)),
  );
}

void _noop() {}

double _buttonHeight(WidgetTester tester, String label) {
  return tester
      .getSize(
        find.ancestor(
          of: find.text(label),
          matching: find.byType(AnimatedContainer),
        ),
      )
      .height;
}

void main() {
  group('Common Widgets Tests', () {
    testWidgets('LfButton renders label and triggers tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestApp(
          LfButton(label: 'Test Button', onPressed: () => tapped = true),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      await tester.tap(find.text('Test Button'));
      expect(tapped, isTrue);
    });

    testWidgets('LfButton uses the height its kind specifies', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const Column(
            children: [
              LfButton(
                label: 'Primary',
                onPressed: _noop,
                style: LfButtonStyle.primary,
              ),
              LfButton(
                label: 'Secondary',
                onPressed: _noop,
                style: LfButtonStyle.secondary,
              ),
              LfButton(
                label: 'Tertiary',
                onPressed: _noop,
                style: LfButtonStyle.tertiary,
              ),
              LfButton(
                label: 'Danger',
                onPressed: _noop,
                style: LfButtonStyle.danger,
              ),
            ],
          ),
        ),
      );

      // DESIGN.md 7.1 heights.
      expect(tester.getSize(find.text('Primary')).height, lessThan(38));
      expect(_buttonHeight(tester, 'Primary'), equals(38));
      expect(_buttonHeight(tester, 'Secondary'), equals(28));
      expect(_buttonHeight(tester, 'Tertiary'), equals(25));
      expect(_buttonHeight(tester, 'Danger'), equals(32));
    });

    testWidgets('LfButton does not fire while disabled or loading', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        buildTestApp(
          Column(
            children: [
              LfButton(label: 'Disabled', onPressed: null),
              LfButton(
                label: 'Busy',
                isLoading: true,
                loadingLabel: '번역 진행 중…',
                onPressed: () => taps++,
              ),
            ],
          ),
        ),
      );

      expect(find.text('번역 진행 중…'), findsOneWidget);
      await tester.tap(find.text('번역 진행 중…'));
      await tester.tap(find.text('Disabled'));
      expect(taps, equals(0));
    });

    testWidgets('An icon-only LfButton carries a tooltip', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const LfButton(
            icon: Icon(Icons.settings),
            tooltip: '설정',
            style: LfButtonStyle.icon,
            onPressed: _noop,
          ),
        ),
      );

      expect(find.byType(Tooltip), findsOneWidget);
      expect(
        tester.widget<Tooltip>(find.byType(Tooltip)).message,
        equals('설정'),
      );
    });

    testWidgets('LfStatusChip renders label and status style', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const LfStatusChip(type: LfStatusType.done)),
      );

      expect(find.text('새 번역'), findsOneWidget);
    });

    testWidgets('LfCheckbox toggles value', (tester) async {
      bool value = false;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildTestApp(
              LfCheckbox(
                value: value,
                onChanged: (val) => setState(() => value = val!),
              ),
            );
          },
        ),
      );

      expect(find.byType(LfCheckbox), findsOneWidget);
      await tester.tap(find.byType(LfCheckbox));
      expect(value, isTrue);
    });

    testWidgets('LfTextField renders placeholder and receives input', (
      tester,
    ) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        buildTestApp(
          LfTextField(controller: controller, placeholder: 'Enter text'),
        ),
      );

      expect(find.text('Enter text'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Hello World');
      expect(controller.text, equals('Hello World'));
    });

    testWidgets('LfPanel renders title and child content', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const LfPanel(title: 'Test Panel', child: Text('Panel Content')),
        ),
      );

      expect(find.text('TEST PANEL'), findsOneWidget);
      expect(find.text('Panel Content'), findsOneWidget);
    });
  });
}
