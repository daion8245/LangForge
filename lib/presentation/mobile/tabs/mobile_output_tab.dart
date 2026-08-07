import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_extensions.dart';
import '../../../application/mobile/mobile_export_service.dart';
import '../../../application/mobile/mobile_project_providers.dart';
import '../../../application/project/project_language_pair.dart';
import '../../../application/translation/translation_controller.dart';
import '../../../domain/model/entry_status.dart';
import '../../../domain/policy/export_gate.dart';
import '../../../infrastructure/db/app_database.dart';
import '../../../infrastructure/export/pack_meta_builder.dart';
import '../../../infrastructure/platform/file_access.dart';
import '../widgets/mobile_select.dart';

/// Loaded once — the version table is a shipped asset, not project data.
final _mcVersionsProvider = FutureProvider<String>((ref) {
  return rootBundle.loadString('assets/data/mc_versions.json');
});

/// 출력 tab — format, pack_format, a preview of the tree, the precheck, the
/// verdict, and the button.
///
/// The three formats that write several files are shown but disabled: a phone
/// gets a single `ACTION_CREATE_DOCUMENT` sink, not a directory (MOBILE.md
/// 1.1). Hiding them would leave a user wondering where the desktop options
/// went; disabling them with the reason answers that.
class MobileOutputTab extends ConsumerStatefulWidget {
  const MobileOutputTab({super.key, required this.onExport});

  final ValueChanged<String> onExport;

  @override
  ConsumerState<MobileOutputTab> createState() => _MobileOutputTabState();
}

class _MobileOutputTabState extends ConsumerState<MobileOutputTab> {
  String _mcVersion = '1.20.1';

  @override
  Widget build(BuildContext context) {
    final spacing = context.s;

    final counts = ref.watch(mobileProjectCountsProvider);
    final langs =
        ref.watch(mobileLanguagePairProvider).asData?.value ??
        ProjectLanguagePair.defaults;
    final namespaces =
        ref.watch(mobileNamespacesProvider).asData?.value ??
        const <Namespace>[];
    final versionsJson = ref.watch(_mcVersionsProvider).asData?.value;
    final isTranslating = ref.watch(translationControllerProvider).isActive;

    final versions = versionsJson == null
        ? <String>[_mcVersion]
        : PackMetaBuilder.parseVersions(
            versionsJson,
          ).map((v) => v.version).toList();
    // The picker only offers versions from the asset, but the default this
    // state starts on has to survive a version table that no longer lists it —
    // getPackFormat throws rather than guessing (TECHNICAL.md 8.4).
    final selectedVersion = versions.contains(_mcVersion)
        ? _mcVersion
        : (versions.isEmpty ? _mcVersion : versions.first);
    final packFormat = versionsJson == null
        ? 0
        : PackMetaBuilder.getPackFormat(versionsJson, selectedVersion);

    // The two policy switches keep their defaults here. The desktop modal lets
    // 출력 전 검사 건너뛰기 loosen them, but that override is deliberately not on
    // the phone: an export that ships known-bad keys should take the deliberate
    // path (E3).
    const options = ExportPolicyOptions();

    final summary = ExportSummary(
      totalKeys: counts.total,
      translatedKeys: counts.of(EntryStatus.done),
      keptKeys: counts.reused,
      pendingKeys: counts.pending,
      failedKeys: counts.failed,
    );

    final verdict = mobileExportVerdict(
      activeNamespaceCount: counts.selectedNamespaces,
      jsonErrorNamespaceCount: counts.jsonErrorNamespaces,
      summary: summary,
      isTranslating: isTranslating,
      hasUnresolvedConflict: counts.unresolvedConflicts > 0,
      options: options,
    );
    final blocked = verdict is Blocked;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        spacing.space8,
        spacing.space7,
        spacing.space8,
        spacing.space10 - 4,
      ),
      children: [
        MobileSelect<String>(
          label: '출력 형식',
          value: '통합 리소스팩 ZIP',
          items: const ['통합 리소스팩 ZIP'],
          onChanged: null,
          helper: FileAccess.supportsDirectoryExport
              ? null
              : '이 기기에서는 폴더를 지정할 수 없어 통합 ZIP 하나만 내보낼 수 있습니다. '
                    '나머지 형식은 데스크톱 앱에서 사용할 수 있습니다.',
        ),
        SizedBox(height: spacing.space8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: MobileSelect<String>(
                label: 'Minecraft 버전',
                value: selectedVersion,
                items: versions,
                onChanged: (next) => setState(() => _mcVersion = next),
              ),
            ),
            SizedBox(width: spacing.space5),
            MobileReadout(
              label: 'pack_format',
              value: '$packFormat',
              width: 96,
            ),
          ],
        ),
        SizedBox(height: spacing.space8),
        _SectionLabel('출력 구조'),
        SizedBox(height: spacing.space4 + 1),
        _OutputTree(
          namespaces: namespaces,
          outputFileName: langs.outputFileName,
          targetLangCode: langs.targetLang,
        ),
        SizedBox(height: spacing.space8),
        _SectionLabel('출력 전 검사'),
        SizedBox(height: spacing.space4 + 1),
        _Precheck(counts: counts),
        SizedBox(height: spacing.space8),
        _Verdict(verdict: verdict, counts: counts),
        SizedBox(height: spacing.space8),
        _ExportButton(
          blocked: blocked,
          onTap: blocked ? null : () => widget.onExport(selectedVersion),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.t.caption.copyWith(color: context.c.textTertiary),
    );
  }
}

