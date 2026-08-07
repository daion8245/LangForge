import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/validation/conflict_detector.dart';
import 'package:langforge/infrastructure/db/app_database.dart';

void main() {
  group('ConflictDetector Tests', () {
    final now = DateTime.now();

    final testNamespaces = [
      Namespace(
        id: 'ns1',
        inputFileId: 'f1',
        name: 'quark',
        state: 'ok',
        excluded: false,
        selected: true,
        keyCount: 2,
      ),
    ];

    test(
      '1. Detects conflicts when same namespace and key have differing source texts',
      () {
        final testEntries = [
          Entry(
            id: 'e1',
            namespaceId: 'ns1',
            key: 'block.oak_hedge',
            keyOrder: 1,
            sourceText: 'Oak Hedge',
            status: 'wait',
            userEdited: false,
            updatedAt: now,
          ),
          Entry(
            id: 'e2',
            namespaceId: 'ns1',
            key: 'block.oak_hedge',
            keyOrder: 2,
            sourceText: 'Oak Hedge Modified', // Differing source text
            status: 'wait',
            userEdited: false,
            updatedAt: now,
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
  });
}
