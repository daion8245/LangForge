import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../models/course.dart';
import '../../state/app_state.dart';

/// Two pages: pick a course, pick a daily goal. Reversible, not skippable.
/// See `docs/screens.md`.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  Course? _course;
  DailyGoal _goal = DailyGoal.steady;
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _start() {
    final course = _course;
    if (course == null) return;
    AppScope.read(context).completeOnboarding(course: course, goal: _goal);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final state = AppScope.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              page: _page,
              onBack: _page == 0
                  ? null
                  : () {
                      _controller.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                      );
                    },
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _CoursePage(
                    courses: state.courses,
                    selected: _course,
                    onSelect: (course) => setState(() => _course = course),
                  ),
                  _GoalPage(
                    selected: _goal,
                    onSelect: (goal) => setState(() => _goal = goal),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(LFSpace.lg),
              child: _page == 0
                  ? LFButton(
                      label: 'Next',
                      onPressed: _course == null ? null : _next,
                    )
                  : LFButton(label: 'Start forging', onPressed: _start),
            ),
          ],
        ),
      ),
      backgroundColor: c.canvas,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.page, required this.onBack});

  final int page;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        LFSpace.sm,
        LFSpace.sm,
        LFSpace.lg,
        LFSpace.sm,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: onBack == null
                ? null
                : IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Back',
                  ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.hardware_outlined, size: 18, color: c.ember),
                const SizedBox(width: LFSpace.sm),
                Text(
                  'LangForge',
                  style: context.t.label.copyWith(letterSpacing: 1.2),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (var i = 0; i < 2; i++)
                  AnimatedContainer(
                    duration: LFMotion.tile,
                    margin: const EdgeInsets.only(left: 4),
                    width: i == page ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == page ? c.ember : c.hairline,
                      borderRadius: BorderRadius.circular(LFRadius.pill),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoursePage extends StatelessWidget {
  const _CoursePage({
    required this.courses,
    required this.selected,
    required this.onSelect,
  });

  final List<Course> courses;
  final Course? selected;
  final ValueChanged<Course> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(LFSpace.lg),
      children: [
        const SizedBox(height: LFSpace.lg),
        Text('What are you forging?', style: context.t.display),
        const SizedBox(height: LFSpace.sm),
        Text(
          'Pick a language. You can only forge one at a time — that is the point.',
          style: context.t.bodyMuted,
        ),
        const SizedBox(height: LFSpace.xl),
        for (final course in courses) ...[
          _CourseCard(
            course: course,
            selected: course.id == selected?.id,
            onTap: course.available ? () => onSelect(course) : null,
          ),
          const SizedBox(height: LFSpace.md),
        ],
      ],
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.course,
    required this.selected,
    required this.onTap,
  });

  final Course course;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final card = LFCard(
      onTap: onTap,
      fill: selected ? c.emberDim : c.surface,
      borderColor: selected ? c.ember : c.hairline,
      child: Row(
        children: [
          Text(course.flag, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: LFSpace.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(course.name, style: context.t.subtitle),
                    const SizedBox(width: LFSpace.sm),
                    Text(course.nativeName, style: context.t.labelMuted),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  course.available
                      ? '${course.wordCount} words · ${course.units.length} units'
                      : '${course.wordCount} words',
                  style: context.t.labelMuted,
                ),
              ],
            ),
          ),
          if (!course.available)
            const LFPill(label: 'Coming soon')
          else if (selected)
            Icon(Icons.check_circle, color: c.ember)
          else
            Icon(Icons.circle_outlined, color: c.hairline),
        ],
      ),
    );

    if (course.available) return card;
    return Opacity(opacity: 0.4, child: IgnorePointer(child: card));
  }
}

class _GoalPage extends StatelessWidget {
  const _GoalPage({required this.selected, required this.onSelect});

  final DailyGoal selected;
  final ValueChanged<DailyGoal> onSelect;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ListView(
      padding: const EdgeInsets.all(LFSpace.lg),
      children: [
        const SizedBox(height: LFSpace.lg),
        Text('How much per day?', style: context.t.display),
        const SizedBox(height: LFSpace.sm),
        Text(
          'Pick something you would still do on a bad day. You can change it later.',
          style: context.t.bodyMuted,
        ),
        const SizedBox(height: LFSpace.xl),
        for (final goal in DailyGoal.values) ...[
          LFCard(
            onTap: () => onSelect(goal),
            fill: goal == selected ? c.emberDim : c.surface,
            borderColor: goal == selected ? c.ember : c.hairline,
            child: Row(
              children: [
                Icon(
                  goal == selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: goal == selected ? c.ember : c.hairline,
                ),
                const SizedBox(width: LFSpace.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.label, style: context.t.subtitle),
                      const SizedBox(height: 2),
                      Text(goal.description, style: context.t.labelMuted),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: LFSpace.md),
        ],
      ],
    );
  }
}
