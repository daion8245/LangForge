import 'dart:math';

import 'package:flutter/material.dart';

import '../data/mock_courses.dart';
import '../data/mock_vocab.dart';
import '../models/course.dart';
import '../models/exercise.dart';
import '../models/lesson.dart';
import '../models/vocab_entry.dart';
import 'lesson_session.dart';

enum DailyGoal {
  casual(minutes: 5, xp: 20, label: 'Casual'),
  steady(minutes: 10, xp: 40, label: 'Steady'),
  serious(minutes: 15, xp: 60, label: 'Serious'),
  intense(minutes: 20, xp: 80, label: 'Intense');

  const DailyGoal({
    required this.minutes,
    required this.xp,
    required this.label,
  });

  final int minutes;
  final int xp;
  final String label;

  String get description => '$minutes min a day · $xp XP';
}

/// How a lesson node renders on the Path.
enum LessonStatus { locked, available, current, complete }

/// One earned-or-not badge on the Profile.
@immutable
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.criterion,
    required this.icon,
    required this.earned,
  });

  final String id;
  final String title;
  final String criterion;
  final IconData icon;
  final bool earned;
}

/// Everything that outlives a single lesson.
///
/// The prototype holds this purely in memory — restarting the app resets it,
/// which is intentional (see `docs/prototype-scope.md`).
class AppState extends ChangeNotifier {
  AppState() : _courses = buildCourses();

  final List<Course> _courses;

  /// Every word the course can teach, keyed by id. Read-only reference data:
  /// entries are copied via [VocabEntry.copyFresh] before entering the Vault,
  /// so nothing here is ever mutated.
  final Map<String, VocabEntry> _catalog = {
    for (final entry in buildKoreanVocab()) entry.id: entry,
  };

  final Map<String, VocabEntry> _vault = <String, VocabEntry>{};
  final Set<String> _completedLessonIds = <String>{};

  /// XP per day for the trailing week, oldest first; last entry is today.
  final List<int> _weeklyXp = List<int>.filled(7, 0, growable: false);

  Course? _course;
  DailyGoal _goal = DailyGoal.steady;
  ThemeMode _themeMode = ThemeMode.system;
  bool _onboarded = false;
  int _totalXp = 0;
  int _streakDays = 0;
  int _lessonsCompleted = 0;
  int _answersCorrect = 0;
  int _answersTotal = 0;

  List<Course> get courses => List.unmodifiable(_courses);
  Course? get course => _course;
  DailyGoal get goal => _goal;
  ThemeMode get themeMode => _themeMode;
  bool get onboarded => _onboarded;
  int get totalXp => _totalXp;
  int get streakDays => _streakDays;
  int get lessonsCompleted => _lessonsCompleted;
  int get xpToday => _weeklyXp.last;
  List<int> get weeklyXp => List.unmodifiable(_weeklyXp);

  /// 1-based, 100 XP per level.
  int get level => _totalXp ~/ 100 + 1;

  /// Progress toward the next level, 0–1.
  double get levelProgress => (_totalXp % 100) / 100;

  double get dailyGoalProgress => (xpToday / _goal.xp).clamp(0.0, 1.0);

  double get overallAccuracy =>
      _answersTotal == 0 ? 0 : _answersCorrect / _answersTotal;

  // ── Onboarding & settings ───────────────────────────────────────────

  void completeOnboarding({required Course course, required DailyGoal goal}) {
    _course = course;
    _goal = goal;
    _onboarded = true;
    notifyListeners();
  }

