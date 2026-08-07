import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/normalize/provider_language_code.dart';
import '../../domain/provider/translation_error.dart';
import '../../domain/provider/translation_provider.dart';
import 'http_status_mapper.dart';
import 'provider_definition.dart';

class DeepLProvider implements TranslationProvider {
  DeepLProvider({required this.definition, http.Client? client})
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

  String _endpointForKey(String apiKey) {
    final isFree = apiKey.trim().toLowerCase().endsWith(':fx');
    final key = isFree ? 'free' : 'pro';
    final url = definition.endpoints[key];
    if (url == null || url.isEmpty) {
      throw StateError('DeepL $key endpoint missing from providers.json');
    }
    return url;
  }

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

    final url = Uri.parse(_endpointForKey(apiKey));
    final source = ProviderLanguageCode.map(id, request.sourceCode);
    final target = ProviderLanguageCode.map(id, request.targetCode);

    // DeepL target EN must be regional (EN-US / EN-GB). Source may stay EN.
    final sourceLang = source.startsWith('EN') ? 'EN' : source;

    final body = <String, dynamic>{
      'text': request.texts,
      'source_lang': sourceLang,
      'target_lang': target,
      // Keep punctuation / casing closer to the source (Minecraft UI strings).
      'preserve_formatting': true,
    };

    http.Response response;
    try {
      response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'DeepL-Auth-Key $apiKey',
            },
            body: jsonEncode(body),
          )
          .timeout(limits.requestTimeout);
    } catch (e) {
      if (request.cancel.isCancelled) throw const Cancelled();
      throw NetworkError('DeepL API 네트워크 통신 오류: $e');
    }

    if (request.cancel.isCancelled) throw const Cancelled();

    final mapped = HttpStatusMapper.mapStatus(
      response.statusCode,
      headers: response.headers,
      body: response.body,
      providerLabel: 'DeepL',
    );
    if (mapped != null) throw mapped;

    try {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final translations = jsonResponse['translations'] as List<dynamic>?;
      if (translations == null) {
        throw const InvalidResponse('DeepL 응답에 translations 항목이 없습니다.');
      }
      if (translations.length != request.texts.length) {
        throw InvalidResponse(
          'DeepL 응답 개수 불일치: 요청 ${request.texts.length}, 응답 ${translations.length}',
        );
      }
      return translations.map((item) {
        final map = item as Map<String, dynamic>;
        final text = map['text'] as String?;
        if (text == null) {
          throw const InvalidResponse('DeepL 번역 항목에 text가 없습니다.');
        }
        return text;
      }).toList();
    } catch (e) {
      if (e is TranslationError) rethrow;
      throw InvalidResponse('DeepL 응답 파싱 실패: $e');
    }
  }
}
