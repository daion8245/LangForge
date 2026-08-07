import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../models/lesson.dart';
import '../../state/app_state.dart';
import '../lesson/lesson_screen.dart';
import 'lesson_intro_sheet.dart';

/// The unit/lesson map. See `docs/screens.md`.
class PathScreen extends StatelessWidget {
  const PathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final course = state.course;
    if (course == null) return const SizedBox.shrink();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 168,
          backgroundColor: context.c.canvas,
          surfaceTintColor: Colors.transparent,
          title: Row(
            children: [
              Text(course.flag, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: LFSpace.sm),
              Text(course.name, style: context.t.subtitle),
            ],
          ),
          actions: [
            _StreakChip(days: state.streakDays),
            const SizedBox(width: LFSpace.lg),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    LFSpace.lg,
                    0,
                    LFSpace.lg,
                    LFSpace.lg,
                  ),
                  child: _DailyGoalCard(state: state),
                ),
              ),
            ),
          ),
        ),
        for (final unit in course.units)
          SliverToBoxAdapter(child: _UnitSection(unit: unit)),
        const SliverToBoxAdapter(child: SizedBox(height: LFSpace.xxl)),
      ],
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Row(
      children: [
        Icon(Icons.local_fire_department, size: 18, color: c.gold),
        const SizedBox(width: 4),
        Text(
          '$days',
          style: context.t.label.copyWith(color: c.gold, fontSize: 15),
        ),
      ],
    );
  }
}

/// Today's XP against the daily goal.
class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final met = state.xpToday >= state.goal.xp;
    return LFCard(
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    value: state.dailyGoalProgress,
                    strokeWidth: 5,
                    backgroundColor: c.hairline,
                    valueColor: AlwaysStoppedAnimation(met ? c.mint : c.ember),
                  ),
                ),
                if (met) Icon(Icons.check, size: 18, color: c.mint),
              ],
            ),
          ),
          const SizedBox(width: LFSpace.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  met ? 'Daily goal met' : 'Daily goal',
                  style: context.t.subtitle,
                ),
                const SizedBox(height: 2),
                Text(
                  '${state.xpToday} / ${state.goal.xp} XP today',
                  style: context.t.labelMuted,
                ),
              ],
            ),
          ),
          LFPill(
            label: '${state.totalXp} XP',
            icon: Icons.bolt,
            color: c.gold,
            background: c.gold.withValues(alpha: 0.12),
          ),
        ],
      ),
    );
  }
}

class _UnitSection extends StatelessWidget {
  const _UnitSection({required this.unit});

  final Unit unit;

  /// Horizontal offsets, as a fraction of half-width, giving the node column
  /// a gentle left-right stagger instead of a straight list.
  static const List<double> _stagger = [0, 0.38, 0.52, 0.38, 0, -0.38, -0.52];

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final state = AppScope.of(context);
    final done = state.completedIn(unit);

    return Padding(
      padding: const EdgeInsets.only(bottom: LFSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: LFSpace.lg),
            child: LFCard(
              fill: c.hairline.withValues(alpha: 0.35),
              borderColor: Colors.transparent,
              padding: const EdgeInsets.all(LFSpace.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(unit.title, style: context.t.subtitle),
                        const SizedBox(height: 2),
                        Text(unit.subtitle, style: context.t.labelMuted),
                      ],
                    ),
                  ),
                  const SizedBox(width: LFSpace.md),
                  LFPill(label: '$done/${unit.lessons.length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: LFSpace.sm),
          for (var i = 0; i < unit.lessons.length; i++)
            _LessonRow(
              lesson: unit.lessons[i],
              dx: _stagger[i % _stagger.length],
              previousDx: i == 0 ? null : _stagger[(i - 1) % _stagger.length],
              index: i,
            ),
        ],
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({
    required this.lesson,
    required this.dx,
    required this.previousDx,
    required this.index,
  });

  final Lesson lesson;
  final double dx;
  final double? previousDx;
  final int index;

  static const double rowHeight = 96;
  static const double nodeSize = 60;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: rowHeight,
      child: CustomPaint(
        painter: previousDx == null
            ? null
            : _ConnectorPainter(
                fromDx: previousDx!,
                toDx: dx,
                color: context.c.hairline,
                rowHeight: rowHeight,
                clearance: nodeSize / 2 + 8,
              ),
        child: Align(
          alignment: Alignment(dx, 0),
          child: _LessonNode(lesson: lesson, index: index),
        ),
      ),
    );
  }
}

