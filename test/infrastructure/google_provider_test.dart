import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:langforge/domain/provider/translation_error.dart';
import 'package:langforge/domain/provider/translation_provider.dart';
import 'package:langforge/infrastructure/provider/google_provider.dart';

import '../support/provider_test_setup.dart';

void main() {
  setUpAll(loadProvidersForTest);

  group('GoogleProvider', () {
    test('Sends x-goog-api-key header and not query key', () async {
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
              'data': {
                'translations': [
                  {'translatedText': '안녕'},
                  {'translatedText': '세계'},
                ],
              },
            }),
          ),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final provider = GoogleProvider(
        definition: definitionForTest('google'),
        client: mockClient,
      );

      final result = await provider.translate(
        TranslationRequest(
          texts: const ['Hello', 'World'],
          sourceCode: 'en_us',
          targetCode: 'ko_kr',
          auth: const AuthValues({
            'apiKey': 'AIzaTestKey123456789012345678901',
          }),
          cancel: CancellationToken(),
        ),
      );

      expect(result, equals(['안녕', '세계']));
      expect(uri.toString(), contains('/language/translate/v2'));
      expect(uri.queryParameters.containsKey('key'), isFalse);
      expect(
        headers['x-goog-api-key'],
        equals('AIzaTestKey123456789012345678901'),
      );
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      expect(decoded['source'], equals('en'));
      expect(decoded['target'], equals('ko'));
      expect(decoded['format'], equals('text'));
    });

    test('Maps 403 quota body to QuotaExhausted', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error":{"message":"Quota exceeded"}}', 403);
      });

      final provider = GoogleProvider(
        definition: definitionForTest('google'),
        client: mockClient,
      );

      expect(
        () => provider.translate(
          TranslationRequest(
            texts: const ['Hello'],
            sourceCode: 'en_us',
            targetCode: 'ko_kr',
            auth: const AuthValues({'apiKey': 'k'}),
            cancel: CancellationToken(),
          ),
        ),
        throwsA(isA<QuotaExhausted>()),
      );
    });

    test('Maps plain 403 to AuthError', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error":{"message":"API key not valid"}}', 403);
      });

      final provider = GoogleProvider(
        definition: definitionForTest('google'),
        client: mockClient,
      );

      expect(
        () => provider.translate(
          TranslationRequest(
            texts: const ['Hello'],
            sourceCode: 'en_us',
            targetCode: 'ko_kr',
            auth: const AuthValues({'apiKey': 'k'}),
            cancel: CancellationToken(),
          ),
        ),
        throwsA(isA<AuthError>()),
      );
    });

    test('Unescapes HTML entities in translatedText', () async {
      final mockClient = MockClient((request) async {
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'data': {
                'translations': [
                  {'translatedText': "It&#39;s 100&amp;"},
                ],
              },
            }),
          ),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final provider = GoogleProvider(
        definition: definitionForTest('google'),
        client: mockClient,
      );

      final result = await provider.translate(
        TranslationRequest(
          texts: const ["It's 100&"],
          sourceCode: 'en_us',
          targetCode: 'ko_kr',
          auth: const AuthValues({'apiKey': 'k'}),
          cancel: CancellationToken(),
        ),
      );

      expect(result, equals(["It's 100&"]));
    });

    test(
      'Maps 400 to InvalidResponse without classifying as ServerError',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response('{"error":"bad request"}', 400);
        });

        final provider = GoogleProvider(
          definition: definitionForTest('google'),
          client: mockClient,
        );

        expect(
          () => provider.translate(
            TranslationRequest(
              texts: const ['Hello'],
              sourceCode: 'en_us',
              targetCode: 'ko_kr',
              auth: const AuthValues({'apiKey': 'k'}),
              cancel: CancellationToken(),
            ),
          ),
          throwsA(
            isA<InvalidResponse>().having(
              (e) => e,
              'not ServerError',
              isNot(isA<ServerError>()),
            ),
          ),
        );
      },
    );
  });
}
