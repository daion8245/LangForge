import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/theme_extensions.dart';
import '../../application/conflict/conflict_providers.dart';
import '../../application/scan/scan_controller.dart';
import '../common/lf_button.dart';

/// S11 — 충돌 해결. AC-8.6.
///
/// Every conflict is decided by the user here and nowhere else. The priority
/// setting can highlight a candidate (shown as 제안), but nothing is recorded
/// until 확인 is pressed, and unresolved conflicts keep blocking export.
class ConflictModalView extends ConsumerStatefulWidget {
  const ConflictModalView({super.key});

  @override
  ConsumerState<ConflictModalView> createState() => _ConflictModalViewState();
}

class _ConflictModalViewState extends ConsumerState<ConflictModalView> {
  /// conflict id -> entry id the radio group is on. Seeded from the stored
  /// resolution or the suggestion, then owned by the user's clicks.
  final Map<String, String> _selection = {};

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final radii = context.r;
    final spacing = context.s;
    final conflicts = ref.watch(conflictListProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(spacing.space8),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: context.d.modalLg,
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        decoration: BoxDecoration(
          color: colors.bgSurface,
          borderRadius: radii.r4xl,
          border: Border.all(
            color: colors.borderPanel,
            width: context.d.borderThin,
          ),
        ),
        padding: EdgeInsets.all(spacing.space8),
        child: switch (conflicts) {
          AsyncError(:final error) => _Message('충돌을 읽지 못했습니다: $error'),
          AsyncData(:final value) => _body(value),
          _ => const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          ),
        },
      ),
    );
  }

  Widget _body(List<ConflictView> conflicts) {
    final spacing = context.s;
    final colors = context.c;
    final unresolved = conflicts.where((c) => !c.resolved).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text('충돌 해결', style: context.t.title),
            SizedBox(width: spacing.space5),
            Text(
              conflicts.isEmpty
                  ? '충돌 없음'
                  : '미해결 $unresolved / 전체 ${conflicts.length}',
              style: context.t.caption.copyWith(
                color: unresolved > 0 ? colors.warning : colors.textMuted,
              ),
            ),
            const Spacer(),
            LfButton(
              onPressed: () => Navigator.of(context).maybePop(),
              label: '닫기',
              style: LfButtonStyle.tertiary,
            ),
          ],
        ),
        SizedBox(height: spacing.space5),
        Text(
          '같은 namespace 의 같은 키를 두 파일이 다른 원문으로 가지고 있습니다. '
          '어느 쪽을 출력할지 골라 주세요. 고르지 않은 충돌이 하나라도 남으면 출력은 차단됩니다.',
          style: context.t.caption.copyWith(color: colors.textMuted),
        ),
        SizedBox(height: spacing.space7),
        Flexible(
          child: conflicts.isEmpty
              ? const _Message('해결할 충돌이 없습니다.')
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: conflicts.length,
                  separatorBuilder: (_, _) =>
                      Divider(color: colors.borderPanel),
                  itemBuilder: (context, index) =>
                      _conflictTile(conflicts[index]),
                ),
        ),
      ],
    );
  }

  Widget _conflictTile(ConflictView conflict) {
    final spacing = context.s;
    final colors = context.c;
    final selected = _selection[conflict.id] ?? conflict.initialSelection;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.space6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${conflict.namespaceName} · ${conflict.key}',
                  style: context.t.codeBody,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (conflict.resolved)
                Text(
                  '해결됨',
                  style: context.t.caption.copyWith(color: colors.successText),
                ),
            ],
          ),
          SizedBox(height: spacing.space5),
          RadioGroup<String>(
            groupValue: selected,
            onChanged: (entryId) {
              if (entryId == null) return;
              setState(() => _selection[conflict.id] = entryId);
            },
            child: Column(
              children: [
                for (final candidate in conflict.candidates)
                  _CandidateRow(
                    candidate: candidate,
                    isSuggested: conflict.suggestedEntryId == candidate.entryId,
                    onSelected: () => setState(
                      () => _selection[conflict.id] = candidate.entryId,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: spacing.space5),
          Row(
            children: [
              LfButton(
                onPressed: selected == null
                    ? null
                    : () => unawaited(_confirm(conflict.id, selected)),
                label: conflict.resolved ? '선택 변경' : '확인',
                style: LfButtonStyle.primary,
              ),
              if (conflict.resolved) ...[
                SizedBox(width: spacing.space5),
                LfButton(
                  onPressed: () => unawaited(_undo(conflict.id)),
                  label: '해결 취소',
                  style: LfButtonStyle.tertiary,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirm(String conflictId, String entryId) async {
    await ref
        .read(scanControllerProvider.notifier)
        .resolveConflict(conflictId: conflictId, entryId: entryId);
  }

  Future<void> _undo(String conflictId) async {
    await ref
        .read(scanControllerProvider.notifier)
        .unresolveConflict(conflictId);
  }
}

class _CandidateRow extends StatelessWidget {
  const _CandidateRow({
    required this.candidate,
    required this.isSuggested,
    required this.onSelected,
  });

  final ConflictCandidate candidate;
  final bool isSuggested;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final spacing = context.s;
    final colors = context.c;

    return InkWell(
      onTap: onSelected,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.space3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<String>(value: candidate.entryId, activeColor: colors.accent),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          candidate.inputFileName,
                          style: context.t.body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSuggested) ...[
                        SizedBox(width: spacing.space3),
                        Text(
                          '제안',
                          style: context.t.caption.copyWith(
                            color: colors.accent,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: spacing.space2),
                  Text(
                    '원문  ${candidate.sourceText}',
                    style: context.t.codeBody,
                  ),
                  Text(
                    '번역  ${candidate.translation}',
                    style: context.t.codeBody.copyWith(color: colors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(context.s.space8),
    child: Text(
      text,
      style: context.t.body.copyWith(color: context.c.textMuted),
    ),
  );
}
