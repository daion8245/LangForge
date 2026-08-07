import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../models/vocab_entry.dart';

Future<void> showVocabDetailSheet(BuildContext context, VocabEntry entry) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.c.surface,
    showDragHandle: true,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.85,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(LFRadius.xl)),
    ),
    builder: (context) => VocabDetailSheet(entry: entry),
  );
}

class VocabDetailSheet extends StatelessWidget {
  const VocabDetailSheet({required this.entry, super.key});

  final VocabEntry entry;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final state = AppScope.of(context);
    final lesson = state.lessonById(entry.lessonId);
    final strength = entry.effectiveStrength;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          LFSpace.lg,
          0,
          LFSpace.lg,
          LFSpace.xl,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.term, style: context.t.display),
              const SizedBox(height: LFSpace.xs),
              Text(
                '${entry.romanization} · ${entry.partOfSpeech}',
                style: context.t.bodyMuted,
              ),
              const SizedBox(height: LFSpace.md),
              Text(entry.gloss, style: context.t.subtitle),
              const SizedBox(height: LFSpace.xl),

              Text('Strength', style: context.t.label),
              const SizedBox(height: LFSpace.sm),
              Row(
                children: [
                  for (var i = 0; i < VocabEntry.maxStrength; i++)
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(right: LFSpace.sm),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < strength ? c.ember : Colors.transparent,
                        border: Border.all(
                          color: i < strength ? c.ember : c.hairline,
                          width: 2,
                        ),
                      ),
                    ),
                  const SizedBox(width: LFSpace.sm),
                  Text(
                    strength == 0
                        ? 'Needs work'
                        : (entry.needsReview ? 'Fading' : 'Solid'),
                    style: context.t.labelMuted,
                  ),
                ],
              ),
              const SizedBox(height: LFSpace.xl),

              Text('In context', style: context.t.label),
              const SizedBox(height: LFSpace.sm),
              LFCard(
                fill: c.hairline.withValues(alpha: 0.3),
                borderColor: Colors.transparent,
                padding: const EdgeInsets.all(LFSpace.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.example, style: context.t.target),
                    const SizedBox(height: LFSpace.xs),
                    Text(entry.exampleGloss, style: context.t.bodyMuted),
                  ],
                ),
              ),
              const SizedBox(height: LFSpace.lg),

              Wrap(
                spacing: LFSpace.sm,
                runSpacing: LFSpace.sm,
                children: [
                  if (lesson != null)
                    LFPill(
                      label: 'From “${lesson.title}”',
                      icon: Icons.school_outlined,
                    ),
                  LFPill(
                    label: entry.timesSeen == 0
                        ? 'Not practised yet'
                        : 'Seen ${entry.timesSeen}× · '
                              '${(entry.accuracy * 100).round()}% right',
                    icon: Icons.history,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
