import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/protection/multiset.dart';

void main() {
  group('MultisetValidator Tests', () {
    test('Passes matching token multisets', () {
      const source = '%s hit %s';
      const target = '%s이 %s를 때림';
      final result = MultisetValidator.validate(source, target);

      expect(result.isMatch, isTrue);
      expect(result.tokenChips.length, equals(1));
      expect(result.tokenChips.first.token, equals('%s'));
      expect(result.tokenChips.first.sourceCount, equals(2));
      expect(result.tokenChips.first.targetCount, equals(2));
    });

    test('Fails mismatched token types (%s x2 vs %s x1 %d x1)', () {
      const source = '%s hit %s';
      const target = '%s이 %d를 때림';
      final result = MultisetValidator.validate(source, target);

      expect(result.isMatch, isFalse);
    });

    test(r'Fails missing positional token (%1$s died %2$s vs %1$s died)', () {
      const source = r'%1$s died %2$s';
      const target = r'%1$s님이 사망';
      final result = MultisetValidator.validate(source, target);

      expect(result.isMatch, isFalse);
    });

    test('Passes formatting codes §a and §r matching', () {
      const source = '§aReady§r';
      const target = '§a준비§r';
      final result = MultisetValidator.validate(source, target);

      expect(result.isMatch, isTrue);
    });
  });
}
