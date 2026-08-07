import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/theme_extensions.dart';
import '../../application/mobile/mobile_export_service.dart';
import '../../application/mobile/mobile_project_providers.dart';
import '../../application/mobile/mobile_ui_controller.dart';
import '../../application/project/project_language_pair.dart';
import '../../application/project/project_session.dart';
import '../../application/scan/scan_controller.dart';
import '../../application/settings/engine_settings.dart';
import '../../application/translation/translation_controller.dart';
import '../../infrastructure/db/app_database.dart';
import '../../infrastructure/platform/file_access.dart';
import 'sheets/mobile_edit_sheet.dart';
import 'sheets/mobile_settings_sheet.dart';
import 'sheets/mobile_source_sheet.dart';
import 'tabs/mobile_edit_tab.dart';
import 'tabs/mobile_files_tab.dart';
import 'tabs/mobile_issues_tab.dart';
import 'tabs/mobile_output_tab.dart';
import 'widgets/mobile_bottom_tabs.dart';
import 'widgets/mobile_header.dart';
import 'widgets/mobile_sheet.dart';
import 'widgets/mobile_toast.dart';

/// The whole phone UI — DESIGN.md 6.3.
///
/// Header, progress hairline, the active tab, the run bar, the bottom tabs, and
/// above all of it the sheets and the toast. Nothing here is a route: the
/// sheets are drawn in this stack so the tab bar keeps its place and the scrim
/// covers exactly the app.
class MobileShell extends ConsumerStatefulWidget {
  const MobileShell({super.key, required this.appVersion});

  final String appVersion;

  @override
  ConsumerState<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends ConsumerState<MobileShell>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Android can kill a backgrounded process at any moment (MOBILE.md 1.3).
  ///
  /// Phase 13 decided against a Foreground Service, so the run is paused and
  /// checkpointed on the way out instead. What finished is already in the
  /// database; what did not is still `wait`, so a killed process costs the
  /// queue position and nothing else.
  ///
  /// Coming back does **not** auto-resume: these are paid API calls, and
  /// restarting them without the user asking is worse than making them tap.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.paused) return;
    final translation = ref.read(translationControllerProvider);
    if (translation.isRunning) {
      ref.read(translationControllerProvider.notifier).pause();
    }
    unawaited(
      ref.read(projectSessionProvider.notifier).saveTranslationCheckpoint(),
    );
  }

  MobileUiController get _ui => ref.read(mobileUiControllerProvider.notifier);

  Future<void> _addFiles() async {
    if (ref.read(translationControllerProvider).isActive) return;

    final selection = await FileAccess.pickInputFiles();
    if (selection.isEmpty) return;

    if (selection.rejected.isNotEmpty) {
      _ui.showToast(
        '${selection.rejected.length}개 파일을 가져오지 못했습니다',
        selection.rejected.first,
        isError: true,
      );
    }
    if (selection.paths.isEmpty) return;

    try {
      await ref.read(scanControllerProvider.notifier).addFiles(selection.paths);
    } catch (error) {
      _ui.showToast(
        '파일을 추가하지 못했습니다',
        FileAccess.describeStorageError(error),
        isError: true,
      );
      return;
    } finally {
      // The picker copied every chosen file into the app cache; the scan has
      // what it needs now, so the copies go (MOBILE.md 1.4).
      await FileAccess.releaseImportCache();
    }
  }

  void _startTranslation() {
    final translation = ref.read(translationControllerProvider);
    if (translation.isActive) return;

    final settings = ref.read(engineSettingsProvider);
    if (settings.missingFieldLabels.isNotEmpty) {
      ref.read(engineSettingsProvider.notifier).reportMissingFields();
      _ui.showToast(
        '${settings.provider.displayName} 인증 정보 필요',
        '${settings.missingFieldLabels.join(' · ')} 을(를) 설정에서 입력하세요.',
        isError: true,
      );
      _ui.openSettingsSheet();
      return;
    }

    unawaited(
      ref
          .read(translationControllerProvider.notifier)
          .start(
            provider: settings.provider,
            auth: settings.authValues,
            model: settings.model,
          ),
    );
  }

  Future<void> _export(String mcVersion) async {
    final outcome = await ref
        .read(mobileExportServiceProvider)
        .exportZipPack(mcVersion: mcVersion, appVersion: widget.appVersion);

    switch (outcome) {
      case MobileExportSaved(:final path):
        _ui.showToast('내보내기 완료', path);
      case MobileExportCancelled():
        break;
      case MobileExportFailed(:final message):
        _ui.showToast('내보내기 실패', message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ui = ref.watch(mobileUiControllerProvider);
    final counts = ref.watch(mobileProjectCountsProvider);
    final session = ref.watch(projectSessionProvider);
    final translation = ref.watch(translationControllerProvider);
    final scan = ref.watch(scanControllerProvider);
    final langs =
        ref.watch(mobileLanguagePairProvider).asData?.value ??
        ProjectLanguagePair.defaults;
    final namespaces =
        ref.watch(mobileNamespacesProvider).asData?.value ??
        const <Namespace>[];

    final active = namespaces
        .where((ns) => ns.id == scan.activeNamespaceId)
        .firstOrNull;

    return Scaffold(
      backgroundColor: context.c.bgBase,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                MobileHeader(
                  title: _title(ui.tab, counts, active, session.name),
                  subtitle: _subtitle(
                    ui.tab,
                    counts,
                    active,
                    langs,
                    translation,
                  ),
                  onOpenSettings: _ui.openSettingsSheet,
                ),
                MobileProgressBar(percent: counts.percent),
                Expanded(child: _tabBody(ui.tab)),
                if (ui.tab == MobileTab.edit)
                  _RunBar(
                    onStart: _startTranslation,
                    pendingCount: counts.pending,
                  ),
                MobileBottomTabs(
                  current: ui.tab,
                  issueCount: counts.issueCount,
                  onSelect: _ui.selectTab,
                ),
              ],
            ),
            if (ui.sheet != null) MobileSheetScrim(onTap: _ui.closeSheet),
            if (ui.sheet == MobileSheet.edit && ui.editEntryId != null)
              MobileEditSheet(entryId: ui.editEntryId!),
            if (ui.sheet == MobileSheet.source && ui.sourceNamespaceId != null)
              MobileSourceSheet(namespaceId: ui.sourceNamespaceId!),
            if (ui.sheet == MobileSheet.settings) const MobileSettingsSheet(),
            if (ui.toast != null)
              MobileToastView(toast: ui.toast!, onDismiss: _ui.dismissToast),
          ],
        ),
      ),
    );
  }

  Widget _tabBody(MobileTab tab) => switch (tab) {
    MobileTab.files => MobileFilesTab(onAddFiles: () => unawaited(_addFiles())),
    MobileTab.edit => const MobileEditTab(),
    MobileTab.issues => const MobileIssuesTab(),
    MobileTab.output => MobileOutputTab(
      onExport: (version) => unawaited(_export(version)),
    ),
  };

  static String _title(
    MobileTab tab,
    MobileProjectCounts counts,
    Namespace? active,
    String projectName,
  ) => switch (tab) {
    MobileTab.files => projectName,
    MobileTab.edit => active?.name ?? '편집',
    MobileTab.issues => '문제 ${counts.issueCount}건',
    MobileTab.output => '출력',
  };

  static String _subtitle(
    MobileTab tab,
    MobileProjectCounts counts,
    Namespace? active,
    ProjectLanguagePair langs,
    TranslationUiState translation,
  ) {
    if (tab == MobileTab.edit && active != null) {
      final source = active.sourceOverride ?? langs.sourceLang;
      return 'assets/${active.name}/lang/$source.json → ${langs.outputFileName}';
    }
    if (translation.isRunning) return '번역 중 ${counts.percentInt}%';
    if (translation.isPaused) return '일시정지 ${counts.percentInt}%';
    return 'namespace ${counts.selectedNamespaces} · 키 ${counts.total} · ${counts.percentInt}%';
  }
}

