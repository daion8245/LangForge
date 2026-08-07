import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/model/entry_status.dart';
import 'package:langforge/domain/model/translation_entry.dart';
import 'package:langforge/domain/policy/export_gate.dart';

/// [ExportGate.evaluateAggregate] exists so the mobile 출력 tab can render the
/// verdict without pulling every entry into memory (MOBILE.md 1.2). It is only
/// worth having if it says exactly what [ExportGate.evaluate] says, so these
/// tests run both over the same scenarios and compare.

NamespaceUnit _ns({
  String id = 'ns1',
  NamespaceState state = NamespaceState.ok,
  bool excluded = false,
  bool selected = true,
}) {
  return NamespaceUnit(
    id: id,
    inputFileId: 'file1',
    name: 'quark',
    state: state,
    excluded: excluded,
    selected: selected,
    keyCount: 1,
  );
}

TranslationEntry _entry(String id, EntryStatus status) {
  return TranslationEntry(
    id: id,
    namespaceId: 'ns1',
    key: 'item.$id',
    keyOrder: 1,
    sourceText: 'Oak',
    status: status,
  );
}

/// Runs the aggregate gate on inputs derived from the same lists the row-based
/// gate gets, so a scenario is only ever written once.
ExportVerdict _aggregateOf({
  required List<NamespaceUnit> namespaces,
  required List<TranslationEntry> entries,
  required bool isTranslating,
  bool hasUnresolvedConflict = false,
  ExportPolicyOptions options = const ExportPolicyOptions(),
}) {
  final active = namespaces.where((ns) => !ns.excluded && ns.selected).toList();
  final activeIds = active.map((ns) => ns.id).toSet();
  final scoped = entries.where((e) => activeIds.contains(e.namespaceId));

  var translated = 0;
  var kept = 0;
  var pending = 0;
  var failed = 0;
  for (final entry in scoped) {
    switch (entry.status) {
      case EntryStatus.done:
        translated++;
      case EntryStatus.kept:
      case EntryStatus.cache:
        kept++;
      case EntryStatus.wait:
      case EntryStatus.running:
        pending++;
      case EntryStatus.invalid:
        failed++;
      case EntryStatus.fallback:
      case EntryStatus.confirm:
      case EntryStatus.empty:
        break;
    }
  }

  return ExportGate.evaluateAggregate(
    activeNamespaceCount: active.length,
    jsonErrorNamespaceCount: active
        .where((ns) => ns.state == NamespaceState.jsonError)
        .length,
    summary: ExportSummary(
      totalKeys: scoped.length,
      translatedKeys: translated,
      keptKeys: kept,
      pendingKeys: pending,
      failedKeys: failed,
    ),
    isTranslating: isTranslating,
    hasUnresolvedConflict: hasUnresolvedConflict,
    options: options,
  );
}

Set<BlockReason> _reasons(ExportVerdict verdict) =>
    verdict is Blocked ? verdict.reasons.toSet() : const {};

void main() {
  final scenarios =
      <
        String,
        ({
          List<NamespaceUnit> namespaces,
          List<TranslationEntry> entries,
          bool isTranslating,
          bool conflict,
          ExportPolicyOptions options,
        })
      >{
        'clean project': (
          namespaces: [_ns()],
          entries: [_entry('a', EntryStatus.done)],
          isTranslating: false,
          conflict: false,
          options: const ExportPolicyOptions(),
        ),
        'run in flight': (
          namespaces: [_ns()],
          entries: [_entry('a', EntryStatus.done)],
          isTranslating: true,
          conflict: false,
          options: const ExportPolicyOptions(),
        ),
        'nothing selected': (
          namespaces: [_ns(excluded: true)],
          entries: [_entry('a', EntryStatus.done)],
          isTranslating: false,
          conflict: false,
          options: const ExportPolicyOptions(),
        ),
        'json error namespace': (
          namespaces: [_ns(state: NamespaceState.jsonError)],
          entries: [_entry('a', EntryStatus.done)],
          isTranslating: false,
          conflict: false,
          options: const ExportPolicyOptions(),
        ),
        'unresolved conflict': (
          namespaces: [_ns()],
          entries: [_entry('a', EntryStatus.done)],
          isTranslating: false,
          conflict: true,
          options: const ExportPolicyOptions(),
        ),
        'validation failure': (
          namespaces: [_ns()],
          entries: [_entry('a', EntryStatus.invalid)],
          isTranslating: false,
          conflict: false,
          options: const ExportPolicyOptions(),
        ),
        'pending entries with the policy off': (
          namespaces: [_ns()],
          entries: [_entry('a', EntryStatus.wait)],
          isTranslating: false,
          conflict: false,
          options: const ExportPolicyOptions(allowPendingEntries: false),
        ),
        'everything wrong at once': (
          namespaces: [_ns(state: NamespaceState.jsonError)],
          entries: [
            _entry('a', EntryStatus.invalid),
            _entry('b', EntryStatus.wait),
          ],
          isTranslating: true,
          conflict: true,
          options: const ExportPolicyOptions(allowPendingEntries: false),
        ),
      };

  group('ExportGate.evaluateAggregate', () {
    scenarios.forEach((name, s) {
      test('agrees with evaluate — $name', () {
        final rows = ExportGate.evaluate(
          namespaces: s.namespaces,
          entries: s.entries,
          isTranslating: s.isTranslating,
          hasUnresolvedConflict: s.conflict,
          options: s.options,
        );
        final aggregate = _aggregateOf(
          namespaces: s.namespaces,
          entries: s.entries,
          isTranslating: s.isTranslating,
          hasUnresolvedConflict: s.conflict,
          options: s.options,
        );

        expect(aggregate.runtimeType, rows.runtimeType);
        expect(_reasons(aggregate), _reasons(rows));
      });
    });

    test('carries the summary through when it allows the export', () {
      final verdict = ExportGate.evaluateAggregate(
        activeNamespaceCount: 2,
        jsonErrorNamespaceCount: 0,
        summary: const ExportSummary(
          totalKeys: 10,
          translatedKeys: 7,
          keptKeys: 3,
          pendingKeys: 0,
          failedKeys: 0,
        ),
        isTranslating: false,
      );

      expect(verdict, isA<Allowed>());
      expect((verdict as Allowed).summary.totalKeys, 10);
      expect(verdict.summary.translatedKeys, 7);
    });
  });
}
