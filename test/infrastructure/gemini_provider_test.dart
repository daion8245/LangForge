import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:langforge/domain/provider/translation_error.dart';
import 'package:langforge/domain/provider/translation_provider.dart';
import 'package:langforge/infrastructure/provider/gemini_provider.dart';

void main() {
  group('GeminiProvider REST Client Tests', () {
    test(
      'Includes x-goog-api-key in HTTP header and NOT in URL query',
      () async {
        late Uri requestUri;
        late Map<String, String> requestHeaders;

        final mockClient = MockClient((request) async {
          requestUri = request.url;
          requestHeaders = request.headers;

          final responseBody = {
            'candidates': [
              {
                'content': {
                  'parts': [
                    {
                      'text': jsonEncode(['참나무 산울타리']),
                    },
                  ],
                },
              },
            ],
          };

          return http.Response.bytes(
            utf8.encode(jsonEncode(responseBody)),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });

        final provider = GeminiProvider(client: mockClient);
        final auth = const AuthValues({'apiKey': 'TEST_KEY_123'});

        final req = TranslationRequest(
          texts: ['Oak Hedge'],
          sourceCode: 'en_us',
          targetCode: 'ko_kr',
          auth: auth,
          cancel: CancellationToken(),
        );

        final result = await provider.translate(req);

        expect(result, equals(['참나무 산울타리']));
        expect(requestUri.queryParameters.containsKey('key'), isFalse);
        expect(requestHeaders['x-goog-api-key'], equals('TEST_KEY_123'));
      },
    );

    test('Throws AuthError on 401 response', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      final provider = GeminiProvider(client: mockClient);
      final req = TranslationRequest(
        texts: ['Oak'],
        sourceCode: 'en_us',
        targetCode: 'ko_kr',
        auth: const AuthValues({'apiKey': 'INVALID'}),
        cancel: CancellationToken(),
      );

      expect(() => provider.translate(req), throwsA(isA<AuthError>()));
    });

    test('Throws RateLimited on 429 response', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          'Too many requests',
          429,
          headers: {'retry-after': '5'},
        );
      });

      final provider = GeminiProvider(client: mockClient);
      final req = TranslationRequest(
        texts: ['Oak'],
        sourceCode: 'en_us',
        targetCode: 'ko_kr',
        auth: const AuthValues({'apiKey': 'TEST_KEY'}),
        cancel: CancellationToken(),
      );

      expect(() => provider.translate(req), throwsA(isA<RateLimited>()));
    });
  });
}
