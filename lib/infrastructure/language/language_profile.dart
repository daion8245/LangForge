/// One target language as described by `assets/data/language_profiles.json`.
///
/// TECHNICAL.md 3.6 — adding a language is an asset edit, not a code edit.
class LanguageProfile {
  const LanguageProfile({
    required this.displayName,
    required this.mc,
    required this.outputFile,
    required this.codes,
    required this.aliases,
  });

  /// Shown in the picker: 한국어, English (US), 日本語.
  final String displayName;

  /// Minecraft code, and the app's internal code: `ko_kr`.
  final String mc;

  /// Lang file the export writes: `ko_kr.json`.
  final String outputFile;

  /// providerId -> that provider's code for this language.
  final Map<String, String> codes;

  /// Everything that normalizes to [mc].
  final List<String> aliases;

  factory LanguageProfile.fromJson(Map<String, dynamic> json) {
    final mc = json['mc'] as String;
    return LanguageProfile(
      displayName: json['displayName'] as String? ?? mc,
      mc: mc,
      outputFile: json['outputFile'] as String? ?? '$mc.json',
      codes: {
        for (final entry
            in (json['codes'] as Map<String, dynamic>? ?? {}).entries)
          entry.key: '${entry.value}',
      },
      aliases: [
        for (final alias in json['aliases'] as List<dynamic>? ?? const [])
          '$alias',
      ],
    );
  }

  /// `-` when the provider has no code for this language.
  String codeFor(String providerId) => codes[providerId] ?? '-';
}