  void setGoal(DailyGoal goal) {
    _goal = goal;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void resetProgress() {
    _vault.clear();
    _completedLessonIds.clear();
    for (var i = 0; i < _weeklyXp.length; i++) {
      _weeklyXp[i] = 0;
    }
    _course = null;
    _onboarded = false;
    _totalXp = 0;
    _streakDays = 0;
    _lessonsCompleted = 0;
    _answersCorrect = 0;
    _answersTotal = 0;
    notifyListeners();
  }

  // ── Path progression ────────────────────────────────────────────────

  bool isLessonComplete(String lessonId) =>
      _completedLessonIds.contains(lessonId);

  /// Play order across all units, used for lock/unlock and "current".
  List<Lesson> get _orderedLessons => _course?.allLessons ?? const <Lesson>[];

  /// The single lesson the Path recommends, or null when the course is done.
  String? get currentLessonId {
    for (final lesson in _orderedLessons) {
      if (!isLessonComplete(lesson.id)) return lesson.id;
    }
    return null;
  }

  /// A lesson unlocks when every lesson before it in play order is complete —
  /// which makes the first incomplete lesson the only available one.
  LessonStatus statusOf(String lessonId) {
    if (isLessonComplete(lessonId)) return LessonStatus.complete;
    return lessonId == currentLessonId
        ? LessonStatus.current
        : LessonStatus.locked;
  }

  /// Title of the lesson blocking [lessonId], for the locked-node tooltip.
  String? blockerTitleFor(String lessonId) {
    final current = currentLessonId;
    if (current == null || current == lessonId) return null;
    for (final lesson in _orderedLessons) {
      if (lesson.id == current) return lesson.title;
    }
    return null;
  }

  int completedIn(Unit unit) =>
      unit.lessons.where((l) => isLessonComplete(l.id)).length;

  double unitProgress(Unit unit) =>
      unit.lessons.isEmpty ? 0 : completedIn(unit) / unit.lessons.length;

  Lesson? lessonById(String id) {
    for (final lesson in _orderedLessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }

  // ── Recording results ───────────────────────────────────────────────

  /// Applies a finished session. Called once, by `LessonScreen`.
  void applyResult(LessonResult result, {required bool isReview}) {
    _answersCorrect += result.correctFirstTry;
    _answersTotal += result.totalExercises;

    if (result.passed && !isReview) {
      final firstTime = _completedLessonIds.add(result.lessonId);
      if (firstTime) {
        _lessonsCompleted++;
        _introduceVocabFor(result.lessonId);
      }
    }

    _applyVocabOutcomes(result);

    if (result.xpEarned > 0) {
      final before = _weeklyXp.last;
      _weeklyXp[_weeklyXp.length - 1] = before + result.xpEarned;
      _totalXp += result.xpEarned;
      // First XP of the day advances the streak.
      if (before == 0) _streakDays++;
    }

    notifyListeners();
  }

  void _introduceVocabFor(String lessonId) {
    final lesson = lessonById(lessonId);
    if (lesson == null) return;
    for (final id in lesson.newWordIds) {
      final entry = _catalog[id];
      if (entry != null) _vault.putIfAbsent(id, entry.copyFresh);
    }
  }

  /// Reference lookup for words not yet in the Vault — used by the lesson
  /// intro sheet to preview what a lesson introduces.
  VocabEntry? definitionOf(String id) => _catalog[id];

  void _applyVocabOutcomes(LessonResult result) {
    for (final id in result.vocabCorrect) {
      _vault[id]?.record(correct: true);
    }
    for (final id in result.vocabWrong) {
      _vault[id]?.record(correct: false);
    }
  }

  // ── Vault ───────────────────────────────────────────────────────────

  /// Discovered words, weakest first.
  List<VocabEntry> get vault {
    final entries = _vault.values.toList()
      ..sort((a, b) {
        final byStrength = a.effectiveStrength.compareTo(b.effectiveStrength);
        return byStrength != 0 ? byStrength : a.term.compareTo(b.term);
      });
    return entries;
  }

  List<VocabEntry> get weakWords =>
      vault.where((e) => e.needsReview).toList(growable: false);

  List<VocabEntry> get strongWords =>
      vault.where((e) => !e.needsReview).toList(growable: false);

  List<VocabEntry> get recentWords {
    final entries = _vault.values.where((e) => e.lastSeen != null).toList()
      ..sort((a, b) => b.lastSeen!.compareTo(a.lastSeen!));
    return entries;
  }

  bool get canReview => weakWords.isNotEmpty;

  /// Builds a review session from the weakest entries. Uses the same
  /// [Exercise] types as the Path so there is exactly one player.
  LessonSession buildReviewSession({int size = 6, Random? random}) {
    final rng = random ?? Random();
    final pool = weakWords.isEmpty ? vault : weakWords;
    final picked = pool.take(size).toList();
    final distractors = vault.length > 1 ? vault : picked;

    final exercises = <Exercise>[];
    for (var i = 0; i < picked.length; i++) {
      final entry = picked[i];
      final options = <String>{entry.gloss};
      for (final other in distractors) {
        if (options.length >= 4) break;
        if (other.id != entry.id) options.add(other.gloss);
      }
      final shuffled = options.toList()..shuffle(rng);
      exercises.add(
        MultipleChoiceExercise(
          id: 'review_${entry.id}',
          prompt: 'What does this mean?',
          question: entry.term,
          note: entry.romanization,
          vocabIds: [entry.id],
          options: shuffled,
          correctIndex: shuffled.indexOf(entry.gloss),
        ),
      );
    }

    return LessonSession(
      lessonId: 'review',
      title: 'Review',
      exercises: exercises,
      // Half XP — reviews reinforce, they don't advance the course.
      xpPerCorrect: 5,
    );
  }

  // ── Achievements ────────────────────────────────────────────────────

  List<Achievement> get achievements => [
    Achievement(
      id: 'first_forge',
      title: 'First forge',
      criterion: 'Finish one lesson',
      icon: Icons.local_fire_department_outlined,
      earned: _lessonsCompleted >= 1,
    ),
    Achievement(
      id: 'unit_done',
      title: 'Unit cleared',
      criterion: 'Finish a whole unit',
      icon: Icons.workspace_premium_outlined,
      earned: _course?.units.any((u) => unitProgress(u) >= 1) ?? false,
    ),
    Achievement(
      id: 'word_smith',
      title: 'Wordsmith',
      criterion: 'Bank 10 words',
      icon: Icons.layers_outlined,
      earned: _vault.length >= 10,
    ),
    Achievement(
      id: 'tempered',
      title: 'Tempered',
      criterion: 'Take a word to full strength',
      icon: Icons.bolt_outlined,
      earned: _vault.values.any((e) => e.strength >= VocabEntry.maxStrength),
    ),
    Achievement(
      id: 'goal_met',
      title: 'On target',
      criterion: 'Hit your daily goal',
      icon: Icons.adjust_outlined,
      earned: xpToday >= _goal.xp,
    ),
    Achievement(
      id: 'century',
      title: 'Century',
      criterion: 'Earn 100 XP',
      icon: Icons.military_tech_outlined,
      earned: _totalXp >= 100,
    ),
  ];
}
