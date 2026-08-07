import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_extensions.dart';
import '../../../application/mobile/mobile_project_providers.dart';
import '../../../application/mobile/mobile_ui_controller.dart';
import '../../../application/project/project_language_pair.dart';
import '../../../application/scan/scan_controller.dart';
import '../../../domain/policy/merge_policy.dart';
import '../../../domain/protection/multiset.dart';
import '../../../infrastructure/db/app_database.dart';
import '../../../infrastructure/db/row_mappers.dart';
import '../widgets/mobile_chips.dart';
import '../widgets/mobile_sheet.dart';

/// 편집 sheet — ROADMAP 13.3.
///
/// The one place on a phone where a translation is typed. It shows the source
/// text read-only above the field and the protected-token comparison below it,
/// because the multiset check is what decides whether the entry can be
/// exported and the user has to be able to see why it failed.
class MobileEditSheet extends ConsumerStatefulWidget {
  const MobileEditSheet({super.key, required this.entryId});

  final String entryId;

  @override
  ConsumerState<MobileEditSheet> createState() => _MobileEditSheetState();
}

class _MobileEditSheetState extends ConsumerState<MobileEditSheet> {
  final TextEditingController _controller = TextEditingController();

  /// The entry the controller currently holds text for. Reopening the sheet on
  /// a different entry has to replace the text; a rebuild on the same entry
  /// must not, or every keystroke would be undone.
  String? _loadedFor;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final spacing = context.s;
    final typography = context.t;

    final entry = ref.watch(entryByIdProvider(widget.entryId)).asData?.value;
    final langs =
        ref.watch(mobileLanguagePairProvider).asData?.value ??
        ProjectLanguagePair.defaults;

    if (entry == null) {
      return const MobileSheetSurface(child: SizedBox(height: 120));
    }

    if (_loadedFor != entry.id) {
      _loadedFor = entry.id;
      _controller.text = entry.userTranslation ?? entry.newTranslation ?? '';
    }

    final domain = entry.toDomain();
    final status = MergePolicy.resolveStatus(domain);
    final tokens = MultisetValidator.validate(
      domain.sourceText,
      _controller.text,
    );

    return MobileSheetSurface(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MobileSheetHandle(),
          SizedBox(height: spacing.space7),
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.key,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.codeSm.copyWith(
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              SizedBox(width: spacing.space5),
              MobileStatusChip(status: status),
            ],
          ),
          SizedBox(height: spacing.space7),
          _Label(langs.sourceLang, colors.textFaint),
          SizedBox(height: spacing.space3),
          Text(
            domain.sourceText.isEmpty ? '(빈 문자열)' : domain.sourceText,
            style: typography.codeBody.copyWith(
              fontSize: 13,
              color: colors.textTertiary,
            ),
          ),
          SizedBox(height: spacing.space7),
          _Label(langs.targetLang, colors.accent),
          SizedBox(height: spacing.space3),
          SizedBox(
            height: context.m.editorBox,
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              onChanged: (_) => setState(() {}),
              style: typography.body.copyWith(
                fontSize: 13.5,
                color: colors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '번역을 입력하세요',
                hintStyle: typography.body.copyWith(color: colors.textDisabled),
                filled: true,
                fillColor: colors.bgRaisedHover,
                contentPadding: EdgeInsets.all(spacing.space7 - 2),
                border: OutlineInputBorder(
                  borderRadius: context.r.r3xl,
                  borderSide: BorderSide(color: colors.borderDashed),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: context.r.r3xl,
                  borderSide: BorderSide(color: colors.borderDashed),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: context.r.r3xl,
                  borderSide: BorderSide(color: colors.accent),
                ),
              ),
            ),
          ),
          if (tokens.tokenChips.isNotEmpty) ...[
            SizedBox(height: spacing.space7),
            Text(
              '보호 변수 (개수 포함 비교)',
              style: typography.chip.copyWith(color: colors.textDisabled),
            ),
            SizedBox(height: spacing.space4),
            Wrap(
              spacing: spacing.space3,
              runSpacing: spacing.space3,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final info in tokens.tokenChips) MobileVarChip(info: info),
                Text(
                  _controller.text.isEmpty
                      ? '대기'
                      : (tokens.isMatch ? '멀티셋 일치' : '멀티셋 불일치'),
                  style: typography.micro.copyWith(
                    color: _controller.text.isEmpty
                        ? colors.textDisabled
                        : (tokens.isMatch ? colors.accent : colors.danger),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: spacing.space7),
          _Actions(entry: entry, text: _controller.text),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, this.color);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.t.codeSm.copyWith(fontSize: 10, color: color),
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions({required this.entry, required this.text});

  final Entry entry;
  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scan = ref.read(scanControllerProvider.notifier);
    final ui = ref.read(mobileUiControllerProvider.notifier);

    return Row(
      children: [
        Expanded(
          child: _SheetButton(
            label: '번역 대기로',
            // The phone has no way to run a single key through a provider, so
            // "retry" here means "put it back in the queue" — the next run
            // picks it up with everything else.
            onTap: () async {
              await scan.resetEntryToWait(entry.id);
              ui.showToast('번역 대기로 되돌렸습니다', '다음 번역 실행에서 다시 시도합니다.');
              ui.closeSheet();
            },
          ),
        ),
        SizedBox(width: context.s.space2 + 3),
        Expanded(
          child: _SheetButton(
            label: '원문 유지',
            onTap: () async {
              await scan.keepSourceText(entry.id);
              ui.closeSheet();
            },
          ),
        ),
        SizedBox(width: context.s.space2 + 3),
        Expanded(
          child: _SheetButton(
            label: '완료',
            primary: true,
            onTap: () async {
              await scan.updateUserTranslation(entry.id, text);
              ui.closeSheet();
            },
          ),
        ),
      ],
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: context.r.r3xl,
        child: Container(
          height: context.m.sheetActionButton,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: primary ? colors.accent : colors.bgSelected,
            borderRadius: context.r.r3xl,
            border: primary
                ? null
                : Border.all(
                    color: colors.borderDashed,
                    width: context.d.borderThin,
                  ),
          ),
          child: Text(
            label,
            style: context.t.body.copyWith(
              color: primary ? colors.accentOn : colors.textStrong,
              fontWeight: primary ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
