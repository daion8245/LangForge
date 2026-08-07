import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../models/exercise.dart';
import 'option_row.dart';

/// Listening comprehension.
///
/// The prototype has no audio. Tapping the speaker animates and reveals the
/// spoken text, styled as a dashed note so it reads as scaffolding rather
/// than part of the exercise (see `docs/prototype-scope.md`).
class ListeningView extends StatefulWidget {
  const ListeningView({
    required this.exercise,
    required this.locked,
    required this.onChanged,
    super.key,
  });

  final ListeningExercise exercise;
  final bool locked;
  final ValueChanged<Object?> onChanged;

  @override
  State<ListeningView> createState() => _ListeningViewState();
}

class _ListeningViewState extends State<ListeningView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ripple = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  int? _selected;
  bool _played = false;

  @override
  void dispose() {
    _ripple.dispose();
    super.dispose();
  }

  void _play() {
    _ripple.forward(from: 0);
    if (!_played) setState(() => _played = true);
  }

  void _select(int index) {
    if (widget.locked) return;
    setState(() => _selected = index);
    widget.onChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final e = widget.exercise;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExercisePrompt(text: e.prompt),
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: _play,
                child: AnimatedBuilder(
                  animation: _ripple,
                  builder: (context, child) => Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 96 + _ripple.value * 36,
                        height: 96 + _ripple.value * 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.ember.withValues(
                            alpha: 0.2 * (1 - _ripple.value),
                          ),
                        ),
                      ),
                      child!,
                    ],
                  ),
                  child: Semantics(
                    button: true,
                    label: 'Play audio',
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: c.ember,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.volume_up_rounded,
                        size: 40,
                        color: c.onEmber,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: LFSpace.md),
              TextButton.icon(
                onPressed: _play,
                icon: Icon(
                  Icons.slow_motion_video,
                  size: 18,
                  color: c.inkMuted,
                ),
                label: Text('Play slowly', style: context.t.labelMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: LFSpace.lg),
        AnimatedSize(
          duration: LFMotion.feedback,
          curve: Curves.easeOutCubic,
          child: _played
              ? _ScaffoldNote(text: e.spoken)
              : const SizedBox(width: double.infinity),
        ),
        const SizedBox(height: LFSpace.xl),
        for (var i = 0; i < e.options.length; i++)
          OptionRow(
            label: e.options[i],
            targetLanguage: true,
            state: optionStateFor(
              index: i,
              selected: _selected,
              correctIndex: e.correctIndex,
              locked: widget.locked,
            ),
            onTap: widget.locked ? null : () => _select(i),
          ),
      ],
    );
  }
}

/// Explicitly-marked prototype scaffolding standing in for audio.
class _ScaffoldNote extends StatelessWidget {
  const _ScaffoldNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return DottedBorderBox(
      child: Row(
        children: [
          Icon(Icons.graphic_eq, size: 16, color: c.inkMuted),
          const SizedBox(width: LFSpace.sm),
          Expanded(child: Text(text, style: context.t.target)),
          const SizedBox(width: LFSpace.sm),
          Text('no audio in prototype', style: context.t.labelMuted),
        ],
      ),
    );
  }
}

/// A dashed-border container, used to mark prototype stand-ins.
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DashedBorderPainter(context.c.hairline),
    child: Padding(padding: const EdgeInsets.all(LFSpace.md), child: child),
  );
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(LFRadius.md),
    );
    final path = Path()..addRRect(rect);
    const dash = 6.0;
    const gap = 5.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}
