import 'dart:io';

import 'package:langforge/infrastructure/provider/provider_catalog.dart';
import 'package:langforge/infrastructure/provider/provider_definition.dart';
import 'package:langforge/infrastructure/provider/provider_registry.dart';

/// Loads `assets/data/providers.json` for unit/widget tests.
void loadProvidersForTest() {
  ProviderCatalog.resetForTest();
  ProviderRegistry.resetForTest();
  final source = File('assets/data/providers.json').readAsStringSync();
  ProviderCatalog.loadFromString(source);
  ProviderRegistry.initialize();
}

ProviderDefinition definitionForTest(String id) {
  if (!ProviderCatalog.isLoaded) {
    loadProvidersForTest();
  }
  return ProviderCatalog.byId(id);
}
