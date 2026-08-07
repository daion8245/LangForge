import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/validation/translation_result_checks.dart';

void main() {
  group('TranslationResultChecks', () {
    test('batchEchoRetryThreshold catches a 48/50 (96%) echo batch', () {
      expect(
        48 / 50,
        greaterThanOrEqualTo(TranslationResultChecks.batchEchoRetryThreshold),
      );
      expect(TranslationResultChecks.batchEchoRetryThreshold, lessThan(1.0));
    });

    test('isEmptyTranslation only when source is non-empty', () {
      expect(TranslationResultChecks.isEmptyTranslation('Hi', ''), isTrue);
      expect(TranslationResultChecks.isEmptyTranslation('', ''), isFalse);
    });

    test('hasAbnormalControlChars ignores tab and newlines', () {
      expect(
        TranslationResultChecks.hasAbnormalControlChars('ok\tline\n'),
        isFalse,
      );
      expect(
        TranslationResultChecks.hasAbnormalControlChars('bad\x00'),
        isTrue,
      );
      expect(
        TranslationResultChecks.hasAbnormalControlChars('bad\x7F'),
        isTrue,
      );
    });

    test('isExcessivelyLong uses the 10× multiplier', () {
      expect(TranslationResultChecks.isExcessivelyLong('ab', 'a' * 21), isTrue);
      expect(
        TranslationResultChecks.isExcessivelyLong('ab', 'a' * 20),
        isFalse,
      );
    });
  });
}
