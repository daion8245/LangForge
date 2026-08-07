import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/app/theme/lf_colors.dart';
import 'package:langforge/app/theme/lf_mobile_sizes.dart';
import 'package:langforge/app/theme/lf_radii.dart';
import 'package:langforge/app/theme/lf_sizes.dart';
import 'package:langforge/app/theme/lf_spacing.dart';
import 'package:langforge/app/theme/lf_typography.dart';
import 'package:langforge/application/mobile/mobile_ui_controller.dart';
import 'package:langforge/presentation/mobile/widgets/mobile_bottom_tabs.dart';
import 'package:langforge/presentation/mobile/widgets/mobile_controls.dart';

/// A phone-sized host carrying the mobile theme extension.
Widget host(Widget child, {double textScale = 1.0}) {
  return MaterialApp(
    theme: ThemeData.dark().copyWith(
      extensions: [
        LfColors.dark,
        LfSpacing.standard,
        LfRadii.standard,
        LfTypography.standard,
        LfSizes.standard,
        LfMobileSizes.standard,
      ],
    ),
    home: MediaQuery(
      data: MediaQueryData(
        size: const Size(390, 844),
        textScaler: TextScaler.linear(textScale),
      ),
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  setUp(() => WidgetsFlutterBinding.ensureInitialized());

  group('Touch targets — DESIGN.md 6.3', () {
    testWidgets('a 19px checkbox still responds over 44×44', (tester) async {
      var value = false;
      await tester.pumpWidget(
        host(
          Center(
            child: MobileCheckbox(
              value: value,
              semanticLabel: 'namespace quark 포함',
              onChanged: (next) => value = next,
            ),
          ),
        ),
      );

      final box = tester.getSize(find.byType(MobileTapTarget));
      expect(box.width, greaterThanOrEqualTo(44));
      expect(box.height, greaterThanOrEqualTo(44));

      // The visual box stays the mockup's 19px even though the hit area grew.
      expect(
        tester.getSize(
          find.descendant(
            of: find.byType(MobileCheckbox),
            matching: find.byType(Opacity),
          ),
        ),
        const Size(19, 19),
      );

      await tester.tap(find.byType(MobileCheckbox));
      expect(value, isTrue);
    });

    testWidgets('the toggle clears the same minimum', (tester) async {
      await tester.pumpWidget(
        host(
          Center(
            child: MobileToggle(
              value: true,
              semanticLabel: '자동 저장',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final box = tester.getSize(find.byType(MobileTapTarget));
      expect(box.width, greaterThanOrEqualTo(44));
      expect(box.height, greaterThanOrEqualTo(44));
    });

    testWidgets('an option row is at least 44 tall', (tester) async {
      await tester.pumpWidget(
        host(
          MobileOptionRow(
            label: 'en_gb.json 을(를) 원본으로',
            hint: '24 키',
            selected: false,
            onTap: () {},
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(MobileOptionRow)).height,
        greaterThanOrEqualTo(44),
      );
    });
  });

  group('Bottom tabs — ROADMAP 13.2', () {
    testWidgets('shows the four tabs and reports the selected one', (
      tester,
    ) async {
      var picked = MobileTab.files;
      await tester.pumpWidget(
        host(
          MobileBottomTabs(
            current: MobileTab.edit,
            issueCount: 0,
            onSelect: (tab) => picked = tab,
          ),
        ),
      );

      for (final tab in MobileTab.values) {
        expect(find.text(tab.label), findsOneWidget);
      }

      await tester.tap(find.text('출력'));
      expect(picked, MobileTab.output);
    });

    testWidgets('only 문제 carries a badge, and only when non-zero', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          MobileBottomTabs(
            current: MobileTab.files,
            issueCount: 0,
            onSelect: (_) {},
          ),
        ),
      );
      expect(find.text('0'), findsNothing);

      await tester.pumpWidget(
        host(
          MobileBottomTabs(
            current: MobileTab.files,
            issueCount: 7,
            onSelect: (_) {},
          ),
        ),
      );
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('the badge count reaches a screen reader', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          MobileBottomTabs(
            current: MobileTab.files,
            issueCount: 3,
            onSelect: (_) {},
          ),
        ),
      );

      expect(find.bySemanticsLabel('문제 3건'), findsOneWidget);
      handle.dispose();
    });
  });

  group('Text scaling', () {
    testWidgets('the tab bar survives 1.5× text without overflowing', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          MobileBottomTabs(
            current: MobileTab.files,
            issueCount: 12,
            onSelect: (_) {},
          ),
          textScale: 1.5,
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
