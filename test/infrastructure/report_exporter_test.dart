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

String build({Map<String, List<String>> staleKeys = const {}}) {
  return ReportExporter.generateReport(
    inputFiles: inputFiles,
    namespaces: namespaces,
    entries: [
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
