import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/policy/conflict_preselector.dart';
import 'package:langforge/domain/policy/conflict_priority.dart';
import 'package:langforge/domain/validation/conflict_detector.dart';

ConflictParticipant _p({
  required String id,
  required int order,
  required String source,
  String file = 'f',
}) {
  return ConflictParticipant(
    entryId: id,
    namespaceId: 'ns-$file',
    inputFileId: file,
    addOrder: order,
    sourceText: source,
  );
}

ConflictItem _item(List<ConflictParticipant> participants) {
  return ConflictItem(
    namespaceName: 'quark',
    key: 'item.name',
    participants: participants,
  );
}

void main() {
  group('ConflictPreselector', () {
    test('manual never preselects', () {
      final conflict = _item([
        _p(id: 'a', order: 0, source: 'short'),
        _p(id: 'b', order: 1, source: 'much longer source'),
      ]);
      expect(
        ConflictPreselector.suggest(
          conflict: conflict,
          priority: ConflictPriority.manual,
        ),
        isNull,
      );
    });

    test('preferFirstAdded picks the earliest addOrder', () {
      final conflict = _item([
        _p(id: 'second', order: 1, source: 'B'),
        _p(id: 'first', order: 0, source: 'A'),
      ]);
      expect(
        ConflictPreselector.suggest(
          conflict: conflict,
          priority: ConflictPriority.preferFirstAdded,
        )?.entryId,
        'first',
      );
    });

    test('preferLastAdded picks the latest addOrder', () {
      final conflict = _item([
        _p(id: 'first', order: 0, source: 'A'),
        _p(id: 'second', order: 1, source: 'B'),
      ]);
      expect(
        ConflictPreselector.suggest(
          conflict: conflict,
          priority: ConflictPriority.preferLastAdded,
        )?.entryId,
        'second',
      );
    });

    test('preferLongerSource picks the longer string', () {
      final conflict = _item([
        _p(id: 'short', order: 0, source: 'hi'),
        _p(id: 'long', order: 1, source: 'hello there'),
      ]);
      expect(
        ConflictPreselector.suggest(
          conflict: conflict,
          priority: ConflictPriority.preferLongerSource,
        )?.entryId,
        'long',
      );
    });

    test('preferShorterSource picks the shorter string', () {
      final conflict = _item([
        _p(id: 'short', order: 0, source: 'hi'),
        _p(id: 'long', order: 1, source: 'hello there'),
      ]);
      expect(
        ConflictPreselector.suggest(
          conflict: conflict,
          priority: ConflictPriority.preferShorterSource,
        )?.entryId,
        'short',
      );
    });

    test('length ties fall back to preferFirstAdded', () {
      final conflict = _item([
        _p(id: 'a', order: 0, source: 'same'),
        _p(id: 'b', order: 1, source: 'same'),
      ]);
      expect(
        ConflictPreselector.suggest(
          conflict: conflict,
          priority: ConflictPriority.preferLongerSource,
        )?.entryId,
        'a',
      );
      expect(
        ConflictPreselector.suggest(
          conflict: conflict,
          priority: ConflictPriority.preferShorterSource,
        )?.entryId,
        'a',
      );
    });

    test('addOrder ties break on entryId lexicographic order', () {
      final conflict = _item([
        _p(id: 'z-entry', order: 0, source: 'A'),
        _p(id: 'a-entry', order: 0, source: 'B'),
      ]);
      expect(
        ConflictPreselector.suggest(
          conflict: conflict,
          priority: ConflictPriority.preferFirstAdded,
        )?.entryId,
        'a-entry',
      );
    });

    test('fromWire falls back to manual for unknown values', () {
      expect(ConflictPriority.fromWire('nope'), ConflictPriority.manual);
      expect(
        ConflictPriority.fromWire('preferFirstAdded'),
        ConflictPriority.preferFirstAdded,
      );
    });
  });
}
