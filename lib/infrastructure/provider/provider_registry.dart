import '../../domain/provider/translation_provider.dart';
import 'gemini_provider.dart';

/// The translation engines this build exposes.
///
/// MVP ships Gemini only (PRODUCT.md 6). The other three arrive in Phase 8 and
/// slot in here without anything else changing.
abstract final class ProviderRegistry {
  static List<TranslationProvider> available() => [GeminiProvider()];

  static TranslationProvider byId(String id) {
    for (final provider in available()) {
      if (provider.id == id) return provider;
    }
    throw ArgumentError.value(id, 'id', '등록되지 않은 번역 엔진입니다');
  }

  static String get defaultProviderId => available().first.id;
}
