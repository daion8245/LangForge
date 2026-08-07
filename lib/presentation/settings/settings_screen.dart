import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/theme_extensions.dart';
import '../../application/project/project_settings.dart';
import '../../application/scan/scan_controller.dart';
import '../../domain/policy/conflict_priority.dart';
import '../../domain/validation/pack_icon_validator.dart';
import '../../infrastructure/language/language_profile.dart';
import '../../infrastructure/language/language_profile_catalog.dart';
import '../common/lf_button.dart';
import '../common/lf_toggle.dart';
import 'log_viewer_screen.dart';

/// S10 — 환경설정. EXPERIENCE.md S10 · ROADMAP 10.3 ~ 10.6.
///
/// Every tab edits the open project, not a global preference: two projects can
/// disagree about conflict handling, and the settings travel with the
/// `.lfproj` (TECHNICAL.md 3.2).
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final spacing = context.s;
    final settings = ref.watch(projectSettingsProvider);

    return Scaffold(
      backgroundColor: colors.bgBase,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(context.d.topBar),
        child: Material(
          color: colors.bgBar,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.space7),
              child: Row(
                children: [
                  Text('환경설정', style: context.t.title),
                  const Spacer(),
                  LfButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    label: '닫기',
                    style: LfButtonStyle.tertiary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabs,
            labelColor: colors.accent,
            unselectedLabelColor: colors.textMuted,
            indicatorColor: colors.accent,
            tabs: const [
              Tab(text: '일반'),
              Tab(text: '변수 보호'),
              Tab(text: '충돌 처리'),
              Tab(text: '언어 프로필'),
            ],
          ),
          Expanded(
            child: switch (settings) {
              AsyncError(:final error) => _CenteredMessage(
                '설정을 읽지 못했습니다: $error',
              ),
              AsyncData(:final value) => TabBarView(
                controller: _tabs,
                children: [
                  _GeneralTab(settings: value),
                  const _TokenProtectionTab(),
                  _ConflictTab(settings: value),
                  _LanguageProfileTab(settings: value),
                ],
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }
}

class _GeneralTab extends ConsumerWidget {
  const _GeneralTab({required this.settings});

  final ProjectSettingsData settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = context.s;
    final colors = context.c;

    return ListView(
      padding: EdgeInsets.all(spacing.space8),
      children: [
        for (final toggle in ToggleId.values)
          Padding(
            padding: EdgeInsets.only(bottom: spacing.space7),
            child: _ToggleRow(
              toggle: toggle,
              value: toggle.read(settings.toggles),
              onChanged: (value) => unawaited(
                ref
                    .read(projectSettingsProvider.notifier)
                    .setToggle(toggle, value),
              ),
            ),
          ),
        Divider(color: colors.borderPanel),
        SizedBox(height: spacing.space7),
        Text('pack.png', style: context.t.body),
        SizedBox(height: spacing.space3),
        Text(
          '리소스팩 아이콘. 아이콘이 실패해도 출력 자체는 계속됩니다.',
          style: context.t.caption.copyWith(color: colors.textMuted),
        ),
        SizedBox(height: spacing.space5),
        RadioGroup<String>(
          groupValue: settings.packIconMode,
          onChanged: (value) {
            if (value == null) return;
            unawaited(
              ref
                  .read(projectSettingsProvider.notifier)
                  .setPackIcon(mode: value, clearPath: value != 'custom'),
            );
          },
          child: Column(
            children: [
              for (final choice in _packIconChoices)
                RadioListTile<String>(
                  dense: true,
                  value: choice.$1,
                  title: Text(choice.$2, style: context.t.bodySm),
                ),
            ],
          ),
        ),
        if (settings.packIconMode == 'custom') ...[
          SizedBox(height: spacing.space4),
          Text(
            settings.packIconPath == null
                ? '이미지를 아직 고르지 않았습니다.'
                : '선택됨: ${settings.packIconPath}',
            style: context.t.caption.copyWith(color: colors.textMuted),
          ),
          SizedBox(height: spacing.space4),
          Align(
            alignment: Alignment.centerLeft,
            child: LfButton(
              label: 'PNG 선택…',
              style: LfButtonStyle.secondary,
              onPressed: () => unawaited(_pickCustomPackIcon(ref, context)),
            ),
          ),
        ],
        SizedBox(height: spacing.space7),
        Align(
          alignment: Alignment.centerLeft,
          child: LfButton(
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(builder: (_) => const LogViewerScreen()),
            ),
            label: '로그 보기',
            style: LfButtonStyle.secondary,
          ),
        ),
      ],
    );
  }
}

const _packIconChoices = <(String, String)>[
  ('default', '기본 LangForge 아이콘'),
  ('custom', '사용자 이미지'),
  ('mod', '원본 모드 아이콘'),
  ('none', 'pack.png 없이 출력'),
];

Future<void> _pickCustomPackIcon(WidgetRef ref, BuildContext context) async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['png'],
    allowMultiple: false,
  );
  final path = result?.files.singleOrNull?.path;
  if (path == null) return;

  // ignore: avoid_slow_async_io
  final fileBytes = await File(path).readAsBytes();
  final validation = PackIconValidator.validate(fileBytes);
  if (!validation.isValid) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validation.reason ?? '이미지를 사용할 수 없습니다')),
      );
    }
    return;
  }
  await ref
      .read(projectSettingsProvider.notifier)
      .setPackIcon(mode: 'custom', path: path);
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.toggle,
    required this.value,
    required this.onChanged,
  });

  final ToggleId toggle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = context.s;
    final colors = context.c;

    // 출력 전 검사 건너뛰기 is the one toggle that can ship a broken pack, so it
    // says so instead of reading like the others (E3).
    final isRisky = toggle == ToggleId.allowSkipChecks && value;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(toggle.label, style: context.t.body),
              SizedBox(height: spacing.space2),
              Text(
                isRisky
                    ? '${toggle.description} 검사에 걸린 문제가 그대로 출력됩니다.'
                    : toggle.description,
                style: context.t.caption.copyWith(
                  color: isRisky ? colors.warning : colors.textMuted,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: spacing.space5),
        LfToggle(
          value: value,
          semanticLabel: toggle.label,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ConflictTab extends ConsumerWidget {
  const _ConflictTab({required this.settings});

  final ProjectSettingsData settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = context.s;
    final colors = context.c;

    return ListView(
      padding: EdgeInsets.all(spacing.space8),
      children: [
        Text('충돌 우선순위', style: context.t.body),
        SizedBox(height: spacing.space3),
        Text(
          '두 JAR 이 같은 키의 원문을 다르게 가질 때 어느 쪽을 먼저 제안할지 정합니다. '
          '제안일 뿐이며, 최종 값은 충돌 해결 화면에서 직접 확인해야 합니다.',
          style: context.t.caption.copyWith(color: colors.textMuted),
        ),
        SizedBox(height: spacing.space7),
        RadioGroup<ConflictPriority>(
          groupValue: settings.conflictPriority,
          onChanged: (value) {
            if (value == null) return;
            unawaited(() async {
              await ref
                  .read(projectSettingsProvider.notifier)
                  .setConflictPriority(value);
              await ref
                  .read(scanControllerProvider.notifier)
                  .refreshConflicts();
            }());
          },
          child: Column(
            children: [
              for (final priority in ConflictPriority.values)
                RadioListTile<ConflictPriority>(
                  value: priority,
                  activeColor: colors.accent,
                  contentPadding: EdgeInsets.zero,
                  title: Text(priority.label, style: context.t.body),
                  subtitle: priority == ConflictPriority.manual
                      ? Text(
                          '아무것도 미리 선택하지 않습니다.',
                          style: context.t.caption.copyWith(
                            color: colors.textMuted,
                          ),
                        )
                      : null,
                ),
            ],
          ),
        ),
        SizedBox(height: spacing.space7),
        Text(
          '자동 덮어쓰기는 어떤 설정에서도 일어나지 않습니다. 해결되지 않은 충돌이 남아 있으면 출력은 차단됩니다.',
          style: context.t.caption.copyWith(color: colors.textMuted),
        ),
      ],
    );
  }
}

/// Read-only for MVP+1: the patterns are a correctness guarantee, so they are
/// shown to explain what is protected rather than offered for editing.
class _TokenProtectionTab extends StatelessWidget {
  const _TokenProtectionTab();

  static const _patterns = <(String, String, String)>[
    ('이스케이프된 %%', r'%%', '100%% → 100%'),
    ('색 코드 §a · §r', r'§[0-9a-fk-orA-FK-OR]', '§aGreen'),
    ('HEX 색 코드', r'§x(§[0-9a-fA-F]){6}', '§x§F§F§A§A§0§0'),
    ('위치 지정 printf', r'%1$s · %2$d · %1$.1f', 'Deals %1\$.1f damage.'),
    ('일반 printf', r'%s · %d · %02d', '%s joined the game'),
    ('셸 스타일', r'${name}', r'Welcome, ${player}'),
    ('중괄호 두 겹', r'{{name}}', '{{count}} items'),
    ('중괄호', r'{0} · {name}', 'Level {0}'),
    ('JSON 이스케이프', r'\n · \t · \" · \\', r'Line 1\nLine 2'),
  ];

  @override
  Widget build(BuildContext context) {
    final spacing = context.s;
    final colors = context.c;

    return ListView(
      padding: EdgeInsets.all(spacing.space8),
      children: [
        Text(
          '아래 패턴은 번역기로 보내기 전에 보이지 않는 자리표시자로 바꾸고, 번역 결과에서 원래 값으로 되돌립니다. '
          '하나라도 되돌리지 못하면 그 항목은 검증 실패로 표시됩니다.',
          style: context.t.caption.copyWith(color: colors.textMuted),
        ),
        SizedBox(height: spacing.space8),
        for (final (name, pattern, example) in _patterns)
          Padding(
            padding: EdgeInsets.only(bottom: spacing.space6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: context.t.body),
                SizedBox(height: spacing.space2),
                Text(
                  pattern,
                  style: context.t.codeBody.copyWith(color: colors.accent),
                ),
                Text(
                  example,
                  style: context.t.caption.copyWith(color: colors.textMuted),
                ),
              ],
            ),
          ),
        Divider(color: colors.borderPanel),
        SizedBox(height: spacing.space6),
        Text('멀티셋 예시', style: context.t.body),
        SizedBox(height: spacing.space3),
        Text(
          '§aDeals %1\$.1f damage to {target}\\n',
          style: context.t.codeBody.copyWith(color: colors.accent),
        ),
        SizedBox(height: spacing.space2),
        Text(
          '한 문장에 색 코드 · 위치 지정 printf · 중괄호 · 줄바꿈이 함께 있어도 순서와 개수가 모두 보존됩니다.',
          style: context.t.caption.copyWith(color: colors.textMuted),
        ),
      ],
    );
  }
}

