import '../../domain/cache/cache_hit_rate.dart';
import '../../domain/model/entry_status.dart';
import '../../domain/model/translation_entry.dart';
import '../../domain/policy/exclusion_policy.dart';
import '../security/sensitive_filter.dart';

/// One file the export actually produced. Collected after the write so the
/// sizes in the report are the sizes on disk, not a prediction.
class ReportOutputFile {
  const ReportOutputFile({
    required this.path,
    required this.sizeBytes,
    this.keyCount,
  });

  /// Shown as given — callers pass a path relative to the output directory so
  /// the report does not carry the user's folder layout.
  final String path;

  final int sizeBytes;

  /// Null for files that hold no translation keys (`pack.mcmeta`, `pack.png`).
  final int? keyCount;
}

/// A conflict as the report presents it, already reduced to display names.
///
/// The report does not re-run detection: by export time the user has resolved
/// (or not) each conflict, and that decision lives in the database.
class ReportConflict {
  const ReportConflict({
    required this.namespaceName,
    required this.key,
    required this.participantNames,
    required this.resolution,
  });

  final String namespaceName;
  final String key;

  /// Input file names that disagreed about the source text.
  final List<String> participantNames;

  /// The chosen file name, or the reason it is still open.
  final String resolution;
}

/// Builds `Translation_Report.md`. See TECHNICAL.md 8.6.
abstract final class ReportExporter {
  static String generateReport({
    required List<InputFileUnit> inputFiles,
    required List<NamespaceUnit> namespaces,
    required List<TranslationEntry> entries,
    required String providerName,
    required String modelName,
    required String sourceLangCode,
    required String targetLangCode,
    required String appVersion,
    Map<String, List<String>> staleKeysByNamespace = const {},
    List<ReportConflict> conflicts = const [],
    List<ReportOutputFile> outputFiles = const [],
    DateTime? generatedAt,
  }) {
    final buffer = StringBuffer();
    final now = (generatedAt ?? DateTime.now()).toString().substring(0, 16);

    final namespaceById = {for (final ns in namespaces) ns.id: ns};
    final fileById = {for (final f in inputFiles) f.id: f};

    final entriesByNamespace = <String, List<TranslationEntry>>{};
    for (final entry in entries) {
      entriesByNamespace.putIfAbsent(entry.namespaceId, () => []).add(entry);
    }

    buffer.writeln('# LangForge 번역 보고서');
    buffer.writeln();
    buffer.writeln('생성: $now · LangForge $appVersion');
    buffer.writeln();

    buffer.writeln('## 프로젝트');
    buffer.writeln('- 원본 언어: $sourceLangCode');
    buffer.writeln('- 대상 언어: $targetLangCode');
    buffer.writeln('- 번역 제공자: $providerName');
    buffer.writeln('- 모델: $modelName');
    buffer.writeln();

    buffer.writeln('## 입력 파일');
    buffer.writeln('| 파일명 | 종류 | 크기(bytes) | SHA-256 | namespace | 상태 |');
    buffer.writeln('|---|---|---|---|---|---|');
    for (final f in inputFiles) {
      final shaShort = f.sha256.length >= 12
          ? f.sha256.substring(0, 12)
          : f.sha256;
      final nsCount = namespaces.where((ns) => ns.inputFileId == f.id).length;
      buffer.writeln(
        '| ${f.originalName} | ${f.kind} | ${f.sizeBytes} | $shaShort '
        '| $nsCount | ${f.scanState.wireName} |',
      );
    }
    buffer.writeln();

    buffer.writeln('## namespace');
    buffer.writeln(
      '| namespace | 상태 | 전체 키 | 새 번역 | 기존 유지 | 캐시 | 원문 유지 | 실패 |',
    );
    buffer.writeln('|---|---|---|---|---|---|---|---|');
    for (final ns in namespaces) {
      final nsEntries = entriesByNamespace[ns.id] ?? const <TranslationEntry>[];
      int countIn(EntryStatus status) =>
          nsEntries.where((e) => e.status == status).length;
      buffer.writeln(
        '| ${ns.name} | ${ns.state.wireName} | ${ns.keyCount} '
        '| ${countIn(EntryStatus.done)} | ${countIn(EntryStatus.kept)} '
        '| ${countIn(EntryStatus.cache)} | ${countIn(EntryStatus.fallback)} '
        '| ${countIn(EntryStatus.invalid)} |',
      );
    }
    buffer.writeln();

    final counts = <EntryStatus, int>{};
    for (final entry in entries) {
      counts.update(entry.status, (v) => v + 1, ifAbsent: () => 1);
    }
    int countOf(EntryStatus s) => counts[s] ?? 0;

    buffer.writeln('## 통계');
    buffer.writeln('- 전체 키 수: ${entries.length}');
    buffer.writeln('- 새 번역(done): ${countOf(EntryStatus.done)}');
    buffer.writeln('- 기존 번역 유지(kept): ${countOf(EntryStatus.kept)}');
    buffer.writeln('- 캐시 재사용(cache): ${countOf(EntryStatus.cache)}');
    buffer.writeln('- 원문 유지(fallback): ${countOf(EntryStatus.fallback)}');
    buffer.writeln('- 빈 문자열 유지(empty): ${countOf(EntryStatus.empty)}');
    buffer.writeln('- 확인 필요(confirm): ${countOf(EntryStatus.confirm)}');
    buffer.writeln('- 번역 대기(wait): ${countOf(EntryStatus.wait)}');
    buffer.writeln('- 검증 실패(invalid): ${countOf(EntryStatus.invalid)}');
    // Zero entries must read '—', never 'NaN%' (AGENTS.md 5.3).
    buffer.writeln(
      '- 캐시 적중률: '
      '${CacheHitRate.format(hits: countOf(EntryStatus.cache), total: entries.length)}',
    );
    buffer.writeln();

    _writeErrors(buffer, namespaces: namespaces, fileById: fileById);
    _writeWarnings(
      buffer,
      namespaces: namespaces,
      entries: entries,
      namespaceById: namespaceById,
    );
    _writeConflicts(buffer, conflicts);
    _writeFallbacks(buffer, entries: entries, namespaceById: namespaceById);
    _writeStaleKeys(buffer, staleKeysByNamespace);
    _writeOutputFiles(buffer, outputFiles);

    // Reports are shared with other people; strip credentials and the user's
    // home directory before the text leaves this function.
    return SensitiveFilter.scrub(buffer.toString());
  }

