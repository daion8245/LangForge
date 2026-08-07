import 'dart:async';

import 'package:flutter/material.dart';
import '../../../app/theme/theme_extensions.dart';
import '../../../application/entries/entries_page_controller.dart';
import '../../../domain/model/entry_status.dart';
import '../../../domain/policy/merge_policy.dart';
import '../../../domain/protection/multiset.dart';
import '../../../infrastructure/db/app_database.dart';
import '../../../infrastructure/db/row_mappers.dart';
import '../../common/lf_button.dart';
import '../../common/lf_status_chip.dart';

class EntriesListView extends StatefulWidget {
  const EntriesListView({
    super.key,
    required this.entries,
    this.totalCount = 0,
    this.statusCounts = const {},
    this.statusFilter,
    this.hasMore = false,
    this.onLoadMore,
    this.onStatusFilterChanged,
    this.sourceLang = 'en_us',
    this.targetLang = 'ko_kr',
    this.onUpdateUserTranslation,
    this.onResetEntryToWait,
    this.onKeepSourceText,
    this.onApproveConfirm,
    this.isTranslating = false,
  });

  /// The loaded page, not the whole table.
  final List<Entry> entries;

  /// Row count for the active filter, counted in SQL.
  final int totalCount;

  /// `status -> count`, counted in SQL.
  final Map<String, int> statusCounts;

  final String? statusFilter;
  final bool hasMore;
  final VoidCallback? onLoadMore;
  final ValueChanged<String?>? onStatusFilterChanged;

  final String sourceLang;
  final String targetLang;

  final void Function(String entryId, String newText)? onUpdateUserTranslation;
  final void Function(String entryId)? onResetEntryToWait;
  final void Function(String entryId)? onKeepSourceText;
  final void Function(String entryId)? onApproveConfirm;

  /// While a run is in flight the translation column is read-only
  /// (EXPERIENCE.md 6.4).
  final bool isTranslating;

  @override
  State<EntriesListView> createState() => _EntriesListViewState();
}

class _EntriesListViewState extends State<EntriesListView> {
  final ScrollController _scrollController = ScrollController();

  /// Typing writes through to the database so the status flips to 확인 필요 as
  /// the user types (AC-7.1), but not on literally every keystroke.
  Timer? _editDebounce;
  static const Duration _editDebounceDelay = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _editDebounce?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _submitEdit(String entryId, String value) {
    _editDebounce?.cancel();
    widget.onUpdateUserTranslation?.call(entryId, value);
  }

  void _queueEdit(String entryId, String value) {
    _editDebounce?.cancel();
    _editDebounce = Timer(_editDebounceDelay, () {
      widget.onUpdateUserTranslation?.call(entryId, value);
    });
  }

