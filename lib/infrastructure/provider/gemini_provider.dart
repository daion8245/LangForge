import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/provider/translation_error.dart';
import '../../domain/provider/translation_provider.dart';

class GeminiProvider implements TranslationProvider {
  final http.Client _client;

  GeminiProvider({http.Client? client}) : _client = client ?? http.Client();

  @override
  String get id => 'gemini';

  @override
  String get displayName => 'Google Gemini';

  @override
  List<AuthField> get authFields => const [
    AuthField(
      id: 'apiKey',
      label: 'Gemini API Key',
      isSecret: true,
      helpUrl: 'https://aistudio.google.com/app/apikey',
    ),
  ];

  @override
  List<String> get models => const [
    'gemini-3.6-flash',
    'gemini-3.5-flash-lite',
  ];

  @override
  BatchLimits get limits => const BatchLimits(
    maxTextsPerRequest: 50,
    maxCharsPerRequest: 8000,
    maxConcurrentRequests: 4,
    requestTimeout: Duration(seconds: 30),
  );

  static const String _instruction = '''
You translate Minecraft mod UI strings from {source} to {target}.

Rules:
- Return exactly the same number of items, in the same order.
- Preserve every \u2063LF<number>\u2063 placeholder exactly as it appears. Do not translate,
  reorder relative to surrounding words when grammatically avoidable, or remove them.
- Do not add quotes, explanations, notes, or trailing punctuation that is not in the source.
- Keep the register short and UI-appropriate. These are item names, tooltips, and messages.
- If a string should not be translated (proper noun, mod name), return it unchanged.
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
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
    );

    final systemInstructionText = _instruction
        .replaceAll('{source}', request.sourceCode)
        .replaceAll('{target}', request.targetCode);

    final requestBody = {
      'systemInstruction': {
        'parts': [
          {'text': systemInstructionText},
        ],
      },
      'contents': [
        {
          'parts': [
            {'text': jsonEncode(request.texts)},
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

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const AuthError();
    } else if (response.statusCode == 429) {
      final retryHeader = response.headers['retry-after'];
      Duration? retryAfter;
      if (retryHeader != null) {
        final sec = int.tryParse(retryHeader);
        if (sec != null) retryAfter = Duration(seconds: sec);
      }
      throw RateLimited(retryAfter: retryAfter);
    } else if (response.statusCode == 413) {
      throw const PayloadTooLarge();
    } else if (response.statusCode >= 500) {
      throw ServerError(response.statusCode);
    } else if (response.statusCode != 200) {
      throw ServerError(
        response.statusCode,
        message: 'Gemini API 오류 (${response.statusCode}): ${response.body}',
      );
    }

    try {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = jsonResponse['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw const InvalidResponse('Gemini 응답에 candidates 항목이 없습니다.');
      }

      final candidate = candidates.first as Map<String, dynamic>;
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
