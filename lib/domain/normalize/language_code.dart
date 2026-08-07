abstract final class LanguageCodeNormalizer {
  static const Map<String, String> _knownAliases = {
    'ko-kr': 'ko_kr',
    'ko_kr': 'ko_kr',
    'korean': 'ko_kr',
    '한국어': 'ko_kr',
    'ko': 'ko_kr',
    'en-us': 'en_us',
    'en_us': 'en_us',
    'english': 'en_us',
    'en': 'en_us',
    'en-gb': 'en_gb',
    'en_gb': 'en_gb',
    'ja-jp': 'ja_jp',
    'ja_jp': 'ja_jp',
    'japanese': 'ja_jp',
    '일본어': 'ja_jp',
    'ja': 'ja_jp',
    'de-de': 'de_de',
    'de_de': 'de_de',
    'german': 'de_de',
    '독일어': 'de_de',
    'de': 'de_de',
    'fr-fr': 'fr_fr',
    'fr_fr': 'fr_fr',
    'french': 'fr_fr',
    '프랑스어': 'fr_fr',
    'fr': 'fr_fr',
  };

  /// Normalizes a language code (e.g. `ko-KR`, `KO_KR`, `Korean`) into standard Minecraft format (`ko_kr`).
  static String normalize(String rawCode) {
    if (rawCode.isEmpty) return 'en_us';

    final trimmed = rawCode.trim();
    final lowered = trimmed.toLowerCase();

    // 1. Direct alias match
    if (_knownAliases.containsKey(lowered)) {
      return _knownAliases[lowered]!;
    }

    // 2. Normalize delimiters (- . space -> _)
    final unified = lowered.replaceAll(RegExp(r'[-.\s]+'), '_');
    if (_knownAliases.containsKey(unified)) {
      return _knownAliases[unified]!;
    }

    // 3. xx_yy format match
    if (RegExp(r'^[a-z]{2,3}_[a-z]{2,3}$').hasMatch(unified)) {
      return unified;
    }

    return unified;
  }
}