/// Dashed line from the previous node's centre to this one's. Both ends are
/// trimmed by [clearance] so the line never runs under a node.
class _ConnectorPainter extends CustomPainter {
  const _ConnectorPainter({
    required this.fromDx,
    required this.toDx,
    required this.color,
    required this.rowHeight,
    required this.clearance,
  });

  final double fromDx;
  final double toDx;
  final Color color;
  final double rowHeight;
  final double clearance;

  @override
  void paint(Canvas canvas, Size size) {
    final half = size.width / 2;
    final start = Offset(half + fromDx * half, -rowHeight / 2);
    final end = Offset(half + toDx * half, rowHeight / 2);

    final delta = end - start;
    final length = delta.distance;
    if (length <= clearance * 2) return;

    final unit = delta / length;
    final a = start + unit * clearance;
    final b = end - unit * clearance;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const dash = 5.0;
    const gap = 6.0;
    final span = (b - a).distance;
    for (var t = 0.0; t < span; t += dash + gap) {
      final p1 = a + unit * t;
      final p2 = a + unit * math.min(t + dash, span);
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(_ConnectorPainter old) =>
      old.fromDx != fromDx || old.toDx != toDx || old.color != color;
}

/// A single lesson node. Exactly one node on screen pulses — the current one.
class _LessonNode extends StatefulWidget {
  const _LessonNode({required this.lesson, required this.index});

  final Lesson lesson;
  final int index;

  @override
  State<_LessonNode> createState() => _LessonNodeState();
}

class _LessonNodeState extends State<_LessonNode>
    with TickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: LFMotion.pulse,
  );
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  @override
  void dispose() {
    _pulse.dispose();
    _shake.dispose();
    super.dispose();
  }

  void _onTap(AppState state, LessonStatus status) {
    if (status == LessonStatus.locked) {
      _shake.forward(from: 0);
      final blocker = state.blockerTitleFor(widget.lesson.id);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            content: Text(
              blocker == null
                  ? 'Finish the earlier lessons first.'
                  : 'Finish "$blocker" first.',
            ),
          ),
        );
      return;
    }
    showLessonIntroSheet(context, widget.lesson);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final state = AppScope.of(context);
    final status = state.statusOf(widget.lesson.id);

    // Only the current node animates; the rest hold still.
    if (status == LessonStatus.current) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else if (_pulse.isAnimating) {
      _pulse.stop();
    }

    final (Color fill, Color glyphColor, IconData glyph) = switch (status) {
      LessonStatus.complete => (c.mint, c.onEmber, Icons.check_rounded),
      LessonStatus.current ||
      LessonStatus.available => (c.ember, c.onEmber, Icons.bolt_rounded),
      LessonStatus.locked => (c.hairline, c.inkMuted, Icons.lock_rounded),
    };

    final node = Semantics(
      button: true,
      label: '${widget.lesson.title}, ${status.name}',
      child: GestureDetector(
        onTap: () => _onTap(state, status),
        child: Container(
          width: _LessonRow.nodeSize,
          height: _LessonRow.nodeSize,
          decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
          child: Icon(glyph, color: glyphColor, size: 26),
        ),
      ),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([_pulse, _shake]),
      builder: (context, child) {
        // 3 damped oscillations, ~6px amplitude.
        final shakeX =
            math.sin(_shake.value * math.pi * 6) * 6 * (1 - _shake.value);
        return Transform.translate(
          offset: Offset(shakeX, 0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (status == LessonStatus.current)
                Container(
                  width: _LessonRow.nodeSize + 10 + _pulse.value * 14,
                  height: _LessonRow.nodeSize + 10 + _pulse.value * 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.ember.withValues(alpha: 0.18 * (1 - _pulse.value)),
                  ),
                ),
              child!,
            ],
          ),
        );
      },
      child: node,
    );
  }
}

/// Opens the intro sheet and, if the learner starts, runs the lesson.
Future<void> showLessonIntroSheet(BuildContext context, Lesson lesson) async {
  final start = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: context.c.surface,
    showDragHandle: true,
    // Scroll-controlled so a long word list is not clipped at the default
    // 9/16 height on short screens.
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.85,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(LFRadius.xl)),
    ),
    builder: (context) => LessonIntroSheet(lesson: lesson),
  );

  if (start != true || !context.mounted) return;
  await Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => LessonScreen(lesson: lesson)));
}
