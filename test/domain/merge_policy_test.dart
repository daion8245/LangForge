import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/model/entry_status.dart';
import 'package:langforge/domain/model/translation_entry.dart';
import 'package:langforge/domain/policy/merge_policy.dart';

const String source = 'Original Source';

TranslationEntry make({
  String? user,
  String? existing,
  String? glossary,
  String? reviewedCache,
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
    glossaryTranslation: glossary,
    reviewedCacheTranslation: reviewedCache,
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
          make(
            user: 'USER',
            existing: 'EXISTING',
            glossary: 'GLOSS',
            reviewedCache: 'CACHE',
            fresh: 'NEW',
          ),
        ),
        equals('USER'),
      );
    });

    test('existing outranks glossary, reviewed cache, and provider', () {
      expect(
        MergePolicy.resolveFinal(
          make(
            existing: 'EXISTING',
            glossary: 'GLOSS',
            reviewedCache: 'CACHE',
            fresh: 'NEW',
          ),
        ),
        equals('EXISTING'),
      );
    });

    test('glossary outranks reviewed cache and provider', () {
      expect(
        MergePolicy.resolveFinal(
          make(glossary: 'GLOSS', reviewedCache: 'CACHE', fresh: 'NEW'),
        ),
        equals('GLOSS'),
      );
    });

    test('reviewed cache outranks provider / auto-cache', () {
      expect(
        MergePolicy.resolveFinal(make(reviewedCache: 'CACHE', fresh: 'NEW')),
        equals('CACHE'),
      );
    });

    test('auto-cache in newTranslation is step 5, not step 4', () {
      expect(
        MergePolicy.resolveFinal(make(fresh: 'AUTO_CACHE')),
        equals('AUTO_CACHE'),
      );
    });

    test('source text is the last resort', () {
      expect(MergePolicy.resolveFinal(make()), equals(source));
    });
  });

  group('MergePolicy empty-value handling', () {
    test('an empty user edit wins over an existing translation', () {
      expect(
        MergePolicy.resolveFinal(make(user: '', existing: 'EXISTING')),
        equals(''),
      );
    });

    test('an empty glossary wins over reviewed cache', () {
      expect(
        MergePolicy.resolveFinal(make(glossary: '', reviewedCache: 'CACHE')),
        equals(''),
      );
    });

    test('an empty reviewed cache wins over provider', () {
      expect(
        MergePolicy.resolveFinal(make(reviewedCache: '', fresh: 'NEW')),
        equals(''),
      );
    });
  });

  group('MergePolicy full combination matrix', () {
    const values = <String?>[null, '', 'VALUE'];

    test('243 combinations resolve to the first present field', () {
      var checked = 0;
      for (final user in values) {
        for (final existing in values) {
          for (final glossary in values) {
            for (final reviewed in values) {
              for (final fresh in values) {
                final expected =
                    user ?? existing ?? glossary ?? reviewed ?? fresh ?? source;
                expect(
                  MergePolicy.resolveFinal(
                    make(
                      user: user,
                      existing: existing,
                      glossary: glossary,
                      reviewedCache: reviewed,
                      fresh: fresh,
                    ),
                  ),
                  equals(expected),
                  reason:
                      'user=$user existing=$existing glossary=$glossary '
                      'reviewed=$reviewed new=$fresh',
                );
                checked++;
              }
            }
          }
        }
      }
      expect(checked, equals(243));
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

    test('an untouched entry keeps its stored status', () {
      expect(
        MergePolicy.resolveStatus(
          make(fresh: 'NEW', status: EntryStatus.cache),
        ),
        equals(EntryStatus.cache),
      );
    });
  });
}
