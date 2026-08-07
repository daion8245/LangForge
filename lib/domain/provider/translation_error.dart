sealed class TranslationError implements Exception {
  final String message;
  const TranslationError(this.message);

  @override
  String toString() => message;
}

// Retryable errors
final class RateLimited extends TranslationError {
  final Duration? retryAfter;
  const RateLimited({
    this.retryAfter,
    String message = '요청 한도 초과 (Rate Limited)',
  }) : super(message);
}

final class ServerError extends TranslationError {
  final int statusCode;
  const ServerError(this.statusCode, {String message = '서버 오류가 발생했습니다.'})
    : super(message);
}

final class NetworkError extends TranslationError {
  const NetworkError([super.message = '네트워크 연결 오류']);
}

final class TimeoutError extends TranslationError {
  const TimeoutError([super.message = '응답 시간 초과']);
}

// Non-retryable errors
final class AuthError extends TranslationError {
  const AuthError([super.message = 'API 키 또는 인증 정보가 유효하지 않습니다.']);
}

final class QuotaExhausted extends TranslationError {
  const QuotaExhausted([super.message = 'API 할당량 또는 결제 한도가 소진되었습니다.']);
}

final class PayloadTooLarge extends TranslationError {
  const PayloadTooLarge([super.message = '요청 데이터 크기가 너무 큽니다.']);
}

final class InvalidResponse extends TranslationError {
  const InvalidResponse([super.message = '올바르지 않은 응답 포맷']);
}

final class Cancelled extends TranslationError {
  const Cancelled([super.message = '작업이 취소되었습니다.']);
}
