import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/normalize/provider_language_code.dart';
import '../../domain/provider/translation_error.dart';
import '../../domain/provider/translation_provider.dart';
import 'http_status_mapper.dart';
import 'provider_definition.dart';

class PapagoProvider implements TranslationProvider {
  PapagoProvider({required this.definition, http.Client? client})
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
    _requireAuth(auth);
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
    _requireAuth(request.auth);

    if (request.texts.isEmpty) return const [];
    if (request.texts.length > limits.maxTextsPerRequest) {
      throw PayloadTooLarge(
        'Papago는 요청당 ${limits.maxTextsPerRequest}개 텍스트만 지원합니다.',
      );
    }

    final base = definition.baseUrl;
    if (base == null || base.isEmpty) {
      throw StateError('Papago provider baseUrl missing from providers.json');
    }

    final clientId = request.auth.get('clientId')!.trim();
    final clientSecret = request.auth.get('clientSecret')!.trim();
    final url = Uri.parse(base);
    final source = ProviderLanguageCode.map(id, request.sourceCode);
    final target = ProviderLanguageCode.map(id, request.targetCode);
    final text = request.texts.first;

    final body = <String, dynamic>{
      'source': source,
      'target': target,
      'text': text,
    };

    http.Response response;
    try {
      response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'X-NCP-APIGW-API-KEY-ID': clientId,
              'X-NCP-APIGW-API-KEY': clientSecret,
            },
            body: jsonEncode(body),
          )
          .timeout(limits.requestTimeout);
    } catch (e) {
      if (request.cancel.isCancelled) throw const Cancelled();
      throw NetworkError('Papago API 네트워크 통신 오류: $e');
    }

    if (request.cancel.isCancelled) throw const Cancelled();

    final mapped = HttpStatusMapper.mapStatus(
      response.statusCode,
      headers: response.headers,
      body: response.body,
      providerLabel: 'Papago',
    );
    if (mapped != null) throw mapped;

    try {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final message = jsonResponse['message'] as Map<String, dynamic>?;
      final result = message?['result'] as Map<String, dynamic>?;
      final translated = result?['translatedText'] as String?;
      if (translated == null) {
        throw const InvalidResponse('Papago 응답에 translatedText 항목이 없습니다.');
      }
      return [translated];
    } catch (e) {
      if (e is TranslationError) rethrow;
      throw InvalidResponse('Papago 응답 파싱 실패: $e');
    }
  }

  void _requireAuth(AuthValues auth) {
    final clientId = auth.get('clientId');
    final clientSecret = auth.get('clientSecret');
    if (clientId == null || clientId.trim().isEmpty) {
      throw const AuthError('Client ID가 입력되지 않았습니다.');
    }
    if (clientSecret == null || clientSecret.trim().isEmpty) {
      throw const AuthError('Client Secret이 입력되지 않았습니다.');
    }
  }
}
