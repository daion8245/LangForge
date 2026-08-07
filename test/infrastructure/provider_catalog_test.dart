import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/infrastructure/provider/provider_catalog.dart';
import 'package:langforge/infrastructure/provider/provider_registry.dart';

import '../support/provider_test_setup.dart';

void main() {
  setUp(loadProvidersForTest);

  test('providers.json exposes all four engines with HTTPS endpoints', () {
    final ids = ProviderCatalog.all.map((p) => p.id).toList();
    expect(ids, equals(['gemini', 'deepl', 'google', 'papago']));

    final gemini = ProviderCatalog.byId('gemini');
    expect(
      gemini.translateUrl(model: 'gemini-3.6-flash'),
      startsWith('https://'),
    );
    expect(gemini.limits.maxTextsPerRequest, equals(25));

    final deepl = ProviderCatalog.byId('deepl');
    expect(deepl.endpoints['free'], startsWith('https://'));
    expect(deepl.endpoints['pro'], startsWith('https://'));

    final google = ProviderCatalog.byId('google');
    expect(google.baseUrl, startsWith('https://'));

    final papago = ProviderCatalog.byId('papago');
    expect(papago.baseUrl, startsWith('https://'));
    expect(
      papago.authFields.map((f) => f.id),
      containsAll(['clientId', 'clientSecret']),
    );
    expect(papago.limits.maxTextsPerRequest, equals(1));
  });

  test('ProviderRegistry exposes four adapters from the catalog', () {
    final providers = ProviderRegistry.available();
    expect(providers.map((p) => p.id).toList(), [
      'gemini',
      'deepl',
      'google',
      'papago',
    ]);
    expect(ProviderRegistry.defaultProviderId, equals('gemini'));
  });
}
