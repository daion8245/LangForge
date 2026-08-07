import 'package:flutter/material.dart';
import '../../app/theme/theme_extensions.dart';

class CloseConfirmationDialog extends StatelessWidget {
  const CloseConfirmationDialog({
    super.key,
    required this.isTranslating,
    this.onConfirmClose,
  });

  final bool isTranslating;

  /// Optional extra work on confirm. The dialog itself pops `true` so callers
  /// can simply await the result.
  final VoidCallback? onConfirmClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final radii = context.r;
    final spacing = context.s;
    final typography = context.t;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: context.d.modalSm),
        padding: EdgeInsets.all(spacing.space8),
        decoration: BoxDecoration(
          color: colors.bgSurface,
          borderRadius: radii.r3xl,
          border: Border.all(
            color: colors.borderPanel,
            width: context.d.borderThin,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTranslating ? '번역 진행 중 종료' : '프로젝트 닫기',
              style: typography.title.copyWith(color: colors.textPrimary),
            ),
            SizedBox(height: spacing.space4),
            Text(
              isTranslating
                  ? '현재 번역 작업이 진행 중입니다. 진행 완료된 내역은 저장된 후 안전하게 종료됩니다.'
                  : '현재 작업 중인 프로젝트를 닫고 시작 화면으로 이동하시겠습니까?',
              style: typography.bodySm.copyWith(color: colors.textSecondary),
            ),
            SizedBox(height: spacing.space8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('취소'),
                ),
                SizedBox(width: spacing.space4),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    onConfirmClose?.call();
                  },
                  child: const Text('종료'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
