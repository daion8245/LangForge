import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/model/entry_status.dart';
import 'package:langforge/domain/model/translation_entry.dart';
import 'package:langforge/infrastructure/export/report_exporter.dart';

const inputFiles = [
  InputFileUnit(
    id: 'f1',
    originalName: 'Quark-4.0.jar',
    kind: 'jar',
    sizeBytes: 4200,
    sha256: 'abcdef0123456789',
    scanState: ScanState.ok,
  ),
];

const namespaces = [
  NamespaceUnit(
    id: 'ns1',
    inputFileId: 'f1',
    name: 'quark',
    state: NamespaceState.ok,
    keyCount: 3,
  ),
];

TranslationEntry entry(String id, EntryStatus status) => TranslationEntry(
  id: id,
  namespaceId: 'ns1',
  key: 'item.$id',
  keyOrder: 0,
  sourceText: 'Item',
  status: status,
);

String build({
  Map<String, List<String>> staleKeys = const {},
  List<NamespaceUnit> namespaceUnits = namespaces,
  List<TranslationEntry>? entries,
  List<ReportConflict> conflicts = const [],
  List<ReportOutputFile> outputFiles = const [],
}) {
  return ReportExporter.generateReport(
    inputFiles: inputFiles,
    namespaces: namespaceUnits,
    entries:
        entries ??
        [
          entry('a', EntryStatus.done),
          entry('b', EntryStatus.kept),
          entry('c', EntryStatus.fallback),
        ],
    providerName: 'Gemini',
    modelName: 'gemini-3.6-flash',
    sourceLangCode: 'en_us',
    targetLangCode: 'ko_kr',
    appVersion: '0.1.0',
    staleKeysByNamespace: staleKeys,
    conflicts: conflicts,
    outputFiles: outputFiles,
  );
}