/// The run bar of the mockup: one primary button, plus pause while a run holds
/// the queue.
class _RunBar extends ConsumerWidget {
  const _RunBar({required this.onStart, required this.pendingCount});

  final VoidCallback onStart;
  final int pendingCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.c;
    final spacing = context.s;
    final sizes = context.m;
    final translation = ref.watch(translationControllerProvider);
    final notifier = ref.read(translationControllerProvider.notifier);

    final running = translation.isRunning;
    final paused = translation.isPaused;
    final active = running || paused;

    final (label, background, foreground, enabled) = switch (true) {
      _ when paused => (
        '일시정지됨',
        colors.loadingSurface,
        colors.loadingText,
        false,
      ),
      _ when running => (
        '번역 진행 중… ${((translation.percent ?? 0) * 100).round()}%',
        colors.loadingSurface,
        colors.loadingText,
        false,
      ),
      _ when pendingCount > 0 => (
        '번역 시작 ($pendingCount건 대기)',
        colors.accent,
        colors.accentOn,
        true,
      ),
      _ => ('대기 항목 없음', colors.bgDisabled, colors.textFaint, false),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.space8,
        vertical: spacing.space2 * 2,
      ),
      decoration: BoxDecoration(
        color: colors.bgBar,
        border: Border(
          top: BorderSide(
            color: colors.borderDefault,
            width: context.d.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              button: true,
              enabled: enabled,
              child: InkWell(
                onTap: enabled ? onStart : null,
                borderRadius: context.r.r3xl,
                child: Container(
                  height: sizes.runButton,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: context.r.r3xl,
                  ),
                  child: Text(
                    label,
                    style: context.t.heading.copyWith(color: foreground),
                  ),
                ),
              ),
            ),
          ),
          if (active) ...[
            SizedBox(width: spacing.space2 + 3),
            SizedBox(
              width: sizes.pauseButton,
              child: InkWell(
                onTap: paused ? notifier.resume : notifier.pause,
                borderRadius: context.r.r3xl,
                child: Container(
                  height: sizes.runButton,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.bgSelected,
                    borderRadius: context.r.r3xl,
                    border: Border.all(
                      color: colors.borderDashed,
                      width: context.d.borderThin,
                    ),
                  ),
                  child: Text(
                    paused ? '재개' : '일시정지',
                    style: context.t.body.copyWith(color: colors.textStrong),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
