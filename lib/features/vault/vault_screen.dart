import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../models/vocab_entry.dart';
import '../../state/app_state.dart';
import '../lesson/lesson_screen.dart';
import 'vocab_detail_sheet.dart';

enum _VaultFilter { all, weak, strong, recent }

extension on _VaultFilter {
  String get label => switch (this) {
    _VaultFilter.all => 'All',
    _VaultFilter.weak => 'Weak',
    _VaultFilter.strong => 'Strong',
    _VaultFilter.recent => 'Recent',
  };

  List<VocabEntry> apply(AppState state) => switch (this) {
    _VaultFilter.all => state.vault,
    _VaultFilter.weak => state.weakWords,
    _VaultFilter.strong => state.strongWords,
    _VaultFilter.recent => state.recentWords,
  };
}

/// The vocabulary Vault. See `docs/screens.md`.
class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  _VaultFilter _filter = _VaultFilter.all;

  void _startReview(AppState state) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            LessonScreen.review(providedSession: state.buildReviewSession()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final state = AppScope.of(context);
    final entries = _filter.apply(state);
    final weakCount = state.weakWords.length;

    if (state.vault.isEmpty) {
      return SafeArea(
        child: LFEmptyState(
          icon: Icons.layers_outlined,
          title: 'Nothing forged yet',
          message:
              'Words land here once you finish the lesson that introduces '
              'them. Complete a lesson on the Path to fill the Vault.',
        ),
      );
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              LFSpace.lg,
              LFSpace.lg,
              LFSpace.lg,
              LFSpace.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vault', style: context.t.display),
                const SizedBox(height: LFSpace.xs),
                Text(
                  '${state.vault.length} words · $weakCount need review',
                  style: context.t.bodyMuted,
                ),
                const SizedBox(height: LFSpace.lg),
                LFButton(
                  label: state.canReview
                      ? 'Review $weakCount words'
                      : 'Nothing to review yet',
                  icon: Icons.refresh_rounded,
                  onPressed: state.canReview ? () => _startReview(state) : null,
                ),
                if (!state.canReview) ...[
                  const SizedBox(height: LFSpace.sm),
                  Text(
                    'Everything is above review strength. Words weaken over '
                    'time — check back later.',
                    style: context.t.labelMuted,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: LFSpace.lg),
              children: [
                for (final filter in _VaultFilter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: LFSpace.sm),
                    child: ChoiceChip(
                      label: Text(filter.label),
                      selected: _filter == filter,
                      onSelected: (_) => setState(() => _filter = filter),
                      showCheckmark: false,
                      backgroundColor: c.surface,
                      selectedColor: c.emberDim,
                      side: BorderSide(
                        color: _filter == filter ? c.ember : c.hairline,
                      ),
                      labelStyle: context.t.label,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? LFEmptyState(
                    icon: Icons.filter_alt_outlined,
                    title: 'Nothing here',
                    message: 'No words match the ${_filter.label} filter yet.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      LFSpace.lg,
                      LFSpace.sm,
                      LFSpace.lg,
                      LFSpace.xxl,
                    ),
                    itemCount: entries.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: LFSpace.sm),
                      child: _VocabRow(entry: entries[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _VocabRow extends StatelessWidget {
  const _VocabRow({required this.entry});

  final VocabEntry entry;

  @override
  Widget build(BuildContext context) {
    return LFCard(
      padding: const EdgeInsets.symmetric(
        horizontal: LFSpace.lg,
        vertical: LFSpace.md,
      ),
      onTap: () => showVocabDetailSheet(context, entry),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.term, style: context.t.target),
                const SizedBox(height: 2),
                Text(entry.gloss, style: context.t.labelMuted),
              ],
            ),
          ),
          const SizedBox(width: LFSpace.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              LFStrengthMeter(strength: entry.effectiveStrength),
              const SizedBox(height: LFSpace.sm),
              Text(_relative(entry.lastSeen), style: context.t.labelMuted),
            ],
          ),
        ],
      ),
    );
  }
}

String _relative(DateTime? time) {
  if (time == null) return 'new';
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
