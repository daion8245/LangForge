import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_extensions.dart';
import '../../../application/entries/entries_page_controller.dart';
import '../../../application/mobile/mobile_project_providers.dart';
import '../../../application/mobile/mobile_ui_controller.dart';
import '../../../application/project/project_language_pair.dart';
import '../../../application/scan/scan_controller.dart';
import '../../../domain/model/entry_status.dart' as model;
import '../../../domain/policy/merge_policy.dart';
import '../../../domain/protection/multiset.dart';
import '../../../infrastructure/db/app_database.dart';
import '../../../infrastructure/db/row_mappers.dart';
import '../widgets/mobile_chips.dart';

/// 편집 tab — one namespace's entries, three lines per row.
///
/// The desktop editor puts source and target side by side; 390px cannot, so
/// they stack with a fixed language-code gutter. The gutter is what keeps the
/// two lines readable as a pair rather than as two paragraphs.
class MobileEditTab extends ConsumerWidget {
  const MobileEditTab({super.key});

  /// The four filter chips of the mockup, in order.
  static const List<(String label, String? filter)> filters = [
    ('전체', null),
    ('대기', 'wait'),
    ('재사용', reuseStatusFilter),
    ('문제', problemStatusFilter),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = context.s;

    final namespaces =
        ref.watch(mobileNamespacesProvider).asData?.value ??
        const <Namespace>[];
    final activeId = ref.watch(scanControllerProvider).activeNamespaceId;
    final view = ref.watch(entriesViewControllerProvider);
    final langs =
        ref.watch(mobileLanguagePairProvider).asData?.value ??
        ProjectLanguagePair.defaults;

    // Namespaces the user turned off stay out of the chip row, except the one
    // being looked at — otherwise switching a namespace off would yank the
    // list out from under the user.
    final chips = namespaces
        .where((ns) => (!ns.excluded && ns.selected) || ns.id == activeId)
        .toList();
    final active = chips.where((ns) => ns.id == activeId).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ChipRow(
          height: context.m.chipHeight,
          padding: EdgeInsets.fromLTRB(
            spacing.space8,
            spacing.space7 - 2,
            spacing.space8,
            spacing.space2 * 2,
          ),
          children: [
            for (final ns in chips)
              MobileNamespaceChip(
                label: ns.name,
                selected: ns.id == activeId,
                onTap: () {
                  ref
                      .read(scanControllerProvider.notifier)
                      .setActiveNamespace(ns.id);
                  ref
                      .read(entriesViewControllerProvider.notifier)
                      .selectNamespace(ns.id);
                },
              ),
          ],
        ),
        _ChipRow(
          height: context.m.filterHeight,
          padding: EdgeInsets.fromLTRB(
            spacing.space8,
            0,
            spacing.space8,
            spacing.space7 - 2,
          ),
          children: [
            for (final (label, filter) in filters)
              MobileFilterChip(
                label: label,
                selected: view.statusFilter == filter,
                onTap: () => ref
                    .read(entriesViewControllerProvider.notifier)
                    .setStatusFilter(filter),
              ),
          ],
        ),
        Expanded(
          child: active == null
              ? const _NoNamespace()
              : _Body(namespace: active, langs: langs),
        ),
      ],
    );
  }
}

/// Horizontally scrolling chip strip. Both rows in the mockup behave this way.
class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.children,
    required this.height,
    required this.padding,
  });

  final List<Widget> children;
  final double height;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: height + padding.vertical,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: children.length,
        separatorBuilder: (_, _) => SizedBox(width: context.s.space4),
        itemBuilder: (_, index) => children[index],
      ),
    );
  }
}

class _NoNamespace extends StatelessWidget {
  const _NoNamespace();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.s.space10),
        child: Text(
          '선택된 namespace 가 없습니다.\n파일 탭에서 하나를 고르세요.',
          textAlign: TextAlign.center,
          style: context.t.bodySm.copyWith(color: context.c.textFaint),
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.namespace, required this.langs});

  final Namespace namespace;
  final ProjectLanguagePair langs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final broken = namespace.state == model.NamespaceState.jsonError.wireName;
    final noSource = namespace.state == model.NamespaceState.noSource.wireName;

    if (broken || noSource) {
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          context.s.space8,
          context.s.space3,
          context.s.space8,
          context.s.space10,
        ),
        child: _BlockedPanel(namespace: namespace, broken: broken),
      );
    }

    final entries =
        ref.watch(entriesPageProvider).asData?.value ?? const <Entry>[];
    final total = ref.watch(entriesTotalCountProvider).asData?.value ?? 0;
    final hasMore = entries.length < total;
    final sourceCode = namespace.sourceOverride ?? langs.sourceLang;

    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(context.s.space10),
          child: Text(
            '이 조건에 해당하는 항목이 없습니다.',
            style: context.t.bodySm.copyWith(color: context.c.textFaint),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: context.s.space8),
      itemCount: entries.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == entries.length) {
          return _LoadMore(
            loaded: entries.length,
            total: total,
            onTap: ref.read(entriesViewControllerProvider.notifier).loadMore,
          );
        }
        return _EntryRow(
          entry: entries[index],
          sourceCode: sourceCode,
          targetCode: langs.targetLang,
        );
      },
    );
  }
}

class _EntryRow extends ConsumerWidget {
  const _EntryRow({
    required this.entry,
    required this.sourceCode,
    required this.targetCode,
  });