/// The code mapping table of ROADMAP 10.6, straight from the asset.
class _LanguageProfileTab extends ConsumerWidget {
  const _LanguageProfileTab({required this.settings});

  final ProjectSettingsData settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = context.s;
    final colors = context.c;

    if (!LanguageProfileCatalog.isLoaded) {
      return const _CenteredMessage('언어 프로필을 아직 읽지 못했습니다.');
    }
    final profiles = LanguageProfileCatalog.all;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.space8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '대상 언어를 고르면 출력 파일 이름과 각 번역기에 보내는 언어 코드가 함께 바뀝니다.',
            style: context.t.caption.copyWith(color: colors.textMuted),
          ),
          SizedBox(height: spacing.space6),
          Text('대상 언어', style: context.t.body),
          SizedBox(height: spacing.space3),
          DropdownButton<String>(
            value: profiles.any((p) => p.mc == settings.targetLangCode)
                ? settings.targetLangCode
                : profiles.first.mc,
            isExpanded: true,
            items: [
              for (final profile in profiles)
                DropdownMenuItem(
                  value: profile.mc,
                  child: Text('${profile.displayName} (${profile.outputFile})'),
                ),
            ],
            onChanged: (value) {
              if (value == null) return;
              unawaited(
                ref.read(projectSettingsProvider.notifier).setTargetLang(value),
              );
            },
          ),
          SizedBox(height: spacing.space8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: context.t.caption.copyWith(
                color: colors.textMuted,
              ),
              dataTextStyle: context.t.body,
              columns: const [
                DataColumn(label: Text('언어')),
                DataColumn(label: Text('코드')),
                DataColumn(label: Text('출력 파일')),
                DataColumn(label: Text('Google')),
                DataColumn(label: Text('Papago')),
                DataColumn(label: Text('DeepL')),
                DataColumn(label: Text('Gemini')),
              ],
              rows: [
                for (final profile in profiles)
                  DataRow(
                    selected: profile.mc == settings.targetLangCode,
                    cells: [
                      DataCell(Text(profile.displayName)),
                      DataCell(_Mono(profile.mc)),
                      DataCell(_Mono(profile.outputFile)),
                      DataCell(_Mono(profile.codeFor('google'))),
                      DataCell(_Mono(profile.codeFor('papago'))),
                      DataCell(_Mono(profile.codeFor('deepl'))),
                      DataCell(_Mono(profile.codeFor('gemini'))),
                    ],
                  ),
              ],
            ),
          ),
          SizedBox(height: spacing.space8),
          Text(
            '별칭 — 입력 파일의 언어 파일 이름이 아래 중 하나면 같은 언어로 인식합니다.',
            style: context.t.caption.copyWith(color: colors.textMuted),
          ),
          SizedBox(height: spacing.space5),
          for (final profile in profiles) _AliasRow(profile: profile),
        ],
      ),
    );
  }
}

class _AliasRow extends StatelessWidget {
  const _AliasRow({required this.profile});

  final LanguageProfile profile;

  @override
  Widget build(BuildContext context) {
    final spacing = context.s;
    return Padding(
      padding: EdgeInsets.only(bottom: spacing.space3),
      child: Text(
        '${profile.displayName} — ${profile.aliases.join(' · ')}',
        style: context.t.caption.copyWith(color: context.c.textMuted),
      ),
    );
  }
}

class _Mono extends StatelessWidget {
  const _Mono(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.t.codeBody.copyWith(color: context.c.textMuted),
  );
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      text,
      style: context.t.body.copyWith(color: context.c.textMuted),
    ),
  );
}
