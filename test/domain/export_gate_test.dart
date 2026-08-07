import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/model/entry_status.dart';
import 'package:langforge/domain/model/translation_entry.dart';
import 'package:langforge/domain/policy/export_gate.dart';

NamespaceUnit ns({
  String id = 'ns1',
  NamespaceState state = NamespaceState.ok,
  bool excluded = false,
}) {
  return NamespaceUnit(
    id: id,
    inputFileId: 'file1',
    name: 'quark',
    state: state,
    excluded: excluded,
    keyCount: 1,
  );
}

TranslationEntry entry({
  String id = 'e1',
  String namespaceId = 'ns1',
  EntryStatus status = EntryStatus.done,
}) {
  return TranslationEntry(
    id: id,
    namespaceId: namespaceId,
    key: 'item.oak',
    keyOrder: 1,
    sourceText: 'Oak Item',
    status: status,
  );
}

void main() {
  group('ExportGate Pre-checking Tests', () {
    test('1. Allows export when all criteria are satisfied', () {
      final verdict = ExportGate.evaluate(
        namespaces: [ns()],
        entries: [entry()],
        isTranslating: false,
      );

      expect(verdict, isA<Allowed>());
      expect((verdict as Allowed).summary.totalKeys, equals(1));
      expect(verdict.summary.translatedKeys, equals(1));
    });

    test('2. Blocks export when translation is currently running', () {
      final verdict = ExportGate.evaluate(
        namespaces: [ns()],
        entries: [entry()],
        isTranslating: true,
      );

      expect(verdict, isA<Blocked>());
      expect(
        (verdict as Blocked).reasons,
        contains(BlockReason.translationRunning),
      );
    });

    test('3. Blocks export when namespace has jsonError', () {
      final verdict = ExportGate.evaluate(
        namespaces: [ns(state: NamespaceState.jsonError)],
        entries: [entry()],
        isTranslating: false,
      );

      expect(verdict, isA<Blocked>());
      expect((verdict as Blocked).reasons, contains(BlockReason.jsonError));
    });

    test('4. Blocks on validation failure by default', () {
      final verdict = ExportGate.evaluate(
        namespaces: [ns()],
        entries: [entry(status: EntryStatus.invalid)],
        isTranslating: false,
      );

      expect(verdict, isA<Blocked>());
      expect(
        (verdict as Blocked).reasons,
        contains(BlockReason.validationFailed),
      );
    });

    test('5. Allows validation failures when the policy permits it', () {
      final verdict = ExportGate.evaluate(
        namespaces: [ns()],
        entries: [entry(status: EntryStatus.invalid)],
        isTranslating: false,
        options: const ExportPolicyOptions(allowValidationFailed: true),
      );

      expect(verdict, isA<Allowed>());
      expect((verdict as Allowed).summary.failedKeys, equals(1));
    });

    test('6. Pending entries are exported as source text by default', () {
      final verdict = ExportGate.evaluate(
        namespaces: [ns()],
        entries: [entry(status: EntryStatus.wait)],
        isTranslating: false,
      );

      expect(verdict, isA<Allowed>());
      expect((verdict as Allowed).summary.pendingKeys, equals(1));
    });

    test('7. Blocks pending entries when the policy forbids them', () {
      final verdict = ExportGate.evaluate(
        namespaces: [ns()],
        entries: [entry(status: EntryStatus.wait)],
        isTranslating: false,
        options: const ExportPolicyOptions(allowPendingEntries: false),
      );

      expect(verdict, isA<Blocked>());
      expect(
        (verdict as Blocked).reasons,
        contains(BlockReason.pendingEntries),
      );
    });

    test('8. Blocks when every namespace is excluded', () {
      final verdict = ExportGate.evaluate(
        namespaces: [ns(excluded: true)],
        entries: [entry()],
        isTranslating: false,
      );

      expect(verdict, isA<Blocked>());
      expect(
        (verdict as Blocked).reasons,
        contains(BlockReason.noNamespaceSelected),
      );
    });

    test('9. Reports the two mandatory reasons it is told about', () {
      final verdict = ExportGate.evaluate(
        namespaces: [ns()],
        entries: [entry()],
        isTranslating: false,
        hasUnresolvedConflict: true,
        hasCorruptTargetFile: true,
      );

      expect(verdict, isA<Blocked>());
      expect(
        (verdict as Blocked).reasons,
        containsAll([
          BlockReason.unresolvedConflict,
          BlockReason.corruptTargetFile,
        ]),
      );
    });

    test('10. Excluded namespaces do not contribute to the summary', () {
      final verdict = ExportGate.evaluate(
        namespaces: [
          ns(),
          ns(id: 'ns2', excluded: true),
        ],
        entries: [
          entry(),
          entry(id: 'e2', namespaceId: 'ns2'),
        ],
        isTranslating: false,
      );

      expect(verdict, isA<Allowed>());
      expect((verdict as Allowed).summary.totalKeys, equals(1));
    });
  });
}
