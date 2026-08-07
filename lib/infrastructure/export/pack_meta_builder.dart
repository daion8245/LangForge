import 'dart:convert';

class MinecraftVersionInfo {
  const MinecraftVersionInfo({required this.version, required this.packFormat});

  factory MinecraftVersionInfo.fromJson(Map<String, dynamic> json) {
    return MinecraftVersionInfo(
      version: json['version'] as String,
      packFormat: json['packFormat'] as int,
    );
  }

  final String version;
  final int packFormat;
}

/// Thrown when a Minecraft version is not listed in `mc_versions.json`.
///
/// Guessing here would ship a pack Minecraft silently refuses to load, so an
/// unknown version is an error rather than a default.
class UnknownMinecraftVersion implements Exception {
  const UnknownMinecraftVersion(this.version);

  final String version;

  @override
  String toString() =>
      '지원 목록에 없는 Minecraft 버전입니다: $version. '
      'assets/data/mc_versions.json 을 확인하세요.';
}

/// Reads `assets/data/mc_versions.json` and builds `pack.mcmeta`.
/// See TECHNICAL.md 8.4 — pack_format is never hardcoded.
abstract final class PackMetaBuilder {
  static List<MinecraftVersionInfo> parseVersions(String mcVersionsJsonStr) {
    final list = jsonDecode(mcVersionsJsonStr) as List<dynamic>;
    return list
        .map((e) => MinecraftVersionInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Returns the pack_format for [mcVersion].
  ///
  /// Throws [UnknownMinecraftVersion] if the version is not listed, and
  /// [FormatException] if the data file itself is malformed.
  static int getPackFormat(String mcVersionsJsonStr, String mcVersion) {
    for (final info in parseVersions(mcVersionsJsonStr)) {
      if (info.version == mcVersion) return info.packFormat;
    }
    throw UnknownMinecraftVersion(mcVersion);
  }

  static String buildPackMeta({
    required int packFormat,
    String description = '한국어 번역 리소스팩 · LangForge',
  }) {
    final data = {
      'pack': {'pack_format': packFormat, 'description': description},
    };
    return '${const JsonEncoder.withIndent('  ').convert(data)}\n';
  }
}
