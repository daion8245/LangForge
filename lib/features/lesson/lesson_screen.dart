import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../models/lesson.dart';
import '../../state/lesson_session.dart';
import 'exercise_view.dart';
import 'lesson_complete_screen.dart';

/// The lesson player. Owns a [LessonSession] for its lifetime.
///
/// Checking and continuing are two separate taps — see `docs/architecture.md`.
class LessonScreen extends StatefulWidget {
  const LessonScreen({required Lesson this.lesson, super.key})
    : providedSession = null,
      isReview = false;

  /// Runs a session built elsewhere (Vault review). The screen still owns and
  /// disposes it.
  const LessonScreen.review({
    required LessonSession this.providedSession,
    super.key,
  }) : lesson = null,
       isReview = true;

  final Lesson? lesson;
  final LessonSession? providedSession;
  final bool isReview;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final LessonSession _session;

  @override
  void initState() {
    super.initState();
    final lesson = widget.lesson;
    _session =
        widget.providedSession ??
        LessonSession(
          lessonId: lesson!.id,
          title: lesson.title,
          exercises: lesson.exercises,
        );
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  Future<void> _confirmQuit() async {
    final quit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit lesson?'),
        content: const Text('Progress in this lesson is lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep going'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Quit',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (quit == true && mounted) Navigator.of(context).pop();
  }

  void _onPrimary() {
    if (_session.outcome == null) {
      _session.submit();
      return;
    }
    _session.advance();
    if (_session.status != SessionStatus.inProgress) _finish();
  }

  void _finish() {
    final result = _session.result;
    AppScope.read(context).applyResult(result, isReview: widget.isReview);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => LessonCompleteScreen(
          result: result,
          clearedCount: _session.clearedCount,
          isReview: widget.isReview,
          retryLesson: widget.lesson,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmQuit();
      },
      child: Scaffold(
        backgroundColor: c.canvas,
        body: SafeArea(
          child: AnimatedBuilder(
            animation: _session,
            builder: (context, _) {
              final outcome = _session.outcome;
              final exercise = _session.current;
              return Column(
                children: [
                  _TopBar(session: _session, onClose: _confirmQuit),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        LFSpace.lg,
                        LFSpace.lg,
                        LFSpace.lg,
                        LFSpace.xxl,
                      ),
                      child: ExerciseView(
                        // Rebuilt per position so a requeued exercise comes
                        // back with a clean slate.
                        key: ValueKey('${_session.position}:${exercise.id}'),
                        exercise: exercise,
                        locked: _session.isLocked,
                        wasCorrect: outcome?.correct,
                        onChanged: _session.setAnswer,
                      ),
                    ),
                  ),
                  _ActionBar(
                    outcome: outcome,
                    enabled: _session.hasAnswer,
                    onPressed: _onPrimary,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.session, required this.onClose});

  final LessonSession session;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        LFSpace.sm,
        LFSpace.sm,
        LFSpace.lg,
        LFSpace.sm,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Quit lesson',
          ),
          Expanded(child: LFProgressBar(value: session.progress)),
          const SizedBox(width: LFSpace.lg),
          _Hearts(remaining: session.hearts, max: session.maxHearts),
        ],
      ),
    );
  }
}

class _Hearts extends StatelessWidget {
  const _Hearts({required this.remaining, required this.max});

  final int remaining;
  final int max;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      label: '$remaining of $max hearts left',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < max; i++)
            AnimatedScale(
              duration: LFMotion.feedback,
              curve: Curves.easeOutBack,
              scale: i < remaining ? 1 : 0.75,
              child: Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Icon(
                  i < remaining
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 20,
                  color: i < remaining ? c.crimson : c.hairline,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Check / Continue, with the feedback banner sliding in above it.
///
/// The button row keeps a fixed height and position so Continue always lands
/// under the same thumb position.
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.outcome,
    required this.enabled,
    required this.onPressed,
  });

  final AnswerOutcome? outcome;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final correct = outcome?.correct ?? false;
    final fill = outcome == null
        ? Colors.transparent
        : (correct ? c.mintDim : c.crimsonDim);

    return AnimatedContainer(
      duration: LFMotion.feedback,
      curve: Curves.easeOutCubic,
      color: fill,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: LFMotion.feedback,
              curve: Curves.easeOutCubic,
              alignment: Alignment.bottomCenter,
              child: outcome == null
                  ? const SizedBox(width: double.infinity)
                  : _FeedbackBanner(outcome: outcome!),
            ),
            Padding(
              padding: const EdgeInsets.all(LFSpace.lg),
              child: LFButton(
                label: outcome == null ? 'Check' : 'Continue',
                tone: outcome == null
                    ? LFButtonTone.ember
                    : (correct ? LFButtonTone.mint : LFButtonTone.crimson),
                onPressed: outcome == null && !enabled ? null : onPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({required this.outcome});

  final AnswerOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final correct = outcome.correct;
    final accent = correct ? c.mint : c.crimson;

    return Padding(
      padding: const EdgeInsets.fromLTRB(LFSpace.lg, LFSpace.lg, LFSpace.lg, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: accent,
          ),
          const SizedBox(width: LFSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  correct ? 'Nice.' : 'Not quite.',
                  style: context.t.subtitle.copyWith(color: accent),
                ),
                if (!correct) ...[
                  const SizedBox(height: 2),
                  Text(outcome.correctAnswerText, style: context.t.target),
                ],
                if (outcome.note != null) ...[
                  const SizedBox(height: 2),
                  Text(outcome.note!, style: context.t.labelMuted),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
