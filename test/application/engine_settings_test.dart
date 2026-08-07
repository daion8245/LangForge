import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/application/settings/engine_settings.dart';

import '../support/provider_test_setup.dart';

void main() {
  setUpAll(loadProvidersForTest);

  test('Switching provider resets in-memory auth and verify state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(engineSettingsProvider.notifier);
    await notifier.setCredential('apiKey', 'AIzaSyTestKeyForGeminiProvider01');

    final before = container.read(engineSettingsProvider);
    expect(before.providerId, equals('gemini'));
    expect(before.apiKey, isNotEmpty);

    await notifier.setProviderId('papago');
    final after = container.read(engineSettingsProvider);

    expect(after.providerId, equals('papago'));
    expect(after.isVerified, isFalse);
    expect(after.statusMessage, isNull);
    expect(after.credentials, isEmpty);
    expect(after.model, equals(''));
    expect(
      after.missingFieldLabels,
      containsAll(['Client ID', 'Client Secret']),
    );
  });

  test('Non-LLM providers expose empty model lists', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(engineSettingsProvider.notifier);

    await notifier.setProviderId('deepl');
    expect(container.read(engineSettingsProvider).provider.models, isEmpty);

    await notifier.setProviderId('google');
    expect(container.read(engineSettingsProvider).provider.models, isEmpty);

    await notifier.setProviderId('papago');
    expect(container.read(engineSettingsProvider).provider.models, isEmpty);
  });
}
