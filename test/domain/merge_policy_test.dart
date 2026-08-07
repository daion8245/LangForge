import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/model/entry_status.dart';
import 'package:langforge/domain/model/translation_entry.dart';
import 'package:langforge/domain/policy/merge_policy.dart';

const String source = 'Original Source';

TranslationEntry make({
  String? user,
  String? existing,
  String? fresh,
  bool userEdited = false,
  EntryStatus status = EntryStatus.wait,
}) {
  return TranslationEntry(
    id: 'e1',
    namespaceId: 'ns1',
    key: 'item.test',
    keyOrder: 1,
    sourceText: source,
    userTranslation: user,
    existingTranslation: existing,
    newTranslation: fresh,
    userEdited: userEdited,
    status: status,
  );
}

void main() {
  group('MergePolicy priority order', () {
    test('user edit outranks everything', () {
      expect(
        MergePolicy.resolveFinal(
          make(user: 'USER', existing: 'EXISTING', fresh: 'NEW'),
        ),
        equals('USER'),
      );
    });

    test('existing translation outranks a provider translation', () {
      expect(
        MergePolicy.resolveFinal(make(existing: 'EXISTING', fresh: 'NEW')),
        equals('EXISTING'),
      );
    });

    test('provider translation outranks the source text', () {
      expect(MergePolicy.resolveFinal(make(fresh: 'NEW')), equals('NEW'));
    });

    test('source text is the last resort', () {
      expect(MergePolicy.resolveFinal(make()), equals(source));
    });
  });

  group('MergePolicy empty-value handling', () {
    // A cleared field is a deliberate answer. Treating it as "absent" would
    // resurrect a value the user removed — the exact failure AGENTS.md 2.1
    // forbids.
    test('an empty user edit wins over an existing translation', () {
      expect(
        MergePolicy.resolveFinal(make(user: '', existing: 'EXISTING')),
        equals(''),
      );
    });

    test('an empty user edit wins over a provider translation', () {
      expect(
        MergePolicy.resolveFinal(make(user: '', fresh: 'NEW')),
        equals(''),
      );
    });

    test('an empty user edit wins over the source text', () {
      expect(MergePolicy.resolveFinal(make(user: '')), equals(''));
    });

    test('an empty existing translation wins over a provider translation', () {
      expect(
        MergePolicy.resolveFinal(make(existing: '', fresh: 'NEW')),
        equals(''),
      );
    });

    test('an empty provider translation wins over the source text', () {
      expect(MergePolicy.resolveFinal(make(fresh: '')), equals(''));
    });
  });

  group('MergePolicy full combination matrix', () {
    // Every combination of the three candidate fields being absent, empty, or
    // filled: 3 x 3 x 3 = 27 cases, checked against the priority chain.
    const values = <String?>[null, '', 'VALUE'];

    test('27 combinations resolve to the first present field', () {
      var checked = 0;
      for (final user in values) {
        for (final existing in values) {
          for (final fresh in values) {
            final expected = user ?? existing ?? fresh ?? source;
            expect(
              MergePolicy.resolveFinal(
                make(user: user, existing: existing, fresh: fresh),
              ),
              equals(expected),
              reason: 'user=$user existing=$existing new=$fresh',
            );
            checked++;
          }
        }
      }
      expect(checked, equals(27));
    });
  });

  group('MergePolicy.resolveStatus', () {
    test('a pending user edit shows as 확인 필요', () {
      expect(
        MergePolicy.resolveStatus(
          make(user: 'USER', userEdited: true, status: EntryStatus.wait),
        ),
        equals(EntryStatus.confirm),
      );
    });

    test('an empty user edit still counts as an edit', () {
      expect(
        MergePolicy.resolveStatus(
          make(user: '', userEdited: true, status: EntryStatus.done),
        ),
        equals(EntryStatus.confirm),
      );
    });

    test('an untouched entry keeps its stored status', () {
      expect(
        MergePolicy.resolveStatus(make(fresh: 'NEW', status: EntryStatus.done)),
        equals(EntryStatus.done),
      );
    });

    test('userEdited without a value does not force 확인 필요', () {
      expect(
        MergePolicy.resolveStatus(
          make(fresh: 'NEW', userEdited: true, status: EntryStatus.done),
        ),
        equals(EntryStatus.done),
      );
    });
  });
}
