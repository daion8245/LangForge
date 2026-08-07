import 'lesson.dart';

/// A language course. The prototype seeds exactly one that is playable;
/// the rest render as "coming soon" (see `docs/screens.md`).
class Course {
  const Course({
    required this.id,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.wordCount,
    this.available = true,
    this.units = const <Unit>[],
  });

  final String id;

  /// Name in the learner's language, e.g. "Korean".
  final String name;

  /// Endonym, e.g. "한국어".
  final String nativeName;

  /// Flag emoji — avoids bundling image assets.
  final String flag;

  /// Marketing-ish total for the course card, not the fixture count.
  final int wordCount;

  final bool available;
  final List<Unit> units;

  int get lessonCount =>
      units.fold(0, (sum, unit) => sum + unit.lessons.length);

  /// Flat lesson list in play order.
  List<Lesson> get allLessons => [for (final u in units) ...u.lessons];

  Unit? unitOf(String lessonId) {
    for (final unit in units) {
      if (unit.lessons.any((l) => l.id == lessonId)) return unit;
    }
    return null;
  }
}
