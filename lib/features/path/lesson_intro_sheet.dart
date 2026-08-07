import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../models/lesson.dart';

/// Bottom sheet shown before starting a lesson. Pops `true` to start.
class LessonIntroSheet extends StatelessWidget {
  const LessonIntroSheet({required this.lesson, super.key});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final state = AppScope.of(context);
    final words = [for (final id in lesson.newWordIds) ?state.definitionOf(id)];
    final replaying = state.isLessonComplete(lesson.id);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          LFSpace.lg,
          0,
          LFSpace.lg,
          LFSpace.lg,
        ),
        // The word list can outgrow a short screen, so it scrolls while the
        // Start button stays pinned.
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lesson.title, style: context.t.title),
                    const SizedBox(height: LFSpace.xs),
                    Text(lesson.subtitle, style: context.t.bodyMuted),
                    const SizedBox(height: LFSpace.lg),
                    Row(
                      children: [
                        LFPill(
                          label: '${lesson.exercises.length} exercises',
                          icon: Icons.format_list_numbered,
                        ),
                        const SizedBox(width: LFSpace.sm),
                        LFPill(
                          label: '~${lesson.estimatedMinutes} min',
                          icon: Icons.schedule,
                        ),
                        if (replaying) ...[
                          const SizedBox(width: LFSpace.sm),
                          LFPill(
                            label: 'Replay',
                            icon: Icons.replay,
                            color: c.mint,
                            background: c.mint.withValues(alpha: 0.12),
                          ),
                        ],
                      ],
                    ),
                    if (words.isNotEmpty) ...[
                      const SizedBox(height: LFSpace.xl),
                      Text('New words', style: context.t.label),
                      const SizedBox(height: LFSpace.md),
                      for (final word in words)
                        Padding(
                          padding: const EdgeInsets.only(bottom: LFSpace.sm),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(
                                  top: 8,
                                  right: LFSpace.md,
                                ),
                                decoration: BoxDecoration(
                                  color: c.ember,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: word.term,
                                        style: context.t.target,
                                      ),
                                      TextSpan(
                                        text: '  ${word.gloss}',
                                        style: context.t.bodyMuted,
                                      ),
                                    ],
                                  ),
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
            const SizedBox(height: LFSpace.xl),
            LFButton(
              label: replaying ? 'Practise again' : 'Start',
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    );
  }
}
