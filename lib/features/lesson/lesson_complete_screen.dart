import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../models/lesson.dart';
import '../../state/lesson_session.dart';
import 'lesson_screen.dart';

/// Success and out-of-hearts variants of the end-of-session screen.
class LessonCompleteScreen extends StatelessWidget {
  const LessonCompleteScreen({
    required this.result,
    required this.clearedCount,
    required this.isReview,
    this.retryLesson,
    super.key,
  });

  final LessonResult result;
  final int clearedCount;
  final bool isReview;

  /// Null for review sessions, which cannot be retried in place.
  final Lesson? retryLesson;

  void _backToPath(BuildContext context) =>
      Navigator.of(context).popUntil((route) => route.isFirst);

  void _retry(BuildContext context) {
    final lesson = retryLesson;
    if (lesson == null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => LessonScreen(lesson: lesson)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final state = AppScope.of(context);
    final passed = result.passed;
    final accent = passed ? c.mint : c.crimson;

    return Scaffold(
      backgroundColor: c.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(LFSpace.lg),
                child: Column(
                  children: [
                    const SizedBox(height: LFSpace.xxl),
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: passed ? c.mintDim : c.crimsonDim,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        passed ? Icons.hardware_rounded : Icons.favorite_border,
                        size: 40,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: LFSpace.xl),
                    Text(
                      passed
                          ? (isReview ? 'Review done' : 'Lesson forged')
                          : 'Out of hearts',
                      style: context.t.display,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: LFSpace.sm),
                    Text(
                      passed
                          ? 'Those words are yours now. Keep them warm.'
                          : 'You cleared $clearedCount of ${result.totalExercises}. '
                                'Run it again — nothing is lost.',
                      style: context.t.bodyMuted,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: LFSpace.xxl),
                    Row(
                      children: [
                        Expanded(
                          child: _CountUpStat(
                            icon: Icons.bolt,
                            value: result.xpEarned,
                            suffix: ' XP',
                            label: 'Earned',
                            accent: c.gold,
                          ),
                        ),
                        const SizedBox(width: LFSpace.md),
                        Expanded(
                          child: LFStatTile(
                            icon: Icons.center_focus_strong,
                            value: '${(result.accuracy * 100).round()}%',
                            label: 'First try',
                            accent: accent,
                          ),
                        ),
                        const SizedBox(width: LFSpace.md),
                        Expanded(
                          child: LFStatTile(
                            icon: Icons.schedule,
                            value: _formatDuration(result.elapsed),
                            label: 'Time',
                            accent: c.inkMuted,
                          ),
                        ),
                      ],
                    ),
                    if (passed) ...[
                      const SizedBox(height: LFSpace.md),
                      LFCard(
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              color: c.gold,
                              size: 28,
                            ),
                            const SizedBox(width: LFSpace.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Day ${state.streakDays}',
                                    style: context.t.subtitle,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    state.xpToday >= state.goal.xp
                                        ? 'Daily goal met'
                                        : '${state.goal.xp - state.xpToday} XP '
                                              'to today’s goal',
                                    style: context.t.labelMuted,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(LFSpace.lg),
              child: Column(
                children: [
                  if (!passed && retryLesson != null) ...[
                    LFButton(
                      label: 'Try again',
                      onPressed: () => _retry(context),
                    ),
                    const SizedBox(height: LFSpace.md),
                    LFButton(
                      label: 'Back to path',
                      tone: LFButtonTone.neutral,
                      onPressed: () => _backToPath(context),
                    ),
                  ] else
                    LFButton(
                      label: 'Continue',
                      tone: passed ? LFButtonTone.mint : LFButtonTone.ember,
                      onPressed: () => _backToPath(context),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDuration(Duration d) {
  final minutes = d.inMinutes;
  final seconds = d.inSeconds % 60;
  return minutes == 0 ? '${seconds}s' : '${minutes}m ${seconds}s';
}

/// XP tile that counts up — the one place motion is spent for effect.
class _CountUpStat extends StatelessWidget {
  const _CountUpStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
    this.suffix = '',
  });

  final IconData icon;
  final int value;
  final String label;
  final Color accent;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: LFMotion.countUp,
      curve: Curves.easeOutCubic,
      builder: (context, shown, _) => LFStatTile(
        icon: icon,
        value: '$shown$suffix',
        label: label,
        accent: accent,
      ),
    );
  }
}
