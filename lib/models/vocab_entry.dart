/// A word or phrase in the learner's Vault.
///
/// Strength is a deliberately simple 0–5 scale with time decay — enough to
/// make the review interaction real without pretending to be a scheduler.
/// See `docs/product-brief.md`.
class VocabEntry {
  VocabEntry({
    required this.id,
    required this.term,
    required this.gloss,
    required this.romanization,
    required this.partOfSpeech,
    required this.example,
    required this.exampleGloss,
    required this.lessonId,
    this.strength = 0,
    this.lastSeen,
    this.timesSeen = 0,
    this.timesCorrect = 0,
  });

  final String id;

  /// The term in the target language.
  final String term;

  /// Meaning in the learner's language.
  final String gloss;

  final String romanization;
  final String partOfSpeech;

  /// A short sentence using the term, plus its meaning.
  final String example;
  final String exampleGloss;

  /// Which lesson introduced it.
  final String lessonId;

  /// 0–5, raised by correct answers and lowered by mistakes.
  int strength;

  DateTime? lastSeen;
  int timesSeen;
  int timesCorrect;

  static const int maxStrength = 5;

  /// One strength level is shed per elapsed decay window.
  static const Duration decayWindow = Duration(days: 3);

  /// Strength after accounting for time since [lastSeen]. Drives Vault sort
  /// order, so the list reorders itself without a background job.
  int get effectiveStrength {
    final seen = lastSeen;
    if (seen == null) return strength;
    final windows =
        DateTime.now().difference(seen).inMilliseconds ~/
        decayWindow.inMilliseconds;
    if (windows <= 0) return strength;
    return (strength - windows).clamp(0, maxStrength);
  }

  bool get needsReview => effectiveStrength <= 2;

  double get accuracy => timesSeen == 0 ? 0 : timesCorrect / timesSeen;

  /// An unpractised copy. The catalogue hands these to the Vault so that
  /// resetting progress cannot leave mutated strengths behind.
  VocabEntry copyFresh() => VocabEntry(
    id: id,
    term: term,
    gloss: gloss,
    romanization: romanization,
    partOfSpeech: partOfSpeech,
    example: example,
    exampleGloss: exampleGloss,
    lessonId: lessonId,
  );

  void record({required bool correct}) {
    timesSeen++;
    if (correct) {
      timesCorrect++;
      strength = (effectiveStrength + 1).clamp(0, maxStrength);
    } else {
      strength = (effectiveStrength - 1).clamp(0, maxStrength);
    }
    lastSeen = DateTime.now();
  }
}
