import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:langforge/domain/provider/translation_error.dart';
import 'package:langforge/domain/provider/translation_provider.dart';
import 'package:langforge/infrastructure/provider/deepl_provider.dart';
import 'package:langforge/infrastructure/provider/gemini_provider.dart';
import 'package:langforge/infrastructure/provider/google_provider.dart';
import 'package:langforge/infrastructure/provider/papago_provider.dart';

import '../support/provider_test_setup.dart';

typedef _ProviderFactory = TranslationProvider Function(http.Client client);

void main() {
  setUpAll(loadProvidersForTest);

  final cases = <String, ({_ProviderFactory build, AuthValues auth})>{
    'gemini': (
      build: (client) => GeminiProvider(
        definition: definitionForTest('gemini'),
        client: client,
      ),
      auth: const AuthValues({'apiKey': 'k'}),
    ),
    'deepl': (
      build: (client) =>
          DeepLProvider(definition: definitionForTest('deepl'), client: client),
      auth: const AuthValues({'apiKey': 'k:fx'}),
    ),
    'google': (
      build: (client) => GoogleProvider(
        definition: definitionForTest('google'),
        client: client,
      ),
      auth: const AuthValues({'apiKey': 'k'}),
    ),
    'papago': (
      build: (client) => PapagoProvider(
        definition: definitionForTest('papago'),
        client: client,
      ),
      auth: const AuthValues({'clientId': 'id', 'clientSecret': 'secret'}),
    ),
  };

  group('All providers map generic 4xx to InvalidResponse', () {
    for (final entry in cases.entries) {
      final id = entry.key;
      final setup = entry.value;

      for (final status in [400, 404, 422]) {
        test('$id · $status → InvalidResponse (not ServerError)', () async {
          var calls = 0;
          final mockClient = MockClient((request) async {
            calls++;
            return http.Response('client error', status);
          });

          final provider = setup.build(mockClient);
          await expectLater(
            provider.translate(
              TranslationRequest(
                texts: const ['Hello'],
                sourceCode: 'en_us',
                targetCode: 'ko_kr',
                auth: setup.auth,
                cancel: CancellationToken(),
              ),
            ),
            throwsA(isA<InvalidResponse>()),
          );
          expect(calls, equals(1));
        });
      }
    }
  });
}
