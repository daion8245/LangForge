import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_extensions.dart';
import '../../../application/conflict/conflict_providers.dart';
import '../../../application/entries/entries_page_controller.dart';
import '../../../application/mobile/mobile_project_providers.dart';
import '../../../application/mobile/mobile_ui_controller.dart';
import '../../../application/scan/scan_controller.dart';
import '../../../domain/model/entry_status.dart' as model;
import '../../../domain/protection/multiset.dart';
import '../../../infrastructure/db/app_database.dart';
import '../../../infrastructure/db/row_mappers.dart';

/// One row of the 문제 tab.
class _Issue {
  const _Issue({
    required this.tag,
    required this.tagColor,
    required this.where,
    required this.description,
    required this.onTap,
  });

  final String tag;
  final Color tagColor;
  final String where;
  final String description;

  /// Null when the phone cannot fix this one — the row still has to be listed,
  /// it just says where the fix lives.
  final VoidCallback? onTap;
}

/// 문제 tab — everything standing between the project and an export.
///
/// The three counters at the top are project-wide, not namespace-wide: the
/// export gate is project-wide, so a per-namespace count would let a user clear
/// the screen and still be blocked.
class MobileIssuesTab extends ConsumerWidget {
  const MobileIssuesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = context.s;
    final colors = context.c;
    final counts = ref.watch(mobileProjectCountsProvider);
    final issues = _collect(context, ref);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        spacing.space8,
        spacing.space7,
        spacing.space8,
        spacing.space10 - 4,
      ),
      children: [
        _Stat(label: '검증 실패', value: counts.failed),
        SizedBox(height: spacing.space6),
        _Stat(label: '확인 필요 · 원문 유지', value: counts.needsReview),
        SizedBox(height: spacing.space6),
        _Stat(label: '번역 대기', value: counts.pending),
        SizedBox(height: spacing.space9),
        Text(
          '해결이 필요한 항목',
          style: context.t.micro.copyWith(
            letterSpacing: 1.1,
            color: colors.textFaint,
          ),
        ),
        SizedBox(height: spacing.space6),
        if (issues.isEmpty)
          const _NoIssues()
        else
          for (final issue in issues) ...[
            _IssueCard(issue: issue),
            SizedBox(height: spacing.space6),
          ],
        if (counts.failed > mobileIssueListLimit)
          Padding(
            padding: EdgeInsets.only(top: spacing.space5),
            child: Text(
              '검증 실패 ${counts.failed}건 중 $mobileIssueListLimit건만 표시했습니다. '
              '해결하면 나머지가 이어서 나타납니다.',
              style: context.t.micro.copyWith(color: colors.textFaint),
            ),
          ),
      ],
    );
  }

  List<_Issue> _collect(BuildContext context, WidgetRef ref) {
    final colors = context.c;
    final ui = ref.read(mobileUiControllerProvider.notifier);
    final scan = ref.read(scanControllerProvider.notifier);
    final entriesView = ref.read(entriesViewControllerProvider.notifier);

    final namespaces =
        ref.watch(mobileNamespacesProvider).asData?.value ??
        const <Namespace>[];
    final failed =
        ref.watch(mobileFailedEntriesProvider).asData?.value ?? const <Entry>[];
    final unresolved =
        ref.watch(unresolvedConflictCountProvider).asData?.value ?? 0;

    final nsById = {for (final ns in namespaces) ns.id: ns};
    final issues = <_Issue>[];

    for (final ns in namespaces) {
      if (ns.excluded || !ns.selected) continue;

      if (ns.state == model.NamespaceState.jsonError.wireName) {
        issues.add(
          _Issue(
            tag: 'JSON 오류',
            tagColor: colors.danger,
            where: 'assets/${ns.name}/lang/',
            description:
                'line ${ns.errorLine ?? '?'} · ${ns.errorMessage ?? 'JSON 문법 오류'}. '
                '이 namespace 는 대기열과 출력에서 제외됩니다.',
            // Nothing to tap: the fix is in the mod's own file, not in the app.
            onTap: null,
          ),
        );
      } else if (ns.state == model.NamespaceState.noSource.wireName) {
        issues.add(
          _Issue(
            tag: '원본 없음',
            tagColor: colors.warning,
            where: 'assets/${ns.name}/lang/',
            description: '원본 언어 파일을 찾지 못했습니다. 대체 원본을 지정하거나 제외하세요.',
            onTap: () => ui.openSourceSheet(ns.id),
          ),
        );
      }
    }

    if (unresolved > 0) {
      issues.add(
        _Issue(
          tag: '충돌 미해결',
          tagColor: colors.danger,
          where: '$unresolved건',
          description:
              '같은 키를 서로 다르게 번역한 파일이 있습니다. 자동 덮어쓰기를 하지 않으므로 출력이 차단됩니다. '
              '충돌 해결은 데스크톱 앱에서 할 수 있습니다.',
          onTap: null,
        ),
      );
    }

    for (final row in failed) {
      final ns = nsById[row.namespaceId];
      if (ns == null || ns.excluded || !ns.selected) continue;
      final domain = row.toDomain();
      final target = domain.userTranslation ?? domain.newTranslation ?? '';
      issues.add(
        _Issue(
          tag: '검증 실패',
          tagColor: colors.danger,
          where: '${ns.name} · ${row.key}',
          description: _tokenSummary(domain.sourceText, target),
          onTap: () {
            scan.setActiveNamespace(row.namespaceId);
            entriesView.selectNamespace(row.namespaceId);
            ui.goToEntry(tab: MobileTab.edit, entryId: row.id);
          },
        ),
      );
    }

    return issues;
  }

  /// Says which tokens disagree, with counts. `없음` when a side has none —
  /// "0 tokens" and "no tokens" read the same but only one is the failure.
  static String _tokenSummary(String source, String target) {
    String render(Map<String, int> bag) {
      if (bag.isEmpty) return '없음';
      final keys = bag.keys.toList()..sort();
      return keys.map((k) => '$k×${bag[k]}').join(' ');
    }

    final a = MultisetValidator.bagOf(source);
    final b = MultisetValidator.bagOf(target);
    return '원문 ${render(a)} / 번역 ${render(b)}';
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final spacing = context.s;
    final clean = value == 0;
    final tint = clean ? colors.accent : colors.warning;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.space7,
        vertical: spacing.space7 - 2,
      ),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: context.r.r3xl,
        border: Border.all(
          color: colors.bgSelected,
          width: context.d.borderThin,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: context.m.statIcon,
            height: context.m.statIcon,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: clean ? colors.statusDoneBg : colors.statusFallbackBg,
              borderRadius: context.r.md,
            ),
            child: Text(
              clean ? '✓' : '!',
              style: context.t.label.copyWith(color: tint),
            ),
          ),
          SizedBox(width: spacing.space6),
          Expanded(
            child: Text(
              label,
              style: context.t.body.copyWith(color: colors.textSecondary),
            ),
          ),
          Text(
            '$value',
            style: context.t.codeBody.copyWith(fontSize: 15, color: tint),
          ),
        ],
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  const _IssueCard({required this.issue});

  final _Issue issue;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final spacing = context.s;

    return InkWell(
      onTap: issue.onTap,
      borderRadius: context.r.r3xl,
      child: Container(
        constraints: BoxConstraints(minHeight: context.m.minTapTarget),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.space7,
          vertical: spacing.space7 - 1,
        ),
        decoration: BoxDecoration(
          color: colors.bgSurface,
          borderRadius: context.r.r3xl,
          border: Border.all(
            color: colors.dangerBorder,
            width: context.d.borderThin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 19,
                  padding: EdgeInsets.symmetric(horizontal: spacing.space8 / 2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.statusInvalidBg,
                    borderRadius: context.r.md,
                  ),
                  child: Text(
                    issue.tag,
                    style: context.t.chip.copyWith(color: issue.tagColor),
                  ),
                ),
                SizedBox(width: spacing.space5),
                Expanded(
                  child: Text(
                    issue.where,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.t.codeSm.copyWith(
                      fontSize: 11.5,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.space4),
            Text(
              issue.description,
              style: context.t.bodySm.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoIssues extends StatelessWidget {
  const _NoIssues();

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    return DottedBorderBox(
      child: Text(
        '해결이 필요한 항목이 없습니다.\n출력 탭에서 결과물을 내보낼 수 있습니다.',
        textAlign: TextAlign.center,
        style: context.t.bodySm.copyWith(color: colors.textFaint),
      ),
    );
  }
}

/// The mockup's `border: 1px dashed #2F2F2F` empty state.
///
/// Flutter has no dashed border, and a custom painter for one line of copy is
/// not worth the surface — a solid border in the dashed token reads the same at
/// this size.
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.s.space8,
        vertical: context.s.space11 - 2,
      ),
      decoration: BoxDecoration(
        borderRadius: context.r.r3xl,
        border: Border.all(
          color: context.c.borderPanel,
          width: context.d.borderThin,
        ),
      ),
      child: child,
    );
  }
}
