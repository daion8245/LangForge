import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import 'language_profile.dart';

/// Loads and caches `assets/data/language_profiles.json`.
///
/// The target-language picker (ROADMAP 11.1) and the 언어 프로필 탭 (10.6) both
/// read from here, so the six shipped languages are described in exactly one
/// place.
abstract final class LanguageProfileCatalog {
  static const assetPath = 'assets/data/language_profiles.json';

  static List<LanguageProfile>? _loaded;

  static bool get isLoaded => _loaded != null;

  static List<LanguageProfile> get all {
    final loaded = _loaded;
    if (loaded == null) {
      throw StateError(
        'LanguageProfileCatalog.load() must run before profiles are used',
      );
    }
    return loaded;
  }

  /// Null rather than throwing: a project can name a language this build does
  /// not ship, and the caller decides what to do about it.
  static LanguageProfile? byMc(String mc) {
    for (final profile in all) {
      if (profile.mc == mc) return profile;
    }
    return null;
  }

  static Future<void> load({AssetBundle? bundle}) async {
    final source = await (bundle ?? rootBundle).loadString(assetPath);
    loadFromString(source);
  }

  /// Test / bootstrap helper that skips the asset bundle.
  static void loadFromString(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! List) {
      throw const FormatException('language_profiles.json must be a list');
    }
    final list = decoded
        .cast<Map<String, dynamic>>()
        .map(LanguageProfile.fromJson)
        .toList(growable: false);
    if (list.isEmpty) {
      throw const FormatException('language_profiles.json has no profiles');
    }
    _loaded = list;
  }

  /// Clears the cache. Intended for tests only.
  static void resetForTest() {
    _loaded = null;
  }
}
