import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:langforge/domain/provider/translation_error.dart';
import 'package:langforge/domain/provider/translation_provider.dart';
import 'package:langforge/infrastructure/provider/papago_provider.dart';

import '../support/provider_test_setup.dart';

void main() {
  setUpAll(loadProvidersForTest);

  group('PapagoProvider', () {
    test('Sends NCP headers and returns translatedText', () async {
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
              'message': {
                'result': {
                  'srcLangType': 'en',
                  'tarLangType': 'ko',
                  'translatedText': '안녕',
                },
              },
            }),
          ),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final provider = PapagoProvider(
        definition: definitionForTest('papago'),
        client: mockClient,
      );

      final result = await provider.translate(
        TranslationRequest(
          texts: const ['Hello'],
          sourceCode: 'en_us',
          targetCode: 'ko_kr',
          auth: const AuthValues({
            'clientId': 'ncp-client-id',
            'clientSecret': 'ncp-client-secret',
          }),
          cancel: CancellationToken(),
        ),
      );

      expect(result, equals(['안녕']));
      expect(uri.host, equals('papago.apigw.ntruss.com'));
      expect(headers['x-ncp-apigw-api-key-id'], equals('ncp-client-id'));
      expect(headers['x-ncp-apigw-api-key'], equals('ncp-client-secret'));
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      expect(decoded['source'], equals('en'));
      expect(decoded['target'], equals('ko'));
      expect(provider.limits.maxTextsPerRequest, equals(1));
    });

    test('Rejects batches larger than one text', () async {
      final provider = PapagoProvider(
        definition: definitionForTest('papago'),
        client: MockClient((request) async => http.Response('', 500)),
      );

      expect(
        () => provider.translate(
          TranslationRequest(
            texts: const ['Hello', 'World'],
            sourceCode: 'en_us',
            targetCode: 'ko_kr',
            auth: const AuthValues({
              'clientId': 'id',
              'clientSecret': 'secret',
            }),
            cancel: CancellationToken(),
          ),
        ),
        throwsA(isA<PayloadTooLarge>()),
      );
    });

    test('Maps 401 to AuthError', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      final provider = PapagoProvider(
        definition: definitionForTest('papago'),
        client: mockClient,
      );

      expect(
        () => provider.translate(
          TranslationRequest(
            texts: const ['Hello'],
            sourceCode: 'en_us',
            targetCode: 'ko_kr',
            auth: const AuthValues({
              'clientId': 'id',
              'clientSecret': 'secret',
            }),
            cancel: CancellationToken(),
          ),
        ),
        throwsA(isA<AuthError>()),
      );
    });

    test('Maps 400 to InvalidResponse', () async {
      final mockClient = MockClient((request) async {
        return http.Response('bad request', 400);
      });

      final provider = PapagoProvider(
        definition: definitionForTest('papago'),
        client: mockClient,
      );

      expect(
        () => provider.translate(
          TranslationRequest(
            texts: const ['Hello'],
            sourceCode: 'en_us',
            targetCode: 'ko_kr',
            auth: const AuthValues({
              'clientId': 'id',
              'clientSecret': 'secret',
            }),
            cancel: CancellationToken(),
          ),
        ),
        throwsA(isA<InvalidResponse>()),
      );
    });
  });
}
