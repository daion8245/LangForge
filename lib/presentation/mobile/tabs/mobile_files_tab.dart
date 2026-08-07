import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_extensions.dart';
import '../../../application/entries/entries_page_controller.dart';
import '../../../application/mobile/mobile_project_providers.dart';
import '../../../application/mobile/mobile_ui_controller.dart';
import '../../../application/scan/scan_controller.dart';
import '../../../application/translation/translation_controller.dart';
// scan_controller.dart declares its own ScanState (the UI one), which shadows
// the persisted enum of the same name. The prefix keeps the wire values typed.
import '../../../domain/model/entry_status.dart' as model;
import '../../../infrastructure/db/app_database.dart';
import '../widgets/mobile_controls.dart';

/// 파일 tab — the phone's stand-in for the desktop 탐색기 panel.
///
/// Two levels, like the desktop tree: input file → namespace, with the language
/// files folded away until asked for. The third desktop level (individual keys)
/// belongs to the 편집 tab here; a 390px column cannot carry four levels.
class MobileFilesTab extends ConsumerStatefulWidget {
  const MobileFilesTab({super.key, required this.onAddFiles});

  final VoidCallback onAddFiles;

  @override
  ConsumerState<MobileFilesTab> createState() => _MobileFilesTabState();
}

class _MobileFilesTabState extends ConsumerState<MobileFilesTab> {
  /// Which namespaces have their language files unfolded. UI-only, so it lives
  /// here rather than in a controller.
  final Set<String> _expanded = <String>{};

  @override
  Widget build(BuildContext context) {
    final spacing = context.s;
    final colors = context.c;

    final files =
        ref.watch(mobileInputFilesProvider).asData?.value ??
        const <InputFile>[];
    final namespaces =
        ref.watch(mobileNamespacesProvider).asData?.value ??
        const <Namespace>[];
    final languageFiles =
        ref.watch(mobileLanguageFilesProvider).asData?.value ??
        const <LanguageFile>[];
    final locked = ref.watch(translationControllerProvider).isActive;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        spacing.space8,
        spacing.space7,
        spacing.space8,
        spacing.space10 - 4,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '입력 파일 ${files.length}개',
                style: context.t.micro.copyWith(
                  letterSpacing: 1.1,
                  color: colors.textFaint,
                ),
              ),
            ),
            _AddButton(onTap: locked ? null : widget.onAddFiles),
          ],
        ),
        SizedBox(height: spacing.space7 - 2),
        for (final file in files) ...[
          _FileCard(
            file: file,
            namespaces: namespaces
                .where((ns) => ns.inputFileId == file.id)
                .toList(),
            languageFiles: languageFiles,
            expanded: _expanded,
            locked: locked,
            onToggleExpanded: (nsId) => setState(() {
              if (!_expanded.remove(nsId)) _expanded.add(nsId);
            }),
          ),
          SizedBox(height: spacing.space7 - 2),
        ],
        if (files.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: spacing.space10),
            child: Text(
              '추가된 파일이 없습니다.\n오른쪽 위 추가를 눌러 JAR 또는 ZIP 을 선택하세요.',
              textAlign: TextAlign.center,
              style: context.t.bodySm.copyWith(color: colors.textFaint),
            ),
          ),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    return MobileTapTarget(
      onTap: onTap,
      semanticLabel: '입력 파일 추가',
      borderRadius: context.r.xl,
      child: Container(
        height: context.d.buttonSecondary,
        padding: EdgeInsets.symmetric(horizontal: context.s.space7 - 2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: onTap == null ? colors.bgDisabled : colors.bgRaised,
          borderRadius: context.r.xl,
          border: Border.all(
            color: colors.borderControl,
            width: context.d.borderThin,
          ),
        ),
        child: Text(
          '추가',
          style: context.t.label.copyWith(
            color: onTap == null ? colors.textDisabled : colors.textStrong,
          ),
        ),
      ),
    );
  }
}

class _FileCard extends ConsumerWidget {
  const _FileCard({
    required this.file,
    required this.namespaces,
    required this.languageFiles,
    required this.expanded,
    required this.locked,
    required this.onToggleExpanded,
  });

  final InputFile file;
  final List<Namespace> namespaces;
  final List<LanguageFile> languageFiles;
  final Set<String> expanded;
  final bool locked;
  final ValueChanged<String> onToggleExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.c;
    final spacing = context.s;
    final scan = ref.read(scanControllerProvider.notifier);
    final rejected = file.scanState == model.ScanState.rejected.wireName;

    return Container(
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: context.r.r3xl,
        border: Border.all(
          color: colors.bgSelected,
          width: context.d.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.space7,
              vertical: spacing.space3,
            ),
            child: Row(
              children: [
                MobileCheckbox(
                  value: file.enabled,
                  enabled: !locked && !rejected,
                  semanticLabel: '${file.originalName} 포함',
                  onChanged: locked || rejected
                      ? null
                      : (value) => scan.setInputFileEnabled(file.id, value),
                ),
                SizedBox(width: spacing.space6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.originalName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.t.codeBody.copyWith(
                          color: file.enabled
                              ? colors.textStrong
                              : colors.textDisabled,
                        ),
                      ),
                      SizedBox(height: spacing.space1),
                      Text(
                        rejected
                            ? (file.rejectReason ?? '거부됨')
                            : '${_formatSize(file.sizeBytes)} · namespace ${namespaces.length}개',
                        maxLines: 2,
                        style: context.t.chip.copyWith(
                          color: rejected ? colors.danger : colors.textDisabled,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          for (final ns in namespaces)
            _NamespaceRow(
              namespace: ns,
              languageFiles: languageFiles
                  .where((lf) => lf.namespaceId == ns.id)
                  .toList(),
              expanded: expanded.contains(ns.id),
              locked: locked,
              onToggleExpanded: () => onToggleExpanded(ns.id),
            ),
        ],
      ),
    );
  }

  static String _formatSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) return '${(bytes / 1024).round()} KB';
    return '$bytes B';
  }
}

