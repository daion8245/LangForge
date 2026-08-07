import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/model/entry_status.dart';
import 'package:langforge/domain/validation/existing_translation_classifier.dart';

void main() {
  group('ExistingTranslationClassifier', () {
    test('A sound translation is kept without a warning', () {
      final verdict = ExistingTranslationClassifier.classify(
        sourceText: 'Oak Hedge',
        existingText: '참나무 산울타리',
      );

      expect(verdict.status, equals(EntryStatus.kept));
      expect(verdict.warning, isNull);
    });

    test('A missing translation waits', () {
      expect(
        ExistingTranslationClassifier.classify(
          sourceText: 'Oak Hedge',
          existingText: null,
        ).status,
        equals(EntryStatus.wait),
      );
    });

    test('An empty translation for a real source waits', () {
      expect(
        ExistingTranslationClassifier.classify(
          sourceText: 'Oak Hedge',
          existingText: '',
        ).status,
        equals(EntryStatus.wait),
      );
    });

    test('An empty source is pinned to 빈 문자열 유지', () {
      // These must never be sent to a provider (TECHNICAL.md 5.4).
      expect(
        ExistingTranslationClassifier.classify(
          sourceText: '',
          existingText: '',
        ).status,
        equals(EntryStatus.empty),
      );
      expect(
        ExistingTranslationClassifier.classify(
          sourceText: '',
          existingText: null,
        ).status,
        equals(EntryStatus.empty),
      );
    });

    test('A translation identical to the source is kept, but flagged', () {
      final verdict = ExistingTranslationClassifier.classify(
        sourceText: 'Quark',
        existingText: 'Quark',
      );

      expect(verdict.status, equals(EntryStatus.kept));
      expect(verdict.warning, equals(ExistingTranslationWarning.sameAsSource));
    });

    test('A token mismatch needs the user to confirm it', () {
      final verdict = ExistingTranslationClassifier.classify(
        sourceText: '%s hit %s',
        existingText: '%s이 때림',
      );

      expect(verdict.status, equals(EntryStatus.confirm));
      expect(verdict.warning, equals(ExistingTranslationWarning.tokenMismatch));
    });

    test('Matching tokens in a different order still pass', () {
      final verdict = ExistingTranslationClassifier.classify(
        sourceText: '%1\$s died to %2\$s',
        existingText: '%2\$s에게 %1\$s 사망',
      );

      expect(verdict.status, equals(EntryStatus.kept));
    });

    test('A corrupt target file discards every value in it', () {
      final verdict = ExistingTranslationClassifier.classify(
        sourceText: 'Oak Hedge',
        existingText: '참나무 산울타리',
        targetFileCorrupt: true,
      );

      expect(verdict.status, equals(EntryStatus.wait));
      expect(
        verdict.warning,
        equals(ExistingTranslationWarning.targetFileCorrupt),
      );
    });

    test('Stale keys are the ones the source no longer has', () {
      final stale = ExistingTranslationClassifier.findStaleKeys(
        sourceKeys: ['a', 'b'],
        existingKeys: ['a', 'b', 'removed.one', 'removed.two'],
      );

      expect(stale, equals(['removed.one', 'removed.two']));
    });

    test('No stale keys when the target is a subset of the source', () {
      expect(
        ExistingTranslationClassifier.findStaleKeys(
          sourceKeys: ['a', 'b', 'c'],
          existingKeys: ['a'],
        ),
        isEmpty,
      );
    });
  });
}
