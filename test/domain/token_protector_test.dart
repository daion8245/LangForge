import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/protection/token_protector.dart';

void main() {
  group('TokenProtector Tests', () {
    test('Protects variables with U+2063 invisible placeholders', () {
      const text = r'§aWelcome %1$s to {{server}}!§r';
      final protected = TokenProtector.protect(text);

      expect(protected.tokens, equals(['§a', r'%1$s', '{{server}}', '§r']));
      expect(protected.masked, contains('\u{2063}LF0\u{2063}'));
      expect(protected.masked, contains('\u{2063}LF1\u{2063}'));
      expect(protected.masked, contains('\u{2063}LF2\u{2063}'));
      expect(protected.masked, contains('\u{2063}LF3\u{2063}'));
    });

    test(
      'Restores tokens correctly when translation engine preserves placeholders',
      () {
        const text = r'§aWelcome %1$s to {{server}}!§r';
        final protected = TokenProtector.protect(text);

        final translatedWithPlaceholders =
            '\u{2063}LF0\u{2063}\u{2063}LF2\u{2063} 서버에 오신 것을 환영합니다, \u{2063}LF1\u{2063}님!\u{2063}LF3\u{2063}';
        final restored = TokenProtector.restore(
          protected,
          translatedWithPlaceholders,
        );

        expect(restored, isNotNull);
        expect(restored, equals(r'§a{{server}} 서버에 오신 것을 환영합니다, %1$s님!§r'));
      },
    );

    test('Detects corrupted or deleted placeholders and returns null', () {
      const text = 'Hello %s!';
      final protected = TokenProtector.protect(text);

      const corruptedTranslated =
          '안녕하세요!'; // Placeholder U+2063LF0U+2063 removed by engine
      final restored = TokenProtector.restore(protected, corruptedTranslated);

      expect(restored, isNull);
    });

    test('Detects extra or leftover placeholders and returns null', () {
      const text = 'Hello %s!';
      final protected = TokenProtector.protect(text);

      // Engine restored LF0, but also introduced an invented LF99 placeholder
      const extraPlaceholderText = '안녕하세요 %s! \u{2063}LF99\u{2063}';
      final restored = TokenProtector.restore(protected, extraPlaceholderText);

      expect(restored, isNull);
    });

    test(
      'Roundtrip protection and restoration preserves exact string when unchanged',
      () {
        const text = r'§x§F§F§A§A§0§0Item %1$s count: %d%%§r';
        final protected = TokenProtector.protect(text);
        final restored = TokenProtector.restore(protected, protected.masked);

        expect(restored, equals(text));
      },
    );
  });
}
