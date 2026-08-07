import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/provider/translation_error.dart';
import 'package:langforge/infrastructure/provider/http_status_mapper.dart';

void main() {
  group('HttpStatusMapper', () {
    test('Treats any 2xx as success', () {
      for (final code in [200, 201, 204, 299]) {
        expect(
          HttpStatusMapper.mapStatus(code),
          isNull,
          reason: 'status $code should succeed',
        );
      }
    });

    test('Keeps specific permanent / retryable classifications', () {
      expect(HttpStatusMapper.mapStatus(401), isA<AuthError>());
      expect(HttpStatusMapper.mapStatus(403), isA<AuthError>());
      expect(HttpStatusMapper.mapStatus(413), isA<PayloadTooLarge>());
      expect(HttpStatusMapper.mapStatus(429), isA<RateLimited>());
      expect(HttpStatusMapper.mapStatus(456), isA<QuotaExhausted>());
      expect(HttpStatusMapper.mapStatus(500), isA<ServerError>());
      expect(HttpStatusMapper.mapStatus(503), isA<ServerError>());
    });

    test('Maps generic 4xx to InvalidResponse (non-retryable)', () {
      for (final code in [400, 404, 422]) {
        final error = HttpStatusMapper.mapStatus(
          code,
          body: 'bad request',
          providerLabel: 'TestAPI',
        );
        expect(error, isA<InvalidResponse>(), reason: 'status $code');
        expect(error, isNot(isA<ServerError>()), reason: 'status $code');
        expect(error!.message, contains('TestAPI 오류 ($code)'));
      }
    });

    test('Propagates Retry-After on 429', () {
      final error = HttpStatusMapper.mapStatus(
        429,
        headers: {'retry-after': '7'},
      );
      expect(error, isA<RateLimited>());
      expect(
        (error! as RateLimited).retryAfter,
        equals(const Duration(seconds: 7)),
      );
    });
  });
}
