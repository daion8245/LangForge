import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/normalize/provider_language_code.dart';

void main() {
  test('Maps Minecraft codes to each provider API code', () {
    expect(ProviderLanguageCode.map('deepl', 'en_us'), equals('EN-US'));
    expect(ProviderLanguageCode.map('deepl', 'ko_kr'), equals('KO'));
    expect(ProviderLanguageCode.map('google', 'en_us'), equals('en'));
    expect(ProviderLanguageCode.map('papago', 'ja_jp'), equals('ja'));
    expect(ProviderLanguageCode.map('gemini', 'ko_kr'), equals('Korean'));
  });

  test('Normalizes aliases before mapping', () {
    expect(ProviderLanguageCode.map('google', 'KO-KR'), equals('ko'));
    expect(ProviderLanguageCode.map('deepl', 'en-US'), equals('EN-US'));
  });
}
