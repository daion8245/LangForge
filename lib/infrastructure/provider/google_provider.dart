import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/normalize/html_entities.dart';
import '../../domain/normalize/provider_language_code.dart';
import '../../domain/provider/translation_error.dart';
import '../../domain/provider/translation_provider.dart';
import 'http_status_mapper.dart';
import 'provider_definition.dart';

class GoogleProvider implements TranslationProvider {
  GoogleProvider({required this.definition, http.Client? client})
    : _client = client ?? http.Client();

  final ProviderDefinition definition;
  final http.Client _client;

  @override
  String get id => definition.id;

  @override
  String get displayName => definition.displayName;

  @override
  List<AuthField> get authFields => definition.authFields;

  @override
  List<String> get models => definition.models;

  @override
  BatchLimits get limits => definition.limits;

  @override
  Future<void> verify(AuthValues auth) async {
    final apiKey = auth.get('apiKey');
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw const AuthError('API Key가 입력되지 않았습니다.');
    }

    await translate(
      TranslationRequest(
        texts: const ['Hello'],
        sourceCode: 'en_us',
        targetCode: 'ko_kr',
        auth: auth,
        cancel: CancellationToken(),
      ),
    );
  }

  @override
  Future<List<String>> translate(TranslationRequest request) async {
    if (request.cancel.isCancelled) throw const Cancelled();

    final apiKey = request.auth.get('apiKey');
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw const AuthError('API Key가 입력되지 않았습니다.');
    }

    final base = definition.baseUrl;
    if (base == null || base.isEmpty) {
      throw StateError('Google provider baseUrl missing from providers.json');
    }

    final url = Uri.parse(base);
    final source = ProviderLanguageCode.map(id, request.sourceCode);
    final target = ProviderLanguageCode.map(id, request.targetCode);

    final body = <String, dynamic>{
      'q': request.texts,
      'source': source,
      'target': target,
      'format': 'text',
    };

    http.Response response;
    try {
      response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'x-goog-api-key': apiKey,
            },
            body: jsonEncode(body),
          )
          .timeout(limits.requestTimeout);
    } catch (e) {
      if (request.cancel.isCancelled) throw const Cancelled();
      throw NetworkError('Google Translation API 네트워크 통신 오류: $e');
    }

    if (request.cancel.isCancelled) throw const Cancelled();

    if (response.statusCode == 403 && _looksLikeQuota(response.body)) {
      throw const QuotaExhausted();
    }

    final mapped = HttpStatusMapper.mapStatus(
      response.statusCode,
      headers: response.headers,
      body: response.body,
      providerLabel: 'Google Translation',
    );
    if (mapped != null) throw mapped;

    try {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final data = jsonResponse['data'] as Map<String, dynamic>?;
      final translations = data?['translations'] as List<dynamic>?;
      if (translations == null) {
        throw const InvalidResponse(
          'Google Translation 응답에 translations 항목이 없습니다.',
        );
      }
      if (translations.length != request.texts.length) {
        throw InvalidResponse(
          'Google Translation 응답 개수 불일치: 요청 ${request.texts.length}, 응답 ${translations.length}',
        );
      }
      return translations.map((item) {
        final map = item as Map<String, dynamic>;
        final text = map['translatedText'] as String?;
        if (text == null) {
          throw const InvalidResponse(
            'Google Translation 항목에 translatedText가 없습니다.',
          );
        }
        // v2 still HTML-escapes even with format:"text" (&#39; &amp; …).
        return HtmlEntities.unescape(text);
      }).toList();
    } catch (e) {
      if (e is TranslationError) rethrow;
      throw InvalidResponse('Google Translation 응답 파싱 실패: $e');
    }
  }

  static bool _looksLikeQuota(String body) {
    final lower = body.toLowerCase();
    return lower.contains('quota') ||
        lower.contains('daily limit') ||
        lower.contains('billing');
  }
}
