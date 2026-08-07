import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import 'provider_definition.dart';

/// Loads and caches `assets/data/providers.json`.
///
/// Endpoints and model lists live in the asset so vendor changes do not
/// require a code edit (TECHNICAL.md 6.2).
abstract final class ProviderCatalog {
  static const assetPath = 'assets/data/providers.json';

  static List<ProviderDefinition>? _loaded;

  static bool get isLoaded => _loaded != null;

  static List<ProviderDefinition> get all {
    final loaded = _loaded;
    if (loaded == null) {
      throw StateError(
        'ProviderCatalog.load() must run before providers are used',
      );
    }
    return loaded;
  }

  static ProviderDefinition byId(String id) {
    for (final provider in all) {
      if (provider.id == id) return provider;
    }
    throw ArgumentError.value(id, 'id', 'providers.json 에 없는 제공자입니다');
  }

  static Future<void> load({AssetBundle? bundle}) async {
    final source = await (bundle ?? rootBundle).loadString(assetPath);
    loadFromString(source);
  }

  /// Test / bootstrap helper that skips the asset bundle.
  static void loadFromString(String source) {
    final decoded = jsonDecode(source) as Map<String, dynamic>;
    final list = (decoded['providers'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(ProviderDefinition.fromJson)
        .toList(growable: false);
    if (list.isEmpty) {
      throw const FormatException('providers.json has no providers');
    }
    _loaded = list;
  }

  /// Clears the cache. Intended for tests only.
  static void resetForTest() {
    _loaded = null;
  }
}