  final Entry entry;
  final String sourceCode;
  final String targetCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.c;
    final spacing = context.s;
    final typography = context.t;

    final domain = entry.toDomain();
    final status = MergePolicy.resolveStatus(domain);
    final target = domain.userTranslation ?? domain.newTranslation ?? '';
    final tokens = MultisetValidator.validate(domain.sourceText, target);

    final targetText = switch (status) {
      model.EntryStatus.running => '번역 생성 중…',
      model.EntryStatus.empty when target.isEmpty => '빈 문자열 유지',
      _ when target.isEmpty => '번역 대기',
      _ => target,
    };
    final targetColor = switch (status) {
      model.EntryStatus.running => colors.textFaint,
      _ when target.isEmpty => colors.textDisabled,
      _ => colors.textPrimary,
    };

    return InkWell(
      onTap: () =>
          ref.read(mobileUiControllerProvider.notifier).openEditSheet(entry.id),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.space8,
          vertical: spacing.space7,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colors.borderSubtle,
              width: context.d.borderThin,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.key,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.codeSm.copyWith(color: colors.textMuted),
                  ),
                ),
                SizedBox(width: spacing.space5),
                MobileStatusChip(status: status),
              ],
            ),
            SizedBox(height: spacing.space4),
            _Line(
              code: sourceCode,
              codeColor: colors.textFaint,
              text: domain.sourceText.isEmpty ? '(빈 문자열)' : domain.sourceText,
              textColor: colors.textTertiary,
            ),
            SizedBox(height: spacing.space5),
            _Line(
              code: targetCode,
              codeColor: colors.accent,
              text: targetText,
              textColor: targetColor,
            ),
            if (tokens.tokenChips.isNotEmpty) ...[
              SizedBox(height: spacing.space5),
              Padding(
                padding: EdgeInsets.only(
                  left: context.m.langCodeColumn + spacing.space5,
                ),
                child: Wrap(
                  spacing: spacing.space2,
                  runSpacing: spacing.space2,
                  children: [
                    for (final info in tokens.tokenChips)
                      MobileVarChip(info: info),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One `code | text` line of an entry row.
class _Line extends StatelessWidget {
  const _Line({
    required this.code,
    required this.codeColor,
    required this.text,
    required this.textColor,
  });

  final String code;
  final Color codeColor;
  final String text;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: context.m.langCodeColumn,
          child: Padding(
            padding: EdgeInsets.only(top: context.s.space1),
            child: Text(
              code,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: context.t.codeSm.copyWith(fontSize: 9.5, color: codeColor),
            ),
          ),
        ),
        SizedBox(width: context.s.space5),
        Expanded(
          child: Text(text, style: context.t.bodySm.copyWith(color: textColor)),
        ),
      ],
    );
  }
}

class _LoadMore extends StatelessWidget {
  const _LoadMore({
    required this.loaded,
    required this.total,
    required this.onTap,
  });

  final int loaded;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.s.space8),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          minimumSize: Size.fromHeight(context.m.minTapTarget),
          side: BorderSide(color: context.c.borderControl),
          shape: RoundedRectangleBorder(borderRadius: context.r.r3xl),
        ),
        child: Text(
          '더 보기 ($loaded / $total)',
          style: context.t.label.copyWith(color: context.c.textStrong),
        ),
      ),
    );
  }
}

/// Replaces the list when the namespace cannot be worked on at all.
///
/// The wording says what happens to the rest of the project, because the whole
/// point of isolating a broken namespace is that everything else still ships
/// (AC-3.3 · AC-4.4).
class _BlockedPanel extends ConsumerWidget {
  const _BlockedPanel({required this.namespace, required this.broken});

  final Namespace namespace;
  final bool broken;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.c;
    final spacing = context.s;
    final ui = ref.read(mobileUiControllerProvider.notifier);

    final title = broken ? 'JSON 사전 검사 실패' : '원본 언어 파일을 찾지 못했습니다';
    final body = broken
        ? 'line ${namespace.errorLine ?? '?'} · ${namespace.errorMessage ?? 'JSON 문법 오류'} — '
              '이 namespace 는 대기열과 출력에서 제외됩니다. 다른 namespace 작업은 계속 진행됩니다.'
        : '이 namespace 에는 기본 원본 언어 파일이 없습니다. 발견된 다른 언어 파일을 원본으로 지정하거나 작업에서 제외하세요.';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.space8,
        vertical: spacing.space9,
      ),
      decoration: BoxDecoration(
        color: colors.dangerSurface,
        borderRadius: context.r.r3xl,
        border: Border.all(
          color: colors.dangerBorder,
          width: context.d.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.t.heading.copyWith(color: colors.dangerText),
          ),
          SizedBox(height: spacing.space6),
          Text(body, style: context.t.label.copyWith(color: colors.dangerText)),
          if (!broken) ...[
            SizedBox(height: spacing.space6),
            OutlinedButton(
              onPressed: () => ui.openSourceSheet(namespace.id),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(0, context.m.minTapTarget),
                side: BorderSide(color: colors.dangerBorder),
                shape: RoundedRectangleBorder(borderRadius: context.r.xl),
              ),
              child: Text(
                '원본 언어 지정',
                style: context.t.bodySm.copyWith(color: colors.dangerText),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
