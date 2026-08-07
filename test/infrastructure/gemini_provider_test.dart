import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:langforge/domain/provider/translation_error.dart';
import 'package:langforge/domain/provider/translation_provider.dart';
import 'package:langforge/infrastructure/provider/gemini_provider.dart';

import '../support/provider_test_setup.dart';

void main() {
  setUpAll(loadProvidersForTest);

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

        final provider = GeminiProvider(
          definition: definitionForTest('gemini'),
          client: mockClient,
        );
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
        expect(
          requestUri.toString(),
          startsWith(
            'https://generativelanguage.googleapis.com/v1beta/models/',
          ),
        );
      },
    );

    test('Throws AuthError on 401 response', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      final provider = GeminiProvider(
        definition: definitionForTest('gemini'),
        client: mockClient,
      );
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

      final provider = GeminiProvider(
        definition: definitionForTest('gemini'),
        client: mockClient,
      );
      final req = TranslationRequest(
        texts: ['Oak'],
        sourceCode: 'en_us',
        targetCode: 'ko_kr',
        auth: const AuthValues({'apiKey': 'TEST_KEY'}),
        cancel: CancellationToken(),
      );

      expect(() => provider.translate(req), throwsA(isA<RateLimited>()));
    });

    test('User content includes an explicit translate instruction', () async {
      late String body;
      final mockClient = MockClient((request) async {
        body = request.body;
        final responseBody = {
          'candidates': [
            {
              'finishReason': 'STOP',
              'content': {
                'parts': [
                  {
                    'text': jsonEncode(['안녕']),
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

      final provider = GeminiProvider(
        definition: definitionForTest('gemini'),
        client: mockClient,
      );
      await provider.translate(
        TranslationRequest(
          texts: ['Hello'],
          sourceCode: 'en_us',
          targetCode: 'ko_kr',
          auth: const AuthValues({'apiKey': 'TEST_KEY'}),
          cancel: CancellationToken(),
        ),
      );

      expect(body, contains('Translate each string'));
      expect(body, contains('Do not copy the input array'));
      expect(body, contains('Never return the whole input array unchanged'));
      expect(provider.limits.maxTextsPerRequest, equals(25));
    });

    test('Throws InvalidResponse on SAFETY finishReason', () async {
      final mockClient = MockClient((request) async {
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'candidates': [
                {
                  'finishReason': 'SAFETY',
                  'content': {
                    'parts': [
                      {
                        'text': jsonEncode(['x']),
                      },
                    ],
                  },
                },
              ],
            }),
          ),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final provider = GeminiProvider(
        definition: definitionForTest('gemini'),
        client: mockClient,
      );
      expect(
        () => provider.translate(
          TranslationRequest(
            texts: ['Oak'],
            sourceCode: 'en_us',
            targetCode: 'ko_kr',
            auth: const AuthValues({'apiKey': 'TEST_KEY'}),
            cancel: CancellationToken(),
          ),
        ),
        throwsA(isA<InvalidResponse>()),
      );
    });

    test('Throws InvalidResponse when promptFeedback blocks', () async {
      final mockClient = MockClient((request) async {
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'promptFeedback': {'blockReason': 'SAFETY'},
              'candidates': <dynamic>[],
            }),
          ),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final provider = GeminiProvider(
        definition: definitionForTest('gemini'),
        client: mockClient,
      );
      expect(
        () => provider.translate(
          TranslationRequest(
            texts: ['Oak'],
            sourceCode: 'en_us',
            targetCode: 'ko_kr',
            auth: const AuthValues({'apiKey': 'TEST_KEY'}),
            cancel: CancellationToken(),
          ),
        ),
        throwsA(isA<InvalidResponse>()),
      );
    });
  });
}
