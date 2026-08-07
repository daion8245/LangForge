import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_extensions.dart';
import '../../../application/mobile/mobile_project_providers.dart';
import '../../../application/mobile/mobile_ui_controller.dart';
import '../../../application/project/project_language_pair.dart';
import '../../../application/scan/scan_controller.dart';
import '../../../infrastructure/db/app_database.dart';
import '../widgets/mobile_controls.dart';
import '../widgets/mobile_sheet.dart';

/// 원본 지정 sheet — ROADMAP 13.3.
///
/// Opened when a namespace has no file in the project's source language. The
/// app never picks one on its own: which of `en_gb.json` or `de_de.json` is
/// "the original" is a judgement about the mod, not something a filename
/// settles (AC-4.4).
class MobileSourceSheet extends ConsumerWidget {
  const MobileSourceSheet({super.key, required this.namespaceId});

  final String namespaceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.c;
    final spacing = context.s;

    final namespaces =
        ref.watch(mobileNamespacesProvider).asData?.value ??
        const <Namespace>[];
    final namespace = namespaces
        .where((ns) => ns.id == namespaceId)
        .firstOrNull;
    final files =
        (ref.watch(mobileLanguageFilesProvider).asData?.value ??
                const <LanguageFile>[])
            .where((lf) => lf.namespaceId == namespaceId)
            .toList();
    final langs =
        ref.watch(mobileLanguagePairProvider).asData?.value ??
        ProjectLanguagePair.defaults;

    if (namespace == null) {
      return const MobileSheetSurface(child: SizedBox(height: 120));
    }

    final scan = ref.read(scanControllerProvider.notifier);
    final ui = ref.read(mobileUiControllerProvider.notifier);
    final current = namespace.sourceOverride;

    return MobileSheetSurface(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MobileSheetHandle(),
          SizedBox(height: spacing.space7),
          Text(
            '${langs.sourceLang}.json 없음 — ${namespace.name}',
            style: context.t.title.copyWith(color: context.c.textPrimary),
          ),
          SizedBox(height: spacing.space3),
          Text(
            '기본 원본 언어 파일이 없습니다. 발견된 파일 중 하나를 원본으로 지정하거나 이 namespace 를 제외하세요.',
            style: context.t.label.copyWith(color: colors.textMuted),
          ),
          SizedBox(height: spacing.space7),
          for (final file in files) ...[
            MobileOptionRow(
              label: '${file.code}.json 을(를) 원본으로',
              hint: '${file.keyCount} 키',
              selected: current == file.id,
              onTap: () async {
                await scan.setNamespaceSource(namespaceId, file.id);
                ui.closeSheet();
              },
            ),
            SizedBox(height: spacing.space4 + 1),
          ],
          MobileOptionRow(
            label: '이 namespace 제외',
            hint: '출력 제외',
            selected: namespace.excluded,
            onTap: () async {
              await scan.setNamespaceExcluded(namespaceId, true);
              ui.showToast(
                '${namespace.name} 을(를) 제외했습니다',
                '대기열과 출력에서 빠집니다. 파일 탭에서 다시 켤 수 있습니다.',
              );
              ui.closeSheet();
            },
          ),
          if (files.isEmpty) ...[
            SizedBox(height: spacing.space7),
            Text(
              '이 namespace 에는 언어 파일이 하나도 없습니다. 제외하는 것 외에 선택할 수 있는 원본이 없습니다.',
              style: context.t.micro.copyWith(color: colors.textFaint),
            ),
          ],
        ],
      ),
    );
  }
}
