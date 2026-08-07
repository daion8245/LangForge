import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/model/entry_status.dart';
import 'package:langforge/domain/model/translation_entry.dart';
import 'package:langforge/domain/validation/conflict_detector.dart';

void main() {
  group('ConflictDetector Tests', () {
    final testNamespaces = [
      const NamespaceUnit(
        id: 'ns1',
        inputFileId: 'f1',
        name: 'quark',
        state: NamespaceState.ok,
      ),
    ];

    test(
      '1. Detects conflicts when same namespace and key have differing source texts',
      () {
        final testEntries = [
          const TranslationEntry(
            id: 'e1',
            namespaceId: 'ns1',
            key: 'block.oak_hedge',
            keyOrder: 1,
            sourceText: 'Oak Hedge',
            status: EntryStatus.wait,
          ),
          const TranslationEntry(
            id: 'e2',
            namespaceId: 'ns1',
            key: 'block.oak_hedge',
            keyOrder: 2,
            sourceText: 'Oak Hedge Modified', // Differing source text
            status: EntryStatus.wait,
          ),
        ];

        final conflicts = ConflictDetector.detect(
          namespaces: testNamespaces,
          entries: testEntries,
        );

        expect(conflicts.length, equals(1));
        expect(conflicts.first.key, equals('block.oak_hedge'));
        expect(conflicts.first.sourceTextA, equals('Oak Hedge'));
        expect(conflicts.first.sourceTextB, equals('Oak Hedge Modified'));
      },
    );

    // The case AC-8.3 is actually about: each JAR gets its own namespace row,
    // and entries are unique on (namespace_id, key), so grouping by id alone
    // could never see this.
    const twoJars = [
      NamespaceUnit(
        id: 'nsA',
        inputFileId: 'jarA',
        name: 'quark',
        state: NamespaceState.ok,
      ),
      NamespaceUnit(
        id: 'nsB',
        inputFileId: 'jarB',
        name: 'quark',
        state: NamespaceState.ok,
      ),
    ];

    test('2. Two JARs sharing a namespace and key with different source text '
        'conflict', () {
      const entries = [
        TranslationEntry(
          id: 'a1',
          namespaceId: 'nsA',
          key: 'item.wand',
          keyOrder: 0,
          sourceText: 'Wand',
          status: EntryStatus.wait,
        ),
        TranslationEntry(
          id: 'b1',
          namespaceId: 'nsB',
          key: 'item.wand',
          keyOrder: 0,
          sourceText: 'Magic Wand',
          status: EntryStatus.wait,
        ),
      ];

      final conflicts = ConflictDetector.detect(
        namespaces: twoJars,
        entries: entries,
      );

      expect(conflicts.length, equals(1));
      expect(conflicts.first.namespaceName, equals('quark'));
      expect(conflicts.first.sourceTextA, equals('Wand'));
      expect(conflicts.first.sourceTextB, equals('Magic Wand'));
    });

    test('3. Identical source text across JARs is not a conflict (AC-8.4)', () {
      const entries = [
        TranslationEntry(
          id: 'a1',
          namespaceId: 'nsA',
          key: 'item.wand',
          keyOrder: 0,
          sourceText: 'Wand',
          status: EntryStatus.wait,
        ),
        TranslationEntry(
          id: 'b1',
          namespaceId: 'nsB',
          key: 'item.wand',
          keyOrder: 0,
          sourceText: 'Wand',
          status: EntryStatus.wait,
        ),
      ];

      expect(
        ConflictDetector.detect(namespaces: twoJars, entries: entries),
        isEmpty,
      );
    });

    test(
      '4. The same key in differently named namespaces is not a conflict',
      () {
        const namespaces = [
          NamespaceUnit(
            id: 'nsA',
            inputFileId: 'jarA',
            name: 'quark',
            state: NamespaceState.ok,
          ),
          NamespaceUnit(
            id: 'nsB',
            inputFileId: 'jarB',
            name: 'zeta',
            state: NamespaceState.ok,
          ),
        ];
        const entries = [
          TranslationEntry(
            id: 'a1',
            namespaceId: 'nsA',
            key: 'item.wand',
            keyOrder: 0,
            sourceText: 'Wand',
            status: EntryStatus.wait,
          ),
          TranslationEntry(
            id: 'b1',
            namespaceId: 'nsB',
            key: 'item.wand',
            keyOrder: 0,
            sourceText: 'Magic Wand',
            status: EntryStatus.wait,
          ),
        ];

        expect(
          ConflictDetector.detect(namespaces: namespaces, entries: entries),
          isEmpty,
        );
      },
    );
  });
}
