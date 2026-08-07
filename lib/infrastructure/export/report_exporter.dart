import '../../domain/model/entry_status.dart';
import '../../domain/model/translation_entry.dart';
import '../security/sensitive_filter.dart';

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
    DateTime? generatedAt,
  }) {
    final buffer = StringBuffer();
    final now = (generatedAt ?? DateTime.now()).toString().substring(0, 16);

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
    buffer.writeln('| 파일명 | 종류 | 크기(bytes) | SHA-256 |');
    buffer.writeln('|---|---|---|---|');
    for (final f in inputFiles) {
      final shaShort = f.sha256.length >= 12
          ? f.sha256.substring(0, 12)
          : f.sha256;
      buffer.writeln(
        '| ${f.originalName} | ${f.kind} | ${f.sizeBytes} | $shaShort |',
      );
    }
    buffer.writeln();

    buffer.writeln('## namespace');
    buffer.writeln('| namespace | 상태 | 전체 키 수 |');
    buffer.writeln('|---|---|---|');
    for (final ns in namespaces) {
      buffer.writeln('| ${ns.name} | ${ns.state.wireName} | ${ns.keyCount} |');
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
    buffer.writeln('- 원문 유지(fallback): ${countOf(EntryStatus.fallback)}');
    buffer.writeln('- 빈 문자열 유지(empty): ${countOf(EntryStatus.empty)}');
    buffer.writeln('- 확인 필요(confirm): ${countOf(EntryStatus.confirm)}');
    buffer.writeln('- 번역 대기(wait): ${countOf(EntryStatus.wait)}');
    buffer.writeln('- 검증 실패(invalid): ${countOf(EntryStatus.invalid)}');
    buffer.writeln();

    if (staleKeysByNamespace.isNotEmpty) {
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

    // Reports are shared with other people; strip credentials and the user's
    // home directory before the text leaves this function.
    return SensitiveFilter.scrub(buffer.toString());
  }
}
