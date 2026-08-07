import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/provider/backoff.dart';

void main() {
  group('Exponential Backoff Tests', () {
    test(
      'Calculates exponential backoff within capped limit of 30 seconds',
      () {
        final b0 = backoff(0);
        final b1 = backoff(1);
        final b5 = backoff(5);
        final b10 = backoff(10);

        expect(b0.inMilliseconds, greaterThanOrEqualTo(500));
        expect(b1.inMilliseconds, greaterThanOrEqualTo(1000));
        expect(b5.inMilliseconds, lessThanOrEqualTo(37500));
        expect(b10.inMilliseconds, lessThanOrEqualTo(37500));
      },
    );

    test('Max attempts limit is set to 5', () {
      expect(maxAttempts, equals(5));
    });
  });
}
