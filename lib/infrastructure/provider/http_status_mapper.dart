import '../../domain/provider/translation_error.dart';

/// Maps common translation-API HTTP statuses to [TranslationError].
///
/// Retryable: [RateLimited], [ServerError] (5xx), and network/timeouts
/// handled outside this mapper. Permanent client errors are [InvalidResponse]
/// so the runner does not burn backoff attempts on 400/404/422.
abstract final class HttpStatusMapper {
  static TranslationError? mapStatus(
    int statusCode, {
    Map<String, String> headers = const {},
    String? body,
    String providerLabel = 'API',
  }) {
    if (statusCode >= 200 && statusCode < 300) {
      return null;
    }

    if (statusCode == 401 || statusCode == 403) {
      return const AuthError();
    }
    if (statusCode == 429) {
      final retryHeader = headers['retry-after'];
      Duration? retryAfter;
      if (retryHeader != null) {
        final sec = int.tryParse(retryHeader);
        if (sec != null) retryAfter = Duration(seconds: sec);
      }
      return RateLimited(retryAfter: retryAfter);
    }
    if (statusCode == 413) {
      return const PayloadTooLarge();
    }
    // DeepL uses 456 for character quota exhaustion.
    if (statusCode == 456) {
      return const QuotaExhausted();
    }
    if (statusCode >= 500) {
      return ServerError(statusCode);
    }

    final detail = body == null || body.isEmpty ? '' : ': $body';
    return InvalidResponse('$providerLabel 오류 ($statusCode)$detail');
  }
}
