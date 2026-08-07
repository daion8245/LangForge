import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../app/theme/theme_extensions.dart';
import '../../infrastructure/db/app_database.dart';
import '../common/lf_button.dart';

class SourceLangPickerView extends StatelessWidget {
  const SourceLangPickerView({
    super.key,
    required this.namespace,
    required this.availableLanguageFiles,
    required this.onSelectSourceFile,
    required this.onExcludeNamespace,
  });

  final Namespace namespace;
  final List<LanguageFile> availableLanguageFiles;
  final ValueChanged<LanguageFile> onSelectSourceFile;
  final VoidCallback onExcludeNamespace;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final radii = context.r;
    final spacing = context.s;
    final typography = context.t;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: context.d.modalMd),
        padding: EdgeInsets.all(spacing.space11),
        decoration: BoxDecoration(
          color: colors.bgSurface,
          borderRadius: radii.r4xl,
          border: Border.all(
            color: colors.borderPanel,
            width: context.d.borderThin,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.alertTriangle,
              size: context.d.iconXl,
              color: colors.warning,
            ),
            SizedBox(height: spacing.space6),
            Text(
              '기본 원본 언어 파일(en_us.json) 없음',
              style: typography.title.copyWith(color: colors.textPrimary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.space4),
            Text(
              'namespace "${namespace.name}"에 기본 원본 파일(en_us)이 없습니다.\n'
              '발견된 아래 언어 파일 중 번역 원본으로 사용할 파일을 선택하세요.',
              style: typography.bodySm.copyWith(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.space8),

            // Available Language Files List
            Container(
              decoration: BoxDecoration(
                color: colors.bgRaised,
                borderRadius: radii.r2xl,
                border: Border.all(
                  color: colors.borderControl,
                  width: context.d.borderThin,
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: availableLanguageFiles.length,
                separatorBuilder: (context, index) => Divider(
                  color: colors.borderSubtle,
                  height: context.d.borderThin,
                ),
                itemBuilder: (context, index) {
                  final langFile = availableLanguageFiles[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      langFile.entryPath,
                      style: typography.codeSm.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '${langFile.rawCode} (${langFile.keyCount}개 키)',
                      style: typography.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    trailing: Icon(
                      LucideIcons.arrowRight,
                      size: context.d.iconMd,
                      color: colors.accent,
                    ),
                    onTap: () => onSelectSourceFile(langFile),
                  );
                },
              ),
            ),

            SizedBox(height: spacing.space10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LfButton(
                  onPressed: onExcludeNamespace,
                  label: '이 namespace 제외',
                  icon: Icon(LucideIcons.eyeOff, size: context.d.iconMd),
                  style: LfButtonStyle.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
