import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../core/ui.dart';
import '../../../models/exercise.dart';
import 'option_row.dart';

/// Two columns in independent random order. Tap one from each side; a correct
/// pair locks in mint, a wrong pair flashes crimson and clears.
///
/// The exercise reports `true` only when every pair is locked, so it can't be
/// failed — it's the warm-up (see `docs/product-brief.md`).
class MatchPairsView extends StatefulWidget {
  const MatchPairsView({
    required this.exercise,
    required this.locked,
    required this.onChanged,
    super.key,
  });

  final MatchPairsExercise exercise;
  final bool locked;
  final ValueChanged<Object?> onChanged;

  @override
  State<MatchPairsView> createState() => _MatchPairsViewState();
}

class _MatchPairsViewState extends State<MatchPairsView> {
  /// Pair indices, each column shuffled independently.
  late final List<int> _leftOrder;
  late final List<int> _rightOrder;

  final Set<int> _matched = <int>{};

  int? _leftSelected;
  int? _rightSelected;
  bool _flashingWrong = false;

  @override
  void initState() {
    super.initState();
    final count = widget.exercise.pairs.length;
    final rng = Random();
    _leftOrder = List<int>.generate(count, (i) => i)..shuffle(rng);
    _rightOrder = List<int>.generate(count, (i) => i)..shuffle(rng);
  }

  void _tapLeft(int pairIndex) {
    if (widget.locked || _flashingWrong || _matched.contains(pairIndex)) return;
    setState(() => _leftSelected = pairIndex);
    _resolve();
  }

  void _tapRight(int pairIndex) {
    if (widget.locked || _flashingWrong || _matched.contains(pairIndex)) return;
    setState(() => _rightSelected = pairIndex);
    _resolve();
  }

  void _resolve() {
    final left = _leftSelected;
    final right = _rightSelected;
    if (left == null || right == null) return;

    if (left == right) {
      setState(() {
        _matched.add(left);
        _leftSelected = null;
        _rightSelected = null;
      });
      if (_matched.length == widget.exercise.pairs.length) {
        widget.onChanged(true);
      }
      return;
    }

    setState(() => _flashingWrong = true);
    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      setState(() {
        _flashingWrong = false;
        _leftSelected = null;
        _rightSelected = null;
      });
    });
  }

  LFAnswerState _stateFor(int pairIndex, {required bool isLeft}) {
    if (_matched.contains(pairIndex)) return LFAnswerState.correct;
    final selected = isLeft ? _leftSelected : _rightSelected;
    if (selected != pairIndex) return LFAnswerState.idle;
    return _flashingWrong ? LFAnswerState.wrong : LFAnswerState.selected;
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.exercise;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExercisePrompt(text: e.prompt),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  for (final i in _leftOrder)
                    _MatchTile(
                      label: e.pairs[i].target,
                      targetLanguage: true,
                      state: _stateFor(i, isLeft: true),
                      onTap: () => _tapLeft(i),
                    ),
                ],
              ),
            ),
            const SizedBox(width: LFSpace.md),
            Expanded(
              child: Column(
                children: [
                  for (final i in _rightOrder)
                    _MatchTile(
                      label: e.pairs[i].source,
                      targetLanguage: false,
                      state: _stateFor(i, isLeft: false),
                      onTap: () => _tapRight(i),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: LFSpace.lg),
        Center(
          child: Text(
            '${_matched.length} of ${e.pairs.length} matched',
            style: context.t.labelMuted,
          ),
        ),
      ],
    );
  }
}

class _MatchTile extends StatelessWidget {
  const _MatchTile({
    required this.label,
    required this.state,
    required this.onTap,
    required this.targetLanguage,
  });

  final String label;
  final LFAnswerState state;
  final VoidCallback onTap;
  final bool targetLanguage;

  @override
  Widget build(BuildContext context) {
    final palette = LFAnswerPalette.of(context, state);
    final matched = state == LFAnswerState.correct;

    return AnimatedOpacity(
      duration: LFMotion.tile,
      opacity: matched ? 0.45 : 1,
      child: AnimatedContainer(
        duration: LFMotion.tile,
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: LFSpace.md),
        constraints: const BoxConstraints(minHeight: 60),
        decoration: BoxDecoration(
          color: palette.fill,
          border: Border.all(color: palette.border, width: 1.5),
          borderRadius: BorderRadius.circular(LFRadius.md),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(LFRadius.md),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: matched ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: LFSpace.md,
                vertical: LFSpace.md,
              ),
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: targetLanguage
                      ? context.t.target
                      : context.t.body.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
