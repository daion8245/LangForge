import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/theme_extensions.dart';
import '../../application/project/project_session.dart';
import '../../infrastructure/platform/file_access.dart';
import 'mobile_shell.dart';
import 'widgets/mobile_controls.dart';

/// Entry point for the phone build — start screen, then the shell.
///
/// The desktop start screen (S0) carries three ways in: new, open a file, and
/// the recent list. A phone has no "open a file anywhere", so it carries two.
class MobileRoot extends ConsumerWidget {
  const MobileRoot({super.key, required this.appVersion});

  final String appVersion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(projectSessionProvider);
    if (session.isOpen) return MobileShell(appVersion: appVersion);
    return const _MobileStartView();
  }
}

class _MobileStartView extends ConsumerWidget {
  const _MobileStartView();

  /// A new project is given a file straight away.
  ///
  /// The desktop asks for a location on the first save (AC-10.8); a phone has
  /// nowhere to ask about, so the project lands in the app documents directory
  /// under its own name (MOBILE.md 1.1). Without a file, auto-save would have
  /// nothing to write to and a killed process would take the work with it.
  static Future<void> _newProject(WidgetRef ref) async {
    final notifier = ref.read(projectSessionProvider.notifier);
    await notifier.newProject();
    final path = await FileAccess.defaultProjectPath(
      ref.read(projectSessionProvider).name,
    );
    await notifier.saveAs(path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.c;
    final spacing = context.s;
    final recents = ref.watch(recentProjectsProvider).asData?.value ?? const [];
    final session = ref.watch(projectSessionProvider);

    return Scaffold(
      backgroundColor: colors.bgBase,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(spacing.space9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: spacing.space11),
              Row(
                children: [
                  Container(
                    width: context.m.appMark + 8,
                    height: context.m.appMark + 8,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.accent,
                      borderRadius: context.r.xl,
                    ),
                    child: Text(
                      'L',
                      style: context.t.codeBody.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.accentOn,
                      ),
                    ),
                  ),
                  SizedBox(width: spacing.space6),
                  Text(
                    'LangForge',
                    style: context.t.display.copyWith(
                      fontSize: 20,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.space5),
              Text(
                'Minecraft 모드 언어 파일을 번역하고 리소스팩으로 내보냅니다.',
                style: context.t.bodySm.copyWith(color: colors.textFaint),
              ),
              SizedBox(height: spacing.space11),
              _PrimaryButton(
                label: '새 프로젝트',
                onTap: () => unawaited(_newProject(ref)),
              ),
              SizedBox(height: spacing.space9),
              Text(
                '최근 프로젝트',
                style: context.t.micro.copyWith(
                  letterSpacing: 1.1,
                  color: colors.textFaint,
                ),
              ),
              SizedBox(height: spacing.space6),
              Expanded(
                child: recents.isEmpty
                    ? Text(
                        '아직 열어본 프로젝트가 없습니다.',
                        style: context.t.bodySm.copyWith(
                          color: colors.textDisabled,
                        ),
                      )
                    : ListView.separated(
                        itemCount: recents.length,
                        separatorBuilder: (_, _) =>
                            SizedBox(height: spacing.space4),
                        itemBuilder: (context, index) {
                          final recent = recents[index];
                          return _RecentRow(
                            name: recent.name,
                            path: recent.path,
                            missing: recent.hasMissingFiles,
                            onTap: () => unawaited(
                              ref
                                  .read(projectSessionProvider.notifier)
                                  .openProject(recent.path),
                            ),
                          );
                        },
                      ),
              ),
              if (session.errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(top: spacing.space6),
                  child: Text(
                    session.errorMessage!,
                    style: context.t.bodySm.copyWith(color: colors.dangerText),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: context.r.r3xl,
        child: Container(
          height: context.m.exportButton,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.accent,
            borderRadius: context.r.r3xl,
          ),
          child: Text(
            label,
            style: context.t.display.copyWith(
              fontSize: 14.5,
              color: colors.accentOn,
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({
    required this.name,
    required this.path,
    required this.missing,
    required this.onTap,
  });

  final String name;
  final String path;
  final bool missing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    return MobileTapTarget(
      onTap: onTap,
      borderRadius: context.r.r3xl,
      padding: EdgeInsets.symmetric(
        horizontal: context.s.space7,
        vertical: context.s.space6,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.t.body.copyWith(color: colors.textStrong),
                ),
                Text(
                  path,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.t.codeSm.copyWith(color: colors.textDisabled),
                ),
              ],
            ),
          ),
          if (missing)
            Text(
              '파일 누락',
              style: context.t.chip.copyWith(color: colors.warning),
            ),
        ],
      ),
    );
  }
}