class _NamespaceRow extends ConsumerWidget {
  const _NamespaceRow({
    required this.namespace,
    required this.languageFiles,
    required this.expanded,
    required this.locked,
    required this.onToggleExpanded,
  });

  final Namespace namespace;
  final List<LanguageFile> languageFiles;
  final bool expanded;
  final bool locked;
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.c;
    final spacing = context.s;
    final scan = ref.read(scanControllerProvider.notifier);
    final ui = ref.read(mobileUiControllerProvider.notifier);
    final active = ref.watch(scanControllerProvider).activeNamespaceId;

    final state = namespace.state;
    final broken = state == model.NamespaceState.jsonError.wireName;
    final noSource = state == model.NamespaceState.noSource.wireName;
    final included = !namespace.excluded;

    final (meta, metaColor) = switch (state) {
      _ when broken => ('JSON 오류', colors.danger),
      _ when noSource => ('원본 없음', colors.warning),
      _ => ('${namespace.keyCount}', colors.textDisabled),
    };

    final dot = switch (state) {
      _ when broken => colors.danger,
      _ when noSource => colors.warning,
      _ when !included => colors.textFaint,
      _ => colors.accent,
    };

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: active == namespace.id
                ? colors.bgSelected
                : Colors.transparent,
            border: Border(
              top: BorderSide(
                color: colors.borderSubtle,
                width: context.d.borderThin,
              ),
            ),
          ),
          padding: EdgeInsets.only(left: spacing.space7),
          child: Row(
            children: [
              MobileCheckbox(
                value: included,
                enabled: !locked && !broken,
                semanticLabel: 'namespace ${namespace.name} 포함',
                onChanged: locked || broken
                    ? null
                    : (value) =>
                          scan.setNamespaceExcluded(namespace.id, !value),
              ),
              SizedBox(width: spacing.space5),
              Container(
                width: context.d.statusDot,
                height: context.d.statusDot,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              SizedBox(width: spacing.space5),
              Expanded(
                child: InkWell(
                  onTap: () {
                    scan.setActiveNamespace(namespace.id);
                    ref
                        .read(entriesViewControllerProvider.notifier)
                        .selectNamespace(namespace.id);
                    ui.selectTab(MobileTab.edit);
                  },
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: context.m.minTapTarget,
                    ),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            namespace.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.t.body.copyWith(
                              fontFamily: context.t.codeBody.fontFamily,
                              color: included
                                  ? colors.textSecondary
                                  : colors.textDisabled,
                            ),
                          ),
                        ),
                        SizedBox(width: spacing.space5),
                        Text(
                          meta,
                          style: context.t.codeSm.copyWith(color: metaColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              MobileTapTarget(
                onTap: onToggleExpanded,
                semanticLabel: expanded
                    ? '${namespace.name} 파일 목록 접기'
                    : '${namespace.name} 파일 목록 펼치기',
                child: Icon(
                  expanded ? Icons.expand_more : Icons.chevron_right,
                  size: context.d.iconSm,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
        ),
        if (expanded)
          Padding(
            padding: EdgeInsets.fromLTRB(
              spacing.space12 + 2,
              spacing.space1,
              spacing.space7,
              spacing.space7 - 2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final lf in languageFiles)
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing.space2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${lf.code}.json',
                          style: context.t.codeSm.copyWith(
                            fontSize: 11.5,
                            color: switch (lf.role) {
                              'source' => colors.accent,
                              _ when broken => colors.danger,
                              _ => colors.textSecondary,
                            },
                          ),
                        ),
                        SizedBox(width: spacing.space5),
                        Expanded(
                          child: Text(
                            _roleLabel(lf),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.t.chip.copyWith(
                              color: colors.textDisabled,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (broken && namespace.errorMessage != null)
                  Text(
                    'line ${namespace.errorLine ?? '?'} · ${namespace.errorMessage}',
                    style: context.t.chip.copyWith(color: colors.danger),
                  ),
                if (noSource)
                  Padding(
                    padding: EdgeInsets.only(top: spacing.space2),
                    child: _FixSourceButton(
                      onTap: () => ui.openSourceSheet(namespace.id),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  static String _roleLabel(LanguageFile lf) => switch (lf.role) {
    'source' => '원본 · ${lf.keyCount} 키',
    'existing_target' => '기존 번역 ${lf.keyCount} 키',
    _ => '${lf.keyCount} 키',
  };
}

class _FixSourceButton extends StatelessWidget {
  const _FixSourceButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    return MobileTapTarget(
      onTap: onTap,
      semanticLabel: '원본 언어 지정',
      borderRadius: context.r.lg,
      child: Container(
        height: context.d.buttonSecondary - 2,
        padding: EdgeInsets.symmetric(horizontal: context.s.space2 * 2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.statusFallbackBg,
          borderRadius: context.r.lg,
          border: Border.all(
            color: colors.warning.withValues(alpha: 0.35),
            width: context.d.borderThin,
          ),
        ),
        child: Text(
          '원본 언어 지정',
          style: context.t.micro.copyWith(color: colors.warning),
        ),
      ),
    );
  }
}
