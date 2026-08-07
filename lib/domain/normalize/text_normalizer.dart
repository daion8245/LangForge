/// Unicode normalization, supplied from outside the domain layer.
///
/// Dart has no built-in normalization and `domain/` may not depend on
/// packages, so the implementation lives in `infrastructure/` and is injected
/// (AGENTS.md 2.3).
abstract interface class TextNormalizer {
  /// Returns [input] in Normalization Form C.
  ///
  /// Must be idempotent: `toNfc(toNfc(x)) == toNfc(x)`.
  String toNfc(String input);
}

/// Leaves text exactly as it is.
///
/// Used where normalization is irrelevant — pure token tests, and callers that
/// deliberately want the raw provider output.
class NoopTextNormalizer implements TextNormalizer {
  const NoopTextNormalizer();

  @override
  String toNfc(String input) => input;
}
