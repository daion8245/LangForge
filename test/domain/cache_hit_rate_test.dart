import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/cache/cache_hit_rate.dart';

void main() {
  test('zero total shows em dash, never NaN', () {
    expect(CacheHitRate.format(hits: 0, total: 0), '—');
    expect(CacheHitRate.format(hits: 5, total: 0), '—');
  });

  test('formats rounded percent', () {
    expect(CacheHitRate.format(hits: 1, total: 4), '25%');
    expect(CacheHitRate.format(hits: 1, total: 3), '33%');
  });
}
