import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/protection/token_pattern.dart';

void main() {
  group('TokenPattern Order & Matching Tests', () {
    test('Matches HEX color §x§F§F§A§A§0§0 as single token', () {
      const text = '§x§F§F§A§A§0§0Ready to load§r';
      final matches = tokenPattern
          .allMatches(text)
          .map((m) => m.group(0))
          .toList();
      expect(matches, contains('§x§F§F§A§A§0§0'));
      expect(matches, contains('§r'));
    });

    test(r'Matches positional printf %1$s before %s', () {
      const text = r'%1$s died whilst trying to escape %2$s';
      final matches = tokenPattern
          .allMatches(text)
          .map((m) => m.group(0))
          .toList();
      expect(matches, equals([r'%1$s', r'%2$s']));
    });

    test('Matches double braces {{name}} before single braces {name}', () {
      const text = 'Welcome, {{name}}!';
      final matches = tokenPattern
          .allMatches(text)
          .map((m) => m.group(0))
          .toList();
      expect(matches, equals(['{{name}}']));
    });

    test('Matches escaped percent %%', () {
      const text = 'Progress: 50%% complete';
      final matches = tokenPattern
          .allMatches(text)
          .map((m) => m.group(0))
          .toList();
      expect(matches, equals(['%%']));
    });
  });
}
