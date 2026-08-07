import 'dart:math' as math;

const int maxAttempts = 5;

/// Calculates exponential backoff with random jitter.
/// Formula: min(30s, 500ms * 2^attempt) + random_jitter(capped / 4)
Duration backoff(int attempt) {
  final baseMs = 500 * math.pow(2, attempt).toInt();
  final cappedMs = math.min(30000, baseMs);

  final maxJitter = math.max(1, cappedMs ~/ 4);
  final jitterMs = math.Random().nextInt(maxJitter);

  return Duration(milliseconds: cappedMs + jitterMs);
}
