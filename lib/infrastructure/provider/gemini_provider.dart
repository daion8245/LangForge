import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/normalize/provider_language_code.dart';
import '../../domain/provider/translation_error.dart';
import '../../domain/provider/translation_provider.dart';
import 'http_status_mapper.dart';
import 'provider_definition.dart';

class GeminiProvider implements TranslationProvider {
  GeminiProvider({required this.definition, http.Client? client})
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

  static const String _instruction = '''
You translate Minecraft mod UI strings from {source} to {target}.

Rules:
- Return exactly the same number of items, in the same order.
- Preserve every \u2063LF<number>\u2063 placeholder exactly as it appears. Do not translate,
  reorder relative to surrounding words when grammatically avoidable, or remove them.
- Do not add quotes, explanations, notes, or trailing punctuation that is not in the source.
- Keep the register short and UI-appropriate. These are item names, tooltips, and messages.
- Translate every item into {target}. Never return the whole input array unchanged.
- Only an individual proper noun or mod name may be left unchanged — never most or all items.
''';

  static const String _userPreamble = '''
Translate each string in the JSON array below from {source} to {target}.
Return a JSON array of translated strings with the same length and order.
Do not copy the input array back. Translate every ordinary UI string.

Input:
''';

  @override
  Future<void> verify(AuthValues auth) async {
    final apiKey = auth.get('apiKey');
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw const AuthError('API Key가 입력되지 않았습니다.');
    }

    final dummyReq = TranslationRequest(
      texts: ['Hello'],
      sourceCode: 'en_us',
      targetCode: 'ko_kr',
      model: models.first,
      auth: auth,
      cancel: CancellationToken(),
    );

    try {
      await translate(dummyReq);
    } on AuthError {
      rethrow;
    } catch (e) {
      if (e is TranslationError) rethrow;
      throw AuthError('API 키 검증 실패: $e');
    }
  }

  @override
  Future<List<String>> translate(TranslationRequest request) async {
    if (request.cancel.isCancelled) {
      throw const Cancelled();
    }

    final apiKey = request.auth.get('apiKey');
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw const AuthError('API Key가 입력되지 않았습니다.');
    }

    final model = request.model ?? models.first;
    final url = Uri.parse(definition.translateUrl(model: model));

    final source = ProviderLanguageCode.map(id, request.sourceCode);
    final target = ProviderLanguageCode.map(id, request.targetCode);

    final systemInstructionText = _instruction
        .replaceAll('{source}', source)
        .replaceAll('{target}', target);

    final userText =
        _userPreamble
            .replaceAll('{source}', source)
            .replaceAll('{target}', target) +
        jsonEncode(request.texts);

    final requestBody = {
      'systemInstruction': {
        'parts': [
          {'text': systemInstructionText},
        ],
      },
      'contents': [
        {
          'parts': [
            {'text': userText},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.2,
        'responseMimeType': 'application/json',
        'responseSchema': {
          'type': 'ARRAY',
          'items': {'type': 'STRING'},
        },
      },
    };

    http.Response response;
    try {
      response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': apiKey,
            },
            body: jsonEncode(requestBody),
          )
          .timeout(limits.requestTimeout);
    } catch (e) {
      if (request.cancel.isCancelled) throw const Cancelled();
      throw NetworkError('Gemini API 네트워크 통신 오류: $e');
    }

    if (request.cancel.isCancelled) {
      throw const Cancelled();
    }

    final mapped = HttpStatusMapper.mapStatus(
      response.statusCode,
      headers: response.headers,
      body: response.body,
      providerLabel: 'Gemini',
    );
    if (mapped != null) throw mapped;

    try {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      final promptFeedback =
          jsonResponse['promptFeedback'] as Map<String, dynamic>?;
      final blockReason = promptFeedback?['blockReason'];
      if (blockReason != null) {
        throw InvalidResponse('Gemini prompt blocked: $blockReason');
      }

      final candidates = jsonResponse['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw const InvalidResponse('Gemini 응답에 candidates 항목이 없습니다.');
      }

      final candidate = candidates.first as Map<String, dynamic>;
      final finishReason = candidate['finishReason'] as String?;
      if (finishReason != null &&
          finishReason.toUpperCase() != 'STOP' &&
          finishReason.toUpperCase() != 'FINISH_REASON_UNSPECIFIED') {
        throw InvalidResponse('Gemini finishReason: $finishReason');
      }

      final content = candidate['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) {
        throw const InvalidResponse('Gemini 응답에 text parts가 없습니다.');
      }

      final firstPart = parts.first as Map<String, dynamic>;
      final textPart = firstPart['text'] as String?;
      if (textPart == null) {
        throw const InvalidResponse('Gemini 응답 text가 비어있습니다.');
      }

      final decodedArray = jsonDecode(textPart) as List<dynamic>;
      return decodedArray.map((e) => e.toString()).toList();
    } catch (e) {
      if (e is TranslationError) rethrow;
      throw InvalidResponse('Gemini 응답 파싱 실패: $e');
    }
  }
}
