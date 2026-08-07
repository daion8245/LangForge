import '../../domain/provider/translation_provider.dart';
import 'deepl_provider.dart';
import 'gemini_provider.dart';
import 'google_provider.dart';
import 'papago_provider.dart';
import 'provider_catalog.dart';
import 'provider_definition.dart';

/// The translation engines this build exposes.
///
/// All four adapters share [TranslationProvider]; swapping engines must not
/// change token protection, validation, merge, or export (계획서 §3.3).
abstract final class ProviderRegistry {
  static List<TranslationProvider>? _cached;

  /// Builds providers from the loaded [ProviderCatalog].
  ///
  /// Call after [ProviderCatalog.load] (bootstrap). Safe to call again after
  /// catalog reload — the cache is rebuilt.
  static void initialize() {
    _cached = ProviderCatalog.all.map(_fromDefinition).toList(growable: false);
  }

  static List<TranslationProvider> available() {
    final cached = _cached;
    if (cached != null) return cached;
    // Lazy init for tests that load the catalog but skip bootstrap.
    if (ProviderCatalog.isLoaded) {
      initialize();
      return _cached!;
    }
    throw StateError(
      'ProviderRegistry.initialize() requires ProviderCatalog.load() first',
    );
  }

  static TranslationProvider byId(String id) {
    for (final provider in available()) {
      if (provider.id == id) return provider;
    }
    throw ArgumentError.value(id, 'id', '등록되지 않은 번역 엔진입니다');
  }

  static String get defaultProviderId => available().first.id;

  static TranslationProvider _fromDefinition(ProviderDefinition definition) {
    switch (definition.id) {
      case 'gemini':
        return GeminiProvider(definition: definition);
      case 'deepl':
        return DeepLProvider(definition: definition);
      case 'google':
        return GoogleProvider(definition: definition);
      case 'papago':
        return PapagoProvider(definition: definition);
      default:
        throw ArgumentError.value(definition.id, 'id', '지원하지 않는 번역 엔진입니다');
    }
  }

  /// Clears the provider cache. Intended for tests only.
  static void resetForTest() {
    _cached = null;
  }
}