void main() {
  group('ReportExporter', () {
    test('Reports the configured languages, not hardcoded ones', () {
      final report = ReportExporter.generateReport(
        inputFiles: inputFiles,
        namespaces: namespaces,
        entries: const [],
        providerName: 'Gemini',
        modelName: 'gemini-3.6-flash',
        sourceLangCode: 'en_us',
        targetLangCode: 'ja_jp',
        appVersion: '0.1.0',
      );

      expect(report, contains('대상 언어: ja_jp'));
    });

    test('Counts every status, including 원문 유지', () {
      final report = build();

      expect(report, contains('새 번역(done): 1'));
      expect(report, contains('기존 번역 유지(kept): 1'));
      expect(report, contains('원문 유지(fallback): 1'));
    });

    test('Lists stale keys that were dropped from output', () {
      final report = build(
        staleKeys: {
          'quark': ['item.removed_one', 'item.removed_two'],
        },
      );

      expect(report, contains('## 오래된 key'));
      expect(report, contains('item.removed_one'));
      expect(report, contains('item.removed_two'));
      expect(report, contains('| quark | 2 |'));
    });

    test('The stale key section is omitted when there are none', () {
      expect(build(), isNot(contains('## 오래된 key')));
    });

    test('Long stale key lists are truncated, keeping the count', () {
      final many = List.generate(50, (i) => 'item.gone_$i');
      final report = build(staleKeys: {'quark': many});

      expect(report, contains('| quark | 50 |'));
      expect(report, contains('…'));
      expect(report, isNot(contains('item.gone_49')));
    });

    test('The cache hit rate reads — when there is nothing to divide', () {
      final report = build(entries: const []);

      expect(report, contains('캐시 적중률: —'));
      expect(report, isNot(contains('NaN')));
    });

    test('The cache hit rate is a percentage once entries exist', () {
      final report = build(
        entries: [
          entry('a', EntryStatus.cache),
          entry('b', EntryStatus.cache),
          entry('c', EntryStatus.done),
          entry('d', EntryStatus.done),
        ],
      );

      expect(report, contains('캐시 적중률: 50%'));
    });

    test(
      'Broken namespaces are named in the 오류 section with file and line',
      () {
        final report = build(
          namespaceUnits: const [
            NamespaceUnit(
              id: 'ns1',
              inputFileId: 'f1',
              name: 'broken',
              state: NamespaceState.jsonError,
              errorMessage: 'Unexpected character',
              errorLine: 42,
            ),
          ],
        );

        expect(report, contains('## 오류'));
        expect(
          report,
          contains('| broken | Quark-4.0.jar | 42 | Unexpected character |'),
        );
      },
    );

    test('The 오류 section is omitted when every namespace parsed', () {
      expect(build(), isNot(contains('## 오류')));
    });

    test('confirm entries and missing sources become warnings', () {
      final report = build(
        namespaceUnits: const [
          NamespaceUnit(
            id: 'ns1',
            inputFileId: 'f1',
            name: 'quark',
            state: NamespaceState.noSource,
          ),
        ],
        entries: [entry('a', EntryStatus.confirm)],
      );

      expect(report, contains('## 경고'));
      expect(report, contains('원본 언어 파일이 없습니다'));
      expect(report, contains('| quark | item.a | 확인 필요'));
    });

    test('Conflicts list their participants and the resolution', () {
      final report = build(
        conflicts: const [
          ReportConflict(
            namespaceName: 'quark',
            key: 'item.stone',
            participantNames: ['Quark-4.0.jar', 'Supplementaries-2.jar'],
            resolution: 'Quark-4.0.jar 선택',
          ),
        ],
      );

      expect(report, contains('## 충돌'));
      expect(
        report,
        contains(
          '| quark | item.stone | Quark-4.0.jar, Supplementaries-2.jar '
          '| Quark-4.0.jar 선택 |',
        ),
      );
    });

    test('원문 유지 항목 records the source text and why it stayed', () {
      final report = build(
        entries: [
          TranslationEntry(
            id: 'e1',
            namespaceId: 'ns1',
            key: 'msg.url',
            keyOrder: 0,
            sourceText: 'https://example.com/docs',
            status: EntryStatus.fallback,
          ),
          TranslationEntry(
            id: 'e2',
            namespaceId: 'ns1',
            key: 'msg.plain',
            keyOrder: 1,
            sourceText: 'Ancient Tome',
            status: EntryStatus.fallback,
          ),
        ],
      );

      expect(report, contains('## 원문 유지 항목'));
      expect(
        report,
        contains('| quark | msg.url | https://example.com/docs | 번역 제외 규칙 |'),
      );
      expect(
        report,
        contains('| quark | msg.plain | Ancient Tome | 사용자가 원문 유지를 선택 |'),
      );
    });

    test('Output files are listed with size and key count', () {
      final report = build(
        outputFiles: const [
          ReportOutputFile(
            path: 'KO_Translation_Pack.zip',
            sizeBytes: 8192,
            keyCount: 120,
          ),
          ReportOutputFile(path: 'LangForge_Pack/pack.png', sizeBytes: 512),
        ],
      );

      expect(report, contains('## 출력 파일'));
      expect(report, contains('| KO_Translation_Pack.zip | 8192 | 120 |'));
      // No keys in an icon — the column must not invent a zero.
      expect(report, contains('| LangForge_Pack/pack.png | 512 | — |'));
    });

    test('A pipe in a mod string cannot break the table it sits in', () {
      final report = build(
        entries: [
          TranslationEntry(
            id: 'e1',
            namespaceId: 'ns1',
            key: 'msg.pipe',
            keyOrder: 0,
            sourceText: 'left | right\nsecond line',
            status: EntryStatus.fallback,
          ),
        ],
      );

      expect(report, contains(r'left \| right second line'));
    });

    test('Namespace rows break the counts down per status', () {
      final report = build(
        entries: [
          entry('a', EntryStatus.done),
          entry('b', EntryStatus.done),
          entry('c', EntryStatus.kept),
          entry('d', EntryStatus.invalid),
        ],
      );

      expect(report, contains('| quark | ok | 3 | 2 | 1 | 0 | 0 | 1 |'));
    });

    test('Credentials and home paths never reach the report', () {
      final report = ReportExporter.generateReport(
        inputFiles: const [
          InputFileUnit(
            id: 'f1',
            originalName: r'C:\Users\kingh\mods\Quark.jar',
            kind: 'jar',
            sizeBytes: 1,
            sha256: 'abcdef0123456789',
            scanState: ScanState.ok,
          ),
        ],
        namespaces: namespaces,
        entries: const [],
        providerName: 'Gemini',
        modelName: 'api_key=AIzaSyA1b2C3d4E5f6G7h8I9j0K1l2M3n4O5p6',
        sourceLangCode: 'en_us',
        targetLangCode: 'ko_kr',
        appVersion: '0.1.0',
      );

      expect(report, isNot(contains('AIzaSy')));
      expect(report, isNot(contains('kingh')));
      expect(report, contains('%USERPROFILE%'));
    });
  });
}
