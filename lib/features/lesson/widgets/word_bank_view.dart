import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../core/ui.dart';
import '../../../models/exercise.dart';
import 'option_row.dart';

/// The core exercise: build the translation from a bank of tokens.
///
/// Tokens are tracked by their index in [WordBankExercise.bank] rather than by
/// text, so a bank containing the same token twice still behaves correctly.
class WordBankView extends StatefulWidget {
  const WordBankView({
    required this.exercise,
    required this.locked,
    required this.wasCorrect,
    required this.onChanged,
    super.key,
  });

  final WordBankExercise exercise;
  final bool locked;

  /// Null until the learner has checked.
  final bool? wasCorrect;
  final ValueChanged<Object?> onChanged;

  @override
  State<WordBankView> createState() => _WordBankViewState();
}

class _WordBankViewState extends State<WordBankView> {
  /// Indices into `exercise.bank`, in the order the learner placed them.
  final List<int> _tray = [];

  /// Display order of the bank, shuffled once.
  late final List<int> _bankOrder;

  @override
  void initState() {
    super.initState();
    _bankOrder = List<int>.generate(widget.exercise.bank.length, (i) => i)
      ..shuffle(Random());
  }

  void _place(int bankIndex) {
    if (widget.locked || _tray.contains(bankIndex)) return;
    setState(() => _tray.add(bankIndex));
    _report();
  }

  void _remove(int bankIndex) {
    if (widget.locked) return;
    setState(() => _tray.remove(bankIndex));
    _report();
  }

  void _report() {
    widget.onChanged(
      _tray.isEmpty ? null : [for (final i in _tray) widget.exercise.bank[i]],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final e = widget.exercise;
    final trayState = switch (widget.wasCorrect) {
      true => LFAnswerState.correct,
      false => LFAnswerState.wrong,
      null => LFAnswerState.selected,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExercisePrompt(text: e.prompt),
        Text(e.source, style: context.t.title),
        const SizedBox(height: LFSpace.xl),

        // Answer tray.
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 108),
          child: Stack(
            children: [
              const Positioned.fill(child: _RuledLines()),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: _tray.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: LFSpace.md),
                        child: Text(
                          'Tap the words below',
                          style: context.t.labelMuted,
                        ),
                      )
                    : Wrap(
                        spacing: LFSpace.sm,
                        runSpacing: LFSpace.md,
                        children: [
                          for (final i in _tray)
                            _Token(
                              label: e.bank[i],
                              state: trayState,
                              onTap: widget.locked ? null : () => _remove(i),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: LFSpace.xl),

        // Bank. Used tokens stay in place as empty slots so the bank never
        // reflows under the learner's finger.
        Wrap(
          spacing: LFSpace.sm,
          runSpacing: LFSpace.md,
          children: [
            for (final i in _bankOrder)
              _tray.contains(i)
                  ? _Token(
                      label: e.bank[i],
                      state: LFAnswerState.idle,
                      onTap: null,
                      hollow: true,
                    )
                  : _Token(
                      label: e.bank[i],
                      state: LFAnswerState.idle,
                      onTap: widget.locked ? null : () => _place(i),
                    ),
          ],
        ),

        if (widget.wasCorrect == false) ...[
          const SizedBox(height: LFSpace.xl),
          Container(
            padding: const EdgeInsets.all(LFSpace.md),
            decoration: BoxDecoration(
              color: c.mintDim,
              borderRadius: BorderRadius.circular(LFRadius.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_rounded, size: 18, color: c.mint),
                const SizedBox(width: LFSpace.sm),
                Expanded(
                  child: Text(e.solution.join(' '), style: context.t.target),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// One tappable token, in the tray or the bank.
class _Token extends StatelessWidget {
  const _Token({
    required this.label,
    required this.state,
    required this.onTap,
    this.hollow = false,
  });

  final String label;
  final LFAnswerState state;
  final VoidCallback? onTap;

  /// Renders as an empty slot of the same size — the token is in the tray.
  final bool hollow;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final palette = LFAnswerPalette.of(context, state);
    return AnimatedContainer(
      duration: LFMotion.tile,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: hollow ? c.hairline.withValues(alpha: 0.4) : palette.fill,
        border: Border.all(
          color: hollow ? Colors.transparent : palette.border,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(LFRadius.md),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(LFRadius.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: LFSpace.md,
              vertical: LFSpace.md,
            ),
            child: Text(
              label,
              style: context.t.target.copyWith(
                color: hollow ? Colors.transparent : palette.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Two dashed rules behind the answer tray, so an empty tray reads as
/// something to fill in.
class _RuledLines extends StatelessWidget {
  const _RuledLines();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _RuledLinesPainter(context.c.hairline));
}

class _RuledLinesPainter extends CustomPainter {
  const _RuledLinesPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    const dash = 6.0;
    const gap = 6.0;
    for (final y in [52.0, 104.0]) {
      if (y > size.height) continue;
      for (var x = 0.0; x < size.width; x += dash + gap) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x + dash > size.width ? size.width : x + dash, y),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_RuledLinesPainter old) => old.color != color;
}
