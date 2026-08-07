import 'language_code.dart';

/// Maps Minecraft language codes (`en_us`) to each translation provider's API
/// codes. Values mirror `assets/data/language_profiles.json` `codes` maps.
///
/// Keep this table in sync with that asset when adding languages.
abstract final class ProviderLanguageCode {
  static const Map<String, Map<String, String>> _byMc = {
    'ko_kr': {
      'google': 'ko',
      'papago': 'ko',
      'deepl': 'KO',
      'gemini': 'Korean',
    },
    'en_us': {
      'google': 'en',
      'papago': 'en',
      'deepl': 'EN-US',
      'gemini': 'English',
    },
    'en_gb': {
      'google': 'en',
      'papago': 'en',
      'deepl': 'EN-GB',
      'gemini': 'English',
    },
    'ja_jp': {
      'google': 'ja',
      'papago': 'ja',
      'deepl': 'JA',
      'gemini': 'Japanese',
    },
    'de_de': {
      'google': 'de',
      'papago': 'de',
      'deepl': 'DE',
      'gemini': 'German',
    },
    'fr_fr': {
      'google': 'fr',
      'papago': 'fr',
      'deepl': 'FR',
      'gemini': 'French',
    },
  };

  /// Returns the provider-specific language code for a Minecraft (or alias)
  /// code. Falls back to a best-effort heuristic when the profile is unknown.
  static String map(String providerId, String mcOrAlias) {
    final mc = LanguageCodeNormalizer.normalize(mcOrAlias);
    final mapped = _byMc[mc]?[providerId];
    if (mapped != null) return mapped;
    return _heuristic(providerId, mc);
  }

  static String _heuristic(String providerId, String mc) {
    final primary = mc.split('_').first;
    switch (providerId) {
      case 'deepl':
        return primary.toUpperCase();
      case 'gemini':
        return mc;
      default:
        return primary;
    }
  }
}