  static void _writeErrors(
    StringBuffer buffer, {
    required List<NamespaceUnit> namespaces,
    required Map<String, InputFileUnit> fileById,
  }) {
    final failed = namespaces
        .where((ns) => ns.state == NamespaceState.jsonError)
        .toList();
    if (failed.isEmpty) return;

    buffer.writeln('## 오류');
    buffer.writeln();
    buffer.writeln('아래 namespace 는 대기열과 출력에서 제외했습니다. 나머지는 그대로 진행했습니다.');
    buffer.writeln();
    buffer.writeln('| namespace | 파일 | 줄 | 메시지 |');
    buffer.writeln('|---|---|---|---|');
    for (final ns in failed) {
      final fileName = fileById[ns.inputFileId]?.originalName ?? '—';
      final line = ns.errorLine?.toString() ?? '—';
      final message = _cell(ns.errorMessage ?? 'JSON 오류');
      buffer.writeln('| ${ns.name} | $fileName | $line | $message |');
    }
    buffer.writeln();
  }

  static void _writeWarnings(
    StringBuffer buffer, {
    required List<NamespaceUnit> namespaces,
    required List<TranslationEntry> entries,
    required Map<String, NamespaceUnit> namespaceById,
  }) {
    final rows = <(String, String, String)>[];

    for (final ns in namespaces) {
      if (ns.state == NamespaceState.noSource) {
        rows.add((ns.name, '—', '원본 언어 파일이 없습니다'));
      }
    }
    for (final entry in entries) {
      if (entry.status != EntryStatus.confirm) continue;
      final name = namespaceById[entry.namespaceId]?.name ?? entry.namespaceId;
      rows.add((name, entry.key, '확인 필요 — 변수 구성이 원문과 다릅니다'));
    }

    if (rows.isEmpty) return;

    buffer.writeln('## 경고');
    buffer.writeln();
    buffer.writeln('| namespace | key | 내용 |');
    buffer.writeln('|---|---|---|');
    for (final (namespace, key, note) in rows) {
      buffer.writeln('| $namespace | ${_cell(key)} | $note |');
    }
    buffer.writeln();
  }

