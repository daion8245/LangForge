/// Formats the cache hit-rate indicator. AGENTS.md 5.3 · TECHNICAL.md 7.5.
abstract final class CacheHitRate {
  /// `—` when there is nothing to divide; never `NaN%`.
  static String format({required int hits, required int total}) {
    if (total <= 0) return '—';
    final pct = ((hits / total) * 100).round();
    return '$pct%';
  }
}
