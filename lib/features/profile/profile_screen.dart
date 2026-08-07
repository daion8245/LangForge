import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../state/app_state.dart';

/// Stats, achievements and settings. See `docs/screens.md`.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const List<String> _dayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  Future<void> _confirmReset(BuildContext context) async {
    final reset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset progress?'),
        content: const Text(
          'Clears XP, streak, the Vault and every completed lesson, and '
          'returns to onboarding.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Reset',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (reset == true && context.mounted) {
      AppScope.read(context).resetProgress();
    }
  }

  Future<void> _pickGoal(BuildContext context, AppState state) async {
    final goal = await showModalBottomSheet<DailyGoal>(
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
      builder: (context) => SafeArea(
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
                Text('Daily goal', style: context.t.title),
                const SizedBox(height: LFSpace.lg),
                for (final option in DailyGoal.values)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      option == state.goal
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: option == state.goal
                          ? context.c.ember
                          : context.c.hairline,
                    ),
                    title: Text(option.label, style: context.t.subtitle),
                    subtitle: Text(
                      option.description,
                      style: context.t.labelMuted,
                    ),
                    onTap: () => Navigator.of(context).pop(option),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    if (goal != null && context.mounted) {
      AppScope.read(context).setGoal(goal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final state = AppScope.of(context);
    final course = state.course;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          LFSpace.lg,
          LFSpace.lg,
          LFSpace.lg,
          LFSpace.xxl,
        ),
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.emberDim,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.ember, width: 2),
                ),
                child: Text(
                  'L',
                  style: context.t.title.copyWith(color: c.ember),
                ),
              ),
              const SizedBox(width: LFSpace.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Learner', style: context.t.title),
                    const SizedBox(height: 2),
                    Text(
                      course == null
                          ? 'No course'
                          : '${course.flag} ${course.name} · Level ${state.level}',
                      style: context.t.labelMuted,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: LFSpace.lg),
          LFProgressBar(value: state.levelProgress),
          const SizedBox(height: LFSpace.xs),
          Text(
            '${state.totalXp % 100} / 100 XP to level ${state.level + 1}',
            style: context.t.labelMuted,
          ),

          const SizedBox(height: LFSpace.xl),
          Row(
            children: [
              Expanded(
                child: LFStatTile(
                  icon: Icons.local_fire_department,
                  value: '${state.streakDays}',
                  label: 'Day streak',
                  accent: c.gold,
                ),
              ),
              const SizedBox(width: LFSpace.md),
              Expanded(
                child: LFStatTile(
                  icon: Icons.bolt,
                  value: '${state.totalXp}',
                  label: 'Total XP',
                  accent: c.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: LFSpace.md),
          Row(
            children: [
              Expanded(
                child: LFStatTile(
                  icon: Icons.layers,
                  value: '${state.vault.length}',
                  label: 'Words forged',
                  accent: c.ember,
                ),
              ),
              const SizedBox(width: LFSpace.md),
              Expanded(
                child: LFStatTile(
                  icon: Icons.center_focus_strong,
                  value: '${(state.overallAccuracy * 100).round()}%',
                  label: 'Accuracy',
                  accent: c.mint,
                ),
              ),
            ],
          ),

          const SizedBox(height: LFSpace.xl),
          const LFSectionHeader(title: 'This week'),
          const SizedBox(height: LFSpace.md),
          LFCard(
            child: _WeekStrip(state: state, labels: _dayLabels),
          ),

          if (course != null) ...[
            const SizedBox(height: LFSpace.xl),
            const LFSectionHeader(title: 'Units'),
            const SizedBox(height: LFSpace.md),
            for (final unit in course.units) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: LFSpace.md),
                child: LFCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(unit.title, style: context.t.subtitle),
                          ),
                          Text(
                            '${state.completedIn(unit)}/${unit.lessons.length}',
                            style: context.t.labelMuted,
                          ),
                        ],
                      ),
                      const SizedBox(height: LFSpace.md),
                      LFProgressBar(
                        value: state.unitProgress(unit),
                        height: 6,
                        color: state.unitProgress(unit) >= 1 ? c.mint : c.ember,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],

          const SizedBox(height: LFSpace.sm),
          const LFSectionHeader(title: 'Achievements'),
          const SizedBox(height: LFSpace.md),
          Wrap(
            spacing: LFSpace.md,
            runSpacing: LFSpace.md,
            children: [
              for (final achievement in state.achievements)
                _AchievementBadge(achievement: achievement),
            ],
          ),

          const SizedBox(height: LFSpace.xl),
          const LFSectionHeader(title: 'Settings'),
          const SizedBox(height: LFSpace.md),
          LFCard(
            padding: const EdgeInsets.symmetric(
              horizontal: LFSpace.lg,
              vertical: LFSpace.sm,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: LFSpace.md),
                  child: Row(
                    children: [
                      Icon(Icons.brightness_6_outlined, color: c.inkMuted),
                      const SizedBox(width: LFSpace.lg),
                      Expanded(child: Text('Theme', style: context.t.body)),
                      SegmentedButton<ThemeMode>(
                        showSelectedIcon: false,
                        style: const ButtonStyle(
                          visualDensity: VisualDensity.compact,
                        ),
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text('Auto'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            icon: Icon(Icons.light_mode_outlined, size: 16),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            icon: Icon(Icons.dark_mode_outlined, size: 16),
                          ),
                        ],
                        selected: {state.themeMode},
                        onSelectionChanged: (selection) =>
                            state.setThemeMode(selection.first),
                      ),
                    ],
                  ),
                ),
                Divider(color: c.hairline, height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.adjust_outlined, color: c.inkMuted),
                  title: Text('Daily goal', style: context.t.body),
                  trailing: Text(state.goal.label, style: context.t.labelMuted),
                  onTap: () => _pickGoal(context, state),
                ),
                Divider(color: c.hairline, height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.restart_alt, color: c.crimson),
                  title: Text(
                    'Reset progress',
                    style: context.t.body.copyWith(color: c.crimson),
                  ),
                  onTap: () => _confirmReset(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One bar per day against the daily goal; today is highlighted.
class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.state, required this.labels});

  final AppState state;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final weekly = state.weeklyXp;
    final goal = state.goal.xp;
    // Today is the last slot; label backwards from the real weekday.
    final todayIndex = DateTime.now().weekday - 1;

    return SizedBox(
      height: 108,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < weekly.length; i++)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    weekly[i] == 0 ? '' : '${weekly[i]}',
                    style: context.t.labelMuted.copyWith(fontSize: 11),
                  ),
                  const SizedBox(height: LFSpace.xs),
                  AnimatedContainer(
                    duration: LFMotion.progress,
                    curve: Curves.easeOutCubic,
                    height: (72 * (weekly[i] / goal).clamp(0.0, 1.0)).clamp(
                      4.0,
                      72.0,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: weekly[i] == 0
                          ? c.hairline
                          : (i == weekly.length - 1 ? c.ember : c.gold),
                      borderRadius: BorderRadius.circular(LFRadius.sm),
                    ),
                  ),
                  const SizedBox(height: LFSpace.sm),
                  Text(
                    labels[(todayIndex - (weekly.length - 1 - i)) % 7],
                    style: context.t.labelMuted.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final earned = achievement.earned;
    return SizedBox(
      width: 104,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: earned ? c.gold.withValues(alpha: 0.15) : c.surface,
              shape: BoxShape.circle,
              border: Border.all(color: earned ? c.gold : c.hairline, width: 2),
            ),
            child: Icon(
              achievement.icon,
              color: earned ? c.gold : c.inkMuted,
              size: 24,
            ),
          ),
          const SizedBox(height: LFSpace.sm),
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            style: context.t.label.copyWith(color: earned ? c.ink : c.inkMuted),
          ),
          const SizedBox(height: 2),
          Text(
            achievement.criterion,
            textAlign: TextAlign.center,
            style: context.t.labelMuted.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
