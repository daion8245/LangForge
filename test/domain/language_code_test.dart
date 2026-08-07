import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/normalize/language_code.dart';

void main() {
  group('LanguageCodeNormalizer Tests', () {
    test('Normalizes various Korean language code formats to ko_kr', () {
      expect(LanguageCodeNormalizer.normalize('ko-KR'), equals('ko_kr'));
      expect(LanguageCodeNormalizer.normalize('KO_KR'), equals('ko_kr'));
      expect(LanguageCodeNormalizer.normalize('Korean'), equals('ko_kr'));
      expect(LanguageCodeNormalizer.normalize('한국어'), equals('ko_kr'));
      expect(LanguageCodeNormalizer.normalize('ko'), equals('ko_kr'));
    });

    test('Normalizes English, Japanese, German, and French', () {
      expect(LanguageCodeNormalizer.normalize('en-US'), equals('en_us'));
      expect(LanguageCodeNormalizer.normalize('en-GB'), equals('en_gb'));
      expect(LanguageCodeNormalizer.normalize('ja-JP'), equals('ja_jp'));
      expect(LanguageCodeNormalizer.normalize('de-DE'), equals('de_de'));
      expect(LanguageCodeNormalizer.normalize('fr-FR'), equals('fr_fr'));
    });
  });
}
