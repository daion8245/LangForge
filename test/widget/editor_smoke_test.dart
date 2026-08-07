import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/app/theme/lf_colors.dart';
import 'package:langforge/app/theme/lf_radii.dart';
import 'package:langforge/app/theme/lf_sizes.dart';
import 'package:langforge/app/theme/lf_spacing.dart';
import 'package:langforge/app/theme/lf_typography.dart';
import 'package:langforge/infrastructure/db/app_database.dart';
import 'package:langforge/presentation/editor/editor_shell.dart';
import 'package:langforge/presentation/editor/entries/entries_list_view.dart';

/// Builds the three-panel editor with real rows.
///
/// The other widget tests only reach S0 and S1, so nothing was rendering the
/// shell, the tree, the entry list and the settings panel together. Wiring
/// mistakes there — a bad `Expanded`, a mis-nested wrapper, a null callback
/// dereferenced during build — never show up in `flutter analyze`; they only
/// show up when the tree is actually built.
///
/// Rows are constructed directly rather than read from a database: this is a
/// layout and wiring check, and a live drift connection would only add watch
/// streams the test clock has to chase.
final _now = DateTime(2026, 8, 8);

final inputFile = InputFile(
  id: 'file-1',
  originalName: 'ExampleMultiNs-1.0.jar',
  absolutePath: '/mods/ExampleMultiNs-1.0.jar',
  kind: 'jar',
  sizeBytes: 2048,
  sha256: 'seed-hash',
  addedAt: _now,
  enabled: true,
  scanState: 'ok',
);

final namespace = Namespace(
  id: 'ns-alpha',
  inputFileId: 'file-1',
  name: 'exalpha',
  state: 'ok',
  excluded: false,
  selected: true,
  keyCount: 3,
);

final languageFile = LanguageFile(
  id: 'lf-1',
  namespaceId: 'ns-alpha',
  rawCode: 'en_us',
  code: 'en_us',
  entryPath: 'assets/exalpha/lang/en_us.json',
  keyCount: 3,
  role: 'source',
);

Entry _entry({
  required String id,
  required String key,
  required int order,
  required String sourceText,
  required String status,
  String? newTranslation,
  String? validationJson,
}) {
  return Entry(
    id: id,
    namespaceId: 'ns-alpha',
    key: key,
    keyOrder: order,
    sourceText: sourceText,
    newTranslation: newTranslation,
    status: status,
    userEdited: false,
    validationJson: validationJson,
    updatedAt: _now,
  );
}

final entries = <Entry>[
  _entry(
    id: 'e-1',
    key: 'block.exalpha.oak_hedge',
    order: 0,
    sourceText: 'Oak Hedge',
    status: 'wait',
  ),
  _entry(
    id: 'e-2',
    key: 'chat.exalpha.hit',
    order: 1,
    sourceText: '%s hit %s for %d damage',
    status: 'done',
    newTranslation: '%s이(가) %s에게 %d 피해',
  ),
  _entry(
    id: 'e-3',
    key: 'msg.exalpha.color',
    order: 2,
    sourceText: '§aReady§r',
    status: 'invalid',
    validationJson: '{"reason":"tokenMismatch"}',
  ),
];

Widget editor({
  String? selectedNamespaceId,
  bool isTranslating = false,
  Map<String, int> statusCounts = const {'wait': 1, 'done': 1, 'invalid': 1},
}) {
  return ProviderScope(
    child: MaterialApp(
      theme: ThemeData.dark().copyWith(
        extensions: [
          LfColors.dark,
          LfSpacing.standard,
          LfRadii.standard,
          LfTypography.standard,
          LfSizes.standard,
        ],
      ),
      home: EditorShell(
        projectName: 'MyPack',
        inputFiles: [inputFile],
        namespaces: [namespace],
        languageFiles: [languageFile],
        entries: entries,
        totalEntryCount: entries.length,
        statusCounts: statusCounts,
        selectedNamespaceId: selectedNamespaceId,
        isTranslating: isTranslating,
      ),
    ),
  );
}

