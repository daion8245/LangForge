import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/theme_extensions.dart';
import '../../../application/settings/engine_settings.dart';
import '../../../infrastructure/provider/provider_registry.dart';
import '../../common/lf_button.dart';
import '../../common/lf_text_field.dart';

/// S2-C — engine, credentials, and the primary run control.
class SettingsPanel extends ConsumerStatefulWidget {
  const SettingsPanel({
    super.key,
    required this.waitCount,
    required this.isTranslating,
    required this.onStartTranslation,
    required this.onPauseTranslation,
    this.isPaused = false,
    this.onResumeTranslation,
    this.isDocked = true,
  });

  final int waitCount;
  final bool isTranslating;
  final bool isPaused;
  final VoidCallback onStartTranslation;
  final VoidCallback onPauseTranslation;
  final VoidCallback? onResumeTranslation;

  /// Docked to the right of the editor. Inside the end drawer the panel takes
  /// the drawer's width instead of imposing its own, which would overflow the
  /// drawer by the width of its border (DESIGN.md 6.2).
  final bool isDocked;

  @override
  ConsumerState<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends ConsumerState<SettingsPanel> {
  late final TextEditingController _apiKeyController;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(
      text: ref.read(engineSettingsProvider).apiKey,
    );
    // The key may already be in the OS credential store from a previous run.
    Future<void>.microtask(() async {
      await ref.read(engineSettingsProvider.notifier).loadStoredKey();
      if (!mounted) return;
      final loaded = ref.read(engineSettingsProvider).apiKey;
      if (loaded.isNotEmpty && _apiKeyController.text != loaded) {
        _apiKeyController.text = loaded;
      }
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _launchApiKeyUrl() async {
    final settings = ref.read(engineSettingsProvider);
    final helpUrl = settings.provider.authFields.first.helpUrl;
    if (helpUrl == null) return;
    final url = Uri.parse(helpUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final spacing = context.s;
    final typography = context.t;

    final settings = ref.watch(engineSettingsProvider);
    final notifier = ref.read(engineSettingsProvider.notifier);
    final locked = widget.isTranslating;

    return FocusTraversalGroup(
      child: Container(
        width: widget.isDocked ? context.d.settingsPanel : null,
        decoration: BoxDecoration(
          color: colors.bgSurface,
          border: widget.isDocked
              ? Border(
                  left: BorderSide(
                    color: colors.borderPanel,
                    width: context.d.borderThin,
                  ),
                )
              : null,
        ),
        padding: EdgeInsets.all(spacing.space7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '작업 및 엔진 설정',
              style: typography.overline.copyWith(color: colors.textFaint),
            ),
            SizedBox(height: spacing.space7),

            Text(
              '번역 엔진',
              style: typography.caption.copyWith(color: colors.textSecondary),
            ),
            SizedBox(height: spacing.space3),
            _dropdownShell(
              context,
              child: DropdownButton<String>(
                value: settings.providerId,
                isExpanded: true,
                dropdownColor: colors.bgRaised,
                items: [
                  for (final provider in ProviderRegistry.available())
                    DropdownMenuItem(
                      value: provider.id,
                      child: Text(
                        provider.displayName,
                        style: typography.bodySm.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                ],
                // Engine settings are locked during a run (EXPERIENCE.md 6.4).
                onChanged: locked
                    ? null
                    : (value) {
                        if (value != null) notifier.setProviderId(value);
                      },
              ),
            ),
            SizedBox(height: spacing.space6),

            Row(
              children: [
                Text(
                  settings.provider.authFields.first.label,
                  style: typography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: _launchApiKeyUrl,
                  child: Text(
                    '키 발급받기',
                    style: typography.caption.copyWith(color: colors.accent),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.space3),
            LfTextField(
              controller: _apiKeyController,
              obscureText: true,
              readOnly: locked,
              placeholder: 'AIzaSy...',
              onChanged: notifier.setApiKey,
            ),
            SizedBox(height: spacing.space6),

            Text(
              '모델 선택',
              style: typography.caption.copyWith(color: colors.textSecondary),
            ),
            SizedBox(height: spacing.space3),
            _dropdownShell(
              context,
              child: DropdownButton<String>(
                value: settings.model,
                isExpanded: true,
                dropdownColor: colors.bgRaised,
                items: [
                  for (final model in settings.provider.models)
                    DropdownMenuItem(
                      value: model,
                      child: Text(
                        model,
                        style: typography.bodySm.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                ],
                onChanged: locked
                    ? null
                    : (value) {
                        if (value != null) notifier.setModel(value);
                      },
              ),
            ),
            SizedBox(height: spacing.space7),

            LfButton(
              onPressed: settings.isTesting || locked
                  ? null
                  : notifier.testConnection,
              label: settings.isTesting ? '검증 중...' : '연결 테스트',
              tooltip: locked ? '번역이 진행 중입니다' : null,
              icon: Icon(LucideIcons.plug, size: context.d.iconMd),
              style: LfButtonStyle.secondary,
            ),

            if (settings.statusMessage != null) ...[
              SizedBox(height: spacing.space4),
              // A status is never signalled by colour alone (DESIGN.md 14).
              Text(
                settings.statusMessage!,
                style: typography.caption.copyWith(
                  color: settings.isVerified
                      ? colors.successText
                      : colors.dangerText,
                ),
              ),
            ],

            const Spacer(),

            if (widget.isPaused)
              LfButton(
                onPressed: widget.onResumeTranslation,
                label: '일시정지됨 — 재개',
                icon: Icon(LucideIcons.play, size: context.d.iconMd),
                style: LfButtonStyle.primary,
              )
            else if (widget.isTranslating)
              LfButton(
                onPressed: widget.onPauseTranslation,
                label: '번역 진행 중… (일시정지)',
                icon: Icon(LucideIcons.pause, size: context.d.iconMd),
                style: LfButtonStyle.secondary,
              )
            else
              LfButton(
                onPressed: widget.waitCount == 0
                    ? null
                    : widget.onStartTranslation,
                label: widget.waitCount == 0
                    ? '번역 대기 항목 없음'
                    : '대기 항목 번역 시작 (${widget.waitCount})',
                tooltip: widget.waitCount == 0 ? '번역할 대기 항목이 없습니다' : 'Ctrl+R',
                icon: Icon(LucideIcons.play, size: context.d.iconMd),
                style: LfButtonStyle.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _dropdownShell(BuildContext context, {required Widget child}) {
    final colors = context.c;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.s.space7),
      decoration: BoxDecoration(
        color: colors.bgRaised,
        borderRadius: context.r.r2xl,
        border: Border.all(
          color: colors.borderControl,
          width: context.d.borderThin,
        ),
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }
}