  /// Pull the next page in before the user reaches the bottom, so scrolling
  /// through tens of thousands of rows never stalls on an empty viewport.
  void _onScroll() {
    if (!widget.hasMore) return;
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      widget.onLoadMore?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final spacing = context.s;
    final typography = context.t;
    final radii = context.r;

    final filtered = widget.entries;

    // Tab walks the visible rows before leaving the editor (TECHNICAL.md 15).
    return FocusTraversalGroup(
      child: Column(
        children: [
          // Status Filter Bar
          Container(
            height: context.d.filterBar,
            padding: EdgeInsets.symmetric(horizontal: spacing.space7),
            decoration: BoxDecoration(
              color: colors.bgSurface,
              border: Border(
                bottom: BorderSide(
                  color: colors.borderDefault,
                  width: context.d.borderThin,
                ),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterTab(context, 'all', '전체 (${_countFor('all')})'),
                  SizedBox(width: spacing.space4),
                  _buildFilterTab(context, 'wait', '대기 (${_countFor('wait')})'),
                  SizedBox(width: spacing.space4),
                  _buildFilterTab(
                    context,
                    'kept',
                    '기존유지 (${_countFor('kept')})',
                  ),
                  SizedBox(width: spacing.space4),
                  _buildFilterTab(
                    context,
                    'invalid',
                    '검증실패 (${_countFor('invalid')})',
                  ),
                  SizedBox(width: spacing.space4),
                  _buildFilterTab(context, 'done', '완료 (${_countFor('done')})'),
                  SizedBox(width: spacing.space4),
                  _buildFilterTab(
                    context,
                    problemStatusFilter,
                    '문제 (${_countFor(problemStatusFilter)})',
                  ),
                ],
              ),
            ),
          ),

          // Virtualized Entries List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      '표시할 항목이 없습니다.',
                      style: typography.bodySm.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: filtered.length + (widget.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= filtered.length) {
                        return Padding(
                          padding: EdgeInsets.all(spacing.space7),
                          child: Center(
                            child: Text(
                              '항목을 더 불러오는 중…',
                              style: typography.caption.copyWith(
                                color: colors.textMuted,
                              ),
                            ),
                          ),
                        );
                      }
                      final entry = filtered[index];
                      final domainEntry = entry.toDomain();
                      final statusType = _mapStatusType(
                        MergePolicy.resolveStatus(domainEntry),
                      );
                      final targetText = MergePolicy.resolveFinal(domainEntry);

                      final multisetResult = MultisetValidator.validate(
                        entry.sourceText,
                        targetText,
                      );

                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: colors.borderSubtle,
                              width: context.d.borderThin,
                            ),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.space8,
                          vertical: spacing.space6,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Main Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Key
                                  Text(
                                    entry.key,
                                    style: typography.codeBody.copyWith(
                                      color: colors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: spacing.space3),

                                  // Source Text
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: context.d.langLabel,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          '[${widget.sourceLang}]',
                                          style: typography.codeSm.copyWith(
                                            color: colors.textMuted,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: spacing.space3),
                                      Expanded(
                                        child: Text(
                                          entry.sourceText,
                                          style: typography.body.copyWith(
                                            color: colors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: spacing.space2),

                                  // Target Translation (Editable)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: context.d.langLabel,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          '[${widget.targetLang}]',
                                          style: typography.codeSm.copyWith(
                                            color: colors.accent,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: spacing.space3),
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: targetText,
                                          key: Key(entry.id),
                                          style: typography.body.copyWith(
                                            color: colors.textPrimary,
                                          ),
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: spacing.space8,
                                                  vertical: spacing.space3,
                                                ),
                                            hintText: '번역문을 입력하세요...',
                                            hintStyle: typography.body.copyWith(
                                              color: colors.textMuted,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: radii.xs,
                                              borderSide: BorderSide(
                                                color: colors.borderControl,
                                                width: context.d.borderThin,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: radii.xs,
                                              borderSide: BorderSide(
                                                color: colors.accent,
                                                width: context.d.borderThick,
                                              ),
                                            ),
                                          ),
                                          enabled: !widget.isTranslating,
                                          onChanged: (val) =>
                                              _queueEdit(entry.id, val),
                                          onFieldSubmitted: (val) =>
                                              _submitEdit(entry.id, val),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Token Chips
                                  if (multisetResult.tokenChips.isNotEmpty) ...[
                                    SizedBox(height: spacing.space4),
                                    Wrap(
                                      spacing: spacing.space3,
                                      runSpacing: spacing.space2,
                                      children: multisetResult.tokenChips.map((
                                        chip,
                                      ) {
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: spacing.space3,
                                            vertical: spacing.space1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: chip.isMatch
                                                ? colors.bgRaised
                                                : colors.dangerSurface,
                                            borderRadius: radii.xs,
                                            border: Border.all(
                                              color: chip.isMatch
                                                  ? colors.borderControl
                                                  : colors.dangerBorder,
                                              width: context.d.borderThin,
                                            ),
                                          ),
                                          child: Text(
                                            '${chip.token} (s:${chip.sourceCount}/t:${chip.targetCount})',
                                            style: typography.codeSm.copyWith(
                                              color: chip.isMatch
                                                  ? colors.textSecondary
                                                  : colors.dangerText,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            SizedBox(width: spacing.space8),

                            // Status, Validation Badges & Action Buttons
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                LfStatusChip(type: statusType),
                                if (targetText.isNotEmpty) ...[
                                  SizedBox(height: spacing.space3),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: spacing.space3,
                                      vertical: spacing.space1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: multisetResult.isMatch
                                          ? colors.successSurface
                                          : colors.dangerSurface,
                                      borderRadius: radii.xs,
                                    ),
                                    child: Text(
                                      multisetResult.isMatch
                                          ? '멀티셋 일치'
                                          : '멀티셋 불일치',
                                      style: typography.caption.copyWith(
                                        color: multisetResult.isMatch
                                            ? colors.successText
                                            : colors.dangerText,
                                      ),
                                    ),
                                  ),
                                ],
                                if (entry.status == 'invalid') ...[
                                  SizedBox(height: spacing.space4),
                                  Row(
                                    children: [
                                      LfButton(
                                        onPressed: widget.isTranslating
                                            ? null
                                            : () => widget.onResetEntryToWait
                                                  ?.call(entry.id),
                                        label: '다시 시도',
                                        tooltip: widget.isTranslating
                                            ? '번역이 진행 중입니다'
                                            : null,
                                        style: LfButtonStyle.secondary,
                                      ),
                                      SizedBox(width: spacing.space2),
                                      LfButton(
                                        onPressed: widget.isTranslating
                                            ? null
                                            : () => widget.onKeepSourceText
                                                  ?.call(entry.id),
                                        label: '원문 유지',
                                        tooltip: widget.isTranslating
                                            ? '번역이 진행 중입니다'
                                            : null,
                                        style: LfButtonStyle.secondary,
                                      ),
                                    ],
                                  ),
                                ],
                                if (entry.status == 'confirm' ||
                                    (entry.userEdited &&
                                        entry.userTranslation != null)) ...[
                                  SizedBox(height: spacing.space4),
                                  LfButton(
                                    onPressed: widget.isTranslating
                                        ? null
                                        : () => widget.onApproveConfirm?.call(
                                            entry.id,
                                          ),
                                    label: '승인',
                                    tooltip: widget.isTranslating
                                        ? '번역이 진행 중입니다'
                                        : '확인 필요를 승인하고 검수 캐시에 저장',
                                    style: LfButtonStyle.secondary,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Counts come from SQL, so they stay correct even though only one page of
  /// rows is loaded.
  int _countFor(String filterKey) {
    if (filterKey == 'all') {
      return widget.statusCounts.values.fold(0, (sum, n) => sum + n);
    }
    if (filterKey == problemStatusFilter) {
      return problemStatuses.fold(
        0,
        (sum, status) => sum + (widget.statusCounts[status] ?? 0),
      );
    }
    return widget.statusCounts[filterKey] ?? 0;
  }

  Widget _buildFilterTab(BuildContext context, String filterKey, String label) {
    final colors = context.c;
    final isSelected = (widget.statusFilter ?? 'all') == filterKey;

    return InkWell(
      onTap: () => widget.onStatusFilterChanged?.call(
        filterKey == 'all' ? null : filterKey,
      ),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: context.s.space8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? colors.accent : Colors.transparent,
              width: context.d.borderThick,
            ),
          ),
        ),
        child: Text(
          label,
          style: context.t.caption.copyWith(
            color: isSelected ? colors.textPrimary : colors.textMuted,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  LfStatusType _mapStatusType(EntryStatus status) {
    return switch (status) {
      EntryStatus.wait => LfStatusType.wait,
      EntryStatus.running => LfStatusType.running,
      EntryStatus.done => LfStatusType.done,
      EntryStatus.kept => LfStatusType.kept,
      EntryStatus.cache => LfStatusType.cache,
      EntryStatus.invalid => LfStatusType.invalid,
      EntryStatus.fallback => LfStatusType.fallback,
      EntryStatus.confirm => LfStatusType.confirm,
      EntryStatus.empty => LfStatusType.empty,
    };
  }
}
