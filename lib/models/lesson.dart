import 'exercise.dart';

/// One sitting. 5–8 exercises, 3–5 minutes.
class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.exercises,
    this.newWordIds = const <String>[],
  });

  final String id;
  final String title;

  /// One line of context shown on the intro sheet.
  final String subtitle;

  /// Vocabulary introduced here. Lands in the Vault when the lesson is done.
  final List<String> newWordIds;

  final List<Exercise> exercises;

  /// Rough sitting length, used on the intro sheet.
  int get estimatedMinutes => (exercises.length * 0.7).ceil().clamp(2, 15);
}

/// A themed group of lessons. Units unlock in order.
class Unit {
  const Unit({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.lessons,
  });

  final String id;
  final String title;
  final String subtitle;
  final List<Lesson> lessons;
}
