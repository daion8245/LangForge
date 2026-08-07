import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:langforge/domain/provider/translation_error.dart';
import 'package:langforge/domain/provider/translation_provider.dart';
import 'package:langforge/infrastructure/provider/deepl_provider.dart';

import '../support/provider_test_setup.dart';

void main() {
  setUpAll(loadProvidersForTest);

  group('DeepLProvider', () {
    test('Uses Free endpoint and Authorization header for :fx keys', () async {
      late Uri uri;
      late Map<String, String> headers;
      late String body;

      final mockClient = MockClient((request) async {
        uri = request.url;
        headers = request.headers;
        body = request.body;
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'translations': [
                {'detected_source_language': 'EN', 'text': '안녕'},
              ],
            }),
          ),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final provider = DeepLProvider(
        definition: definitionForTest('deepl'),
        client: mockClient,
      );

      final result = await provider.translate(
        TranslationRequest(
          texts: const ['Hello'],
          sourceCode: 'en_us',
          targetCode: 'ko_kr',
          auth: const AuthValues({
            'apiKey': '12345678-1234-1234-1234-123456789abc:fx',
          }),
          cancel: CancellationToken(),
        ),
      );

      expect(result, equals(['안녕']));
      expect(uri.host, equals('api-free.deepl.com'));
      expect(
        headers['authorization'],
        equals('DeepL-Auth-Key 12345678-1234-1234-1234-123456789abc:fx'),
      );
      expect(uri.queryParameters.containsKey('auth_key'), isFalse);
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      expect(decoded['source_lang'], equals('EN'));
      expect(decoded['target_lang'], equals('KO'));
      expect(decoded['preserve_formatting'], isTrue);
    });

    test('Maps 400 to InvalidResponse', () async {
      final mockClient = MockClient((request) async {
        return http.Response('bad request', 400);
      });

      final provider = DeepLProvider(
        definition: definitionForTest('deepl'),
        client: mockClient,
      );

      expect(
        () => provider.translate(
          TranslationRequest(
            texts: const ['Hello'],
            sourceCode: 'en_us',
            targetCode: 'ko_kr',
            auth: const AuthValues({'apiKey': 'bad:fx'}),
            cancel: CancellationToken(),
          ),
        ),
        throwsA(isA<InvalidResponse>()),
      );
    });

    test('Uses Pro endpoint when key has no :fx suffix', () async {
      late Uri uri;
      final mockClient = MockClient((request) async {
        uri = request.url;
        return http.Response(
          jsonEncode({
            'translations': [
              {'text': 'Hallo'},
            ],
          }),
          200,
        );
      });

      final provider = DeepLProvider(
        definition: definitionForTest('deepl'),
        client: mockClient,
      );

      await provider.translate(
        TranslationRequest(
          texts: const ['Hello'],
          sourceCode: 'en_us',
          targetCode: 'de_de',
          auth: const AuthValues({
            'apiKey': '12345678-1234-1234-1234-123456789abc',
          }),
          cancel: CancellationToken(),
        ),
      );

      expect(uri.host, equals('api.deepl.com'));
    });

    test('Maps 456 to QuotaExhausted', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Quota exceeded', 456);
      });

      final provider = DeepLProvider(
        definition: definitionForTest('deepl'),
        client: mockClient,
      );

      expect(
        () => provider.translate(
          TranslationRequest(
            texts: const ['Hello'],
            sourceCode: 'en_us',
            targetCode: 'ko_kr',
            auth: const AuthValues({'apiKey': 'k:fx'}),
            cancel: CancellationToken(),
          ),
        ),
        throwsA(isA<QuotaExhausted>()),
      );
    });

    test('Maps 401 to AuthError', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      final provider = DeepLProvider(
        definition: definitionForTest('deepl'),
        client: mockClient,
      );

      expect(
        () => provider.translate(
          TranslationRequest(
            texts: const ['Hello'],
            sourceCode: 'en_us',
            targetCode: 'ko_kr',
            auth: const AuthValues({'apiKey': 'bad:fx'}),
            cancel: CancellationToken(),
          ),
        ),
        throwsA(isA<AuthError>()),
      );
    });
  });
}
