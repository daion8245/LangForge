import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/app/theme/lf_colors.dart';
import 'package:langforge/app/theme/lf_radii.dart';
import 'package:langforge/app/theme/lf_spacing.dart';
import 'package:langforge/app/theme/lf_typography.dart';
import 'package:langforge/presentation/shell/status_bar.dart';

Widget wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData.dark().copyWith(
      extensions: [
        LfColors.dark,
        LfSpacing.standard,
        LfRadii.standard,
        LfTypography.standard,
      ],
    ),
    home: Scaffold(body: Column(children: [const Spacer(), child])),
  );
}

void main() {
  group('StatusBar cancel control', () {
    testWidgets('No cancel button when nothing is running', (tester) async {
      await tester.pumpWidget(
        wrap(StatusBar(onCancel: () {}, statusMessage: '준비됨')),
      );

      expect(find.byTooltip('취소'), findsNothing);
    });

    testWidgets('A running job offers a cancel button', (tester) async {
      var cancelled = false;
      await tester.pumpWidget(
        wrap(
          StatusBar(
            isProgress: true,
            progressRatio: 0.4,
            statusMessage: '탐색 중…',
            cancelTooltip: '탐색 취소',
            onCancel: () => cancelled = true,
          ),
        ),
      );

      final button = find.byTooltip('탐색 취소');
      expect(button, findsOneWidget);

      await tester.tap(button);
      expect(cancelled, isTrue);
    });

    testWidgets('Progress without a handler shows no cancel button', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const StatusBar(isProgress: true, statusMessage: '탐색 중…')),
      );

      expect(find.byType(Tooltip), findsNothing);
    });

    testWidgets('Counts are formatted with thousands separators', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const StatusBar(
            fileCount: 180,
            namespaceCount: 214,
            totalEntryCount: 48312,
          ),
        ),
      );

      expect(find.textContaining('48,312'), findsOneWidget);
    });
  });
}