  static void _writeConflicts(
    StringBuffer buffer,
    List<ReportConflict> conflicts,
  ) {
    if (conflicts.isEmpty) return;

    buffer.writeln('## 충돌');
    buffer.writeln();
    buffer.writeln('| namespace | key | 참여 파일 | 해결 |');
    buffer.writeln('|---|---|---|---|');
    for (final conflict in conflicts) {
      final participants = conflict.participantNames.join(', ');
      buffer.writeln(
        '| ${conflict.namespaceName} | ${_cell(conflict.key)} '
        '| ${_cell(participants)} | ${_cell(conflict.resolution)} |',
      );
    }
    buffer.writeln();
  }

  static void _writeFallbacks(
    StringBuffer buffer, {
    required List<TranslationEntry> entries,
    required Map<String, NamespaceUnit> namespaceById,
  }) {
    final kept = entries
        .where((e) => e.status == EntryStatus.fallback)
        .toList();
    if (kept.isEmpty) return;

    buffer.writeln('## 원문 유지 항목');
    buffer.writeln();
    buffer.writeln('| namespace | key | 원문 | 사유 |');
    buffer.writeln('|---|---|---|---|');
    for (final entry in kept) {
      final name = namespaceById[entry.namespaceId]?.name ?? entry.namespaceId;
      final reason = ExclusionPolicy.shouldExclude(entry.sourceText)
          ? '번역 제외 규칙'
          : '사용자가 원문 유지를 선택';
      buffer.writeln(
        '| $name | ${_cell(entry.key)} | ${_cell(entry.sourceText)} | $reason |',
      );
    }
    buffer.writeln();
  }

  static void _writeStaleKeys(
    StringBuffer buffer,
    Map<String, List<String>> staleKeysByNamespace,
  ) {
    if (staleKeysByNamespace.isEmpty) return;

    buffer.writeln('## 오래된 key');
    buffer.writeln();
    buffer.writeln('원본 언어 파일에 없는 key 입니다. 출력에서 제외했습니다.');
    buffer.writeln();
    buffer.writeln('| namespace | 개수 | key |');
    buffer.writeln('|---|---|---|');
    for (final entry in staleKeysByNamespace.entries) {
      final keys = entry.value;
      // Long lists make the table unreadable; the count carries the rest.
      final shown = keys.take(20).join(', ');
      final suffix = keys.length > 20 ? ' …' : '';
      buffer.writeln('| ${entry.key} | ${keys.length} | $shown$suffix |');
    }
    buffer.writeln();
  }

  static void _writeOutputFiles(
    StringBuffer buffer,
    List<ReportOutputFile> outputFiles,
  ) {
    if (outputFiles.isEmpty) return;

    buffer.writeln('## 출력 파일');
    buffer.writeln();
    buffer.writeln('| 경로 | 크기(bytes) | 키 수 |');
    buffer.writeln('|---|---|---|');
    for (final file in outputFiles) {
      buffer.writeln(
        '| ${_cell(file.path)} | ${file.sizeBytes} '
        '| ${file.keyCount?.toString() ?? '—'} |',
      );
    }
    buffer.writeln();
  }

  /// Values come from mod authors, so a `|` or a newline in one would break the
  /// table it sits in.
  static String _cell(String value) {
    final flattened = value
        .replaceAll('\r\n', ' ')
        .replaceAll('\n', ' ')
        .replaceAll('|', r'\|');
    return flattened.length > 120
        ? '${flattened.substring(0, 120)}…'
        : flattened;
  }
}