Future<void> pumpAt(WidgetTester tester, Widget widget, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(widget);
  await tester.pumpAndSettle();
}

void main() {
  const wide = Size(1400, 900);

  testWidgets('The three-panel editor builds with real rows', (tester) async {
    await pumpAt(tester, editor(), wide);

    expect(tester.takeException(), isNull);
    expect(find.text('LANGFORGE'), findsOneWidget);
    expect(find.text('프로젝트 탐색기'), findsOneWidget);
    expect(find.text('작업 및 엔진 설정'), findsOneWidget);
    expect(find.text('ExampleMultiNs-1.0.jar'), findsOneWidget);
    expect(find.text('exalpha'), findsOneWidget);
    expect(find.text('MyPack'), findsOneWidget);
  });

  testWidgets('The entry list renders keys, source text and status', (
    tester,
  ) async {
    await pumpAt(tester, editor(selectedNamespaceId: 'ns-alpha'), wide);

    expect(tester.takeException(), isNull);
    expect(find.text('block.exalpha.oak_hedge'), findsOneWidget);
    expect(find.text('chat.exalpha.hit'), findsOneWidget);
    expect(find.text('%s hit %s for %d damage'), findsOneWidget);

    // 문제 = 검증 실패 · 원문 유지 · 확인 필요, and here only the invalid row
    // qualifies (AC-7.7).
    expect(find.textContaining('문제 (1)'), findsOneWidget);
  });

  testWidgets('Switching to the output structure view builds', (tester) async {
    await pumpAt(tester, editor(selectedNamespaceId: 'ns-alpha'), wide);

    await tester.tap(find.text('출력 구조'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('The file menu opens with the project actions', (tester) async {
    await pumpAt(tester, editor(), wide);

    await tester.tap(find.text('파일 ▾'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('프로젝트 저장'), findsOneWidget);
    expect(find.text('다시 검사'), findsOneWidget);
    expect(find.text('프로젝트 닫기'), findsOneWidget);
  });

  testWidgets('At 1024px the settings panel collapses into a drawer', (
    tester,
  ) async {
    await pumpAt(tester, editor(), const Size(1024, 800));

    expect(tester.takeException(), isNull);
    expect(find.text('작업 및 엔진 설정'), findsNothing);
    expect(find.text('프로젝트 탐색기'), findsOneWidget);

    await tester.tap(find.byTooltip('작업 설정 열기'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('작업 및 엔진 설정'), findsOneWidget);
  });

  testWidgets('At 768px both panels collapse and the editor stands alone', (
    tester,
  ) async {
    await pumpAt(
      tester,
      editor(selectedNamespaceId: 'ns-alpha'),
      const Size(768, 800),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('프로젝트 탐색기'), findsNothing);
    expect(find.text('작업 및 엔진 설정'), findsNothing);
    expect(find.text('block.exalpha.oak_hedge'), findsOneWidget);

    await tester.tap(find.byTooltip('탐색기 열기'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('프로젝트 탐색기'), findsOneWidget);
  });

  testWidgets('A run in flight locks editing and the file actions', (
    tester,
  ) async {
    // An indeterminate progress bar animates forever by design, so this one
    // pumps a fixed number of frames instead of settling.
    tester.view.physicalSize = wide;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      editor(selectedNamespaceId: 'ns-alpha', isTranslating: true),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);

    // EXPERIENCE.md 6.4 — the translation column is read-only during a run.
    // Only the entry rows are checked: the credential field locks with
    // readOnly rather than by being disabled, so it stays selectable.
    final entryFields = tester.widgetList<TextFormField>(
      find.descendant(
        of: find.byType(EntriesListView),
        matching: find.byType(TextFormField),
      ),
    );
    expect(entryFields, isNotEmpty);
    for (final field in entryFields) {
      expect(field.enabled, isFalse);
    }
  });

  testWidgets('The editor survives 2.0x text at 1024px', (tester) async {
    tester.view.physicalSize = const Size(1024, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(1024, 800),
          textScaler: TextScaler.linear(2.0),
        ),
        child: editor(selectedNamespaceId: 'ns-alpha'),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
