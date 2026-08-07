import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../app/theme/theme_extensions.dart';
import '../../infrastructure/db/app_database.dart';

class JsonErrorView extends StatelessWidget {
  const JsonErrorView({super.key, required this.namespace});

  final Namespace namespace;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final radii = context.r;
    final spacing = context.s;
    final typography = context.t;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        padding: EdgeInsets.all(spacing.space11),
        decoration: BoxDecoration(
          color: colors.dangerSurface,
          borderRadius: radii.r4xl,
          border: Border.all(color: colors.dangerBorder, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.alertTriangle, size: 28, color: colors.danger),
                SizedBox(width: spacing.space5),
                Text(
                  'JSON 파싱 오류 격리됨',
                  style: typography.title.copyWith(color: colors.dangerText),
                ),
              ],
            ),
            SizedBox(height: spacing.space6),
            Text(
              'namespace "${namespace.name}"의 JSON 언어 파일 구조가 올바르지 않아 작업에서 자동 제외되었습니다.\n'
              '이 오류는 다른 namespace 번역 작업에 영향을 주지 않습니다.',
              style: typography.bodySm.copyWith(color: colors.textPrimary),
            ),
            SizedBox(height: spacing.space8),

            // Error Detail Panel
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(spacing.space7),
              decoration: BoxDecoration(
                color: colors.bgSurface,
                borderRadius: radii.r2xl,
                border: Border.all(color: colors.dangerBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오류 상세 내용',
                    style: typography.overline.copyWith(
                      color: colors.textFaint,
                    ),
                  ),
                  SizedBox(height: spacing.space4),
                  Text(
                    namespace.errorMessage ?? '알 수 없는 JSON 구조 오류가 발생했습니다.',
                    style: typography.codeSm.copyWith(color: colors.dangerText),
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