/// The tree the export will write, drawn from the namespaces actually in scope.
class _OutputTree extends StatelessWidget {
  const _OutputTree({
    required this.namespaces,
    required this.outputFileName,
    required this.targetLangCode,
  });

  final List<Namespace> namespaces;
  final String outputFileName;
  final String targetLangCode;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final live =
        namespaces
            .where((ns) => !ns.excluded && ns.selected)
            .map((ns) => ns.name)
            .toSet()
            .toList()
          ..sort();

    final lines = <(String text, int indent, bool dim)>[
      if (live.isEmpty)
        ('선택된 namespace 가 없습니다', 0, true)
      else ...[
        (
          '${targetLangCode.split('_').first.toUpperCase()}_Translation_Pack.zip',
          0,
          true,
        ),
        ('├── pack.mcmeta', 1, false),
        ('├── pack.png', 1, false),
        ('└── assets/', 1, true),
        for (var i = 0; i < live.length; i++)
          (
            '${i == live.length - 1 ? '└── ' : '├── '}${live[i]}/lang/$outputFileName',
            2,
            false,
          ),
      ],
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.s.space8 - 1,
        vertical: context.s.space7,
      ),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: context.r.r3xl,
        border: Border.all(
          color: colors.bgSelected,
          width: context.d.borderThin,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (text, indent, dim) in lines)
              Padding(
                padding: EdgeInsets.only(left: indent * 16.0),
                child: Text(
                  text,
                  softWrap: false,
                  style: context.t.codeSm.copyWith(
                    fontSize: 11.5,
                    height: 1.95,
                    color: dim ? colors.textFaint : colors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Precheck extends StatelessWidget {
  const _Precheck({required this.counts});

  final MobileProjectCounts counts;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    final rows = <(String label, int value, bool ok, Color tint)>[
      ('번역 완료', counts.of(EntryStatus.done), true, colors.accent),
      ('기존 · 캐시 재사용', counts.reused, true, colors.info),
      (
        '원문 유지 · 확인 필요',
        counts.needsReview,
        counts.needsReview == 0,
        colors.warning,
      ),
      (
        '검증 실패',
        counts.failed,
        counts.failed == 0,
        counts.failed == 0 ? colors.accent : colors.danger,
      ),
      (
        '번역 대기',
        counts.pending,
        counts.pending == 0,
        counts.pending == 0 ? colors.accent : colors.warning,
      ),
      (
        'JSON 오류 namespace',
        counts.jsonErrorNamespaces,
        counts.jsonErrorNamespaces == 0,
        counts.jsonErrorNamespaces == 0 ? colors.accent : colors.danger,
      ),
      (
        '미해결 충돌',
        counts.unresolvedConflicts,
        counts.unresolvedConflicts == 0,
        counts.unresolvedConflicts == 0 ? colors.accent : colors.danger,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: context.r.r3xl,
        border: Border.all(
          color: colors.bgSelected,
          width: context.d.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (label, value, ok, tint) in rows)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.s.space7,
                vertical: context.s.space6,
              ),
              decoration: BoxDecoration(
                color: colors.bgSurface,
                border: Border(
                  bottom: BorderSide(
                    color: colors.borderDefault,
                    width: context.d.borderThin,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: context.m.precheckIcon,
                    height: context.m.precheckIcon,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ok ? colors.statusDoneBg : colors.statusFallbackBg,
                      borderRadius: context.r.sm,
                    ),
                    child: Text(
                      ok ? '✓' : '!',
                      style: context.t.micro.copyWith(
                        color: ok ? colors.accent : colors.warning,
                      ),
                    ),
                  ),
                  SizedBox(width: context.s.space6 - 1),
                  Expanded(
                    child: Text(
                      label,
                      style: context.t.bodySm.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    '$value',
                    style: context.t.codeBody.copyWith(color: tint),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Verdict extends StatelessWidget {
  const _Verdict({required this.verdict, required this.counts});

  final ExportVerdict verdict;
  final MobileProjectCounts counts;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final blocked = verdict is Blocked;

    final text = switch (verdict) {
      Blocked(:final reasons) => reasons.map(_reasonText).join(' '),
      Allowed(:final summary) =>
        '통합 리소스팩 ZIP 형식으로 namespace ${counts.selectedNamespaces}개, '
            '키 ${summary.totalKeys}개를 출력합니다.',
    };

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.s.space7,
        vertical: context.s.space7 - 1,
      ),
      decoration: BoxDecoration(
        color: blocked ? colors.dangerSurface : colors.successSurface,
        borderRadius: context.r.r3xl,
        border: Border.all(
          color: blocked ? colors.dangerBorder : colors.successBorder,
          width: context.d.borderThin,
        ),
      ),
      child: Text(
        text,
        style: context.t.label.copyWith(
          color: blocked ? colors.dangerText : colors.successText,
        ),
      ),
    );
  }

  static String _reasonText(BlockReason reason) => switch (reason) {
    BlockReason.jsonError => 'JSON 오류가 있는 namespace 가 남아 있습니다.',
    BlockReason.unresolvedConflict => '미해결 충돌이 남아 있습니다.',
    BlockReason.corruptTargetFile => '손상된 대상 언어 파일이 있습니다.',
    BlockReason.translationRunning => '번역이 진행 중입니다.',
    BlockReason.noNamespaceSelected => '선택된 namespace 가 없습니다.',
    BlockReason.validationFailed => '검증 실패 항목이 남아 있습니다.',
    BlockReason.pendingEntries => '번역 대기 항목이 남아 있습니다.',
  };
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({required this.blocked, required this.onTap});

  final bool blocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    return Semantics(
      button: true,
      enabled: !blocked,
      child: InkWell(
        onTap: onTap,
        borderRadius: context.r.r3xl,
        child: Container(
          height: context.m.exportButton,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: blocked ? colors.bgDisabled : colors.accent,
            borderRadius: context.r.r3xl,
          ),
          child: Text(
            blocked ? '내보내기 차단됨' : '내보내기',
            style: context.t.display.copyWith(
              fontSize: 14.5,
              color: blocked ? colors.textDisabled : colors.accentOn,
            ),
          ),
        ),
      ),
    );
  }
}
