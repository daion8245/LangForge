import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_extensions.dart';
import '../../../application/mobile/mobile_ui_controller.dart';
import '../../../application/project/project_settings.dart';
import '../../../application/settings/engine_settings.dart';
import '../../../infrastructure/language/language_profile.dart';
import '../../../infrastructure/language/language_profile_catalog.dart';
import '../../../infrastructure/provider/provider_registry.dart';
import '../widgets/mobile_controls.dart';
import '../widgets/mobile_select.dart';
import '../widgets/mobile_sheet.dart';

/// 설정 sheet — ROADMAP 13.3.
///
/// Pinned below the header and scrolling inside itself (MOBILE.md 2.3), because
/// it is the one sheet with more content than a phone screen: engine, its auth
/// fields, the language pair, and the project toggles.
///
/// Credentials go to the OS credential store through the same controller the
/// desktop uses. Nothing here writes a key into the project file (AC-10.6).
class MobileSettingsSheet extends ConsumerWidget {
  const MobileSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = context.s;
    final colors = context.c;

    final engine = ref.watch(engineSettingsProvider);
    final engineNotifier = ref.read(engineSettingsProvider.notifier);
    final settings = ref.watch(projectSettingsProvider).asData?.value;
    final settingsNotifier = ref.read(projectSettingsProvider.notifier);
    final ui = ref.read(mobileUiControllerProvider.notifier);

    final providers = ProviderRegistry.available();
    final profiles = LanguageProfileCatalog.isLoaded
        ? LanguageProfileCatalog.all
        : const <LanguageProfile>[];
    final targetCode = settings?.targetLangCode ?? 'ko_kr';
    final targetProfile = profiles.where((p) => p.mc == targetCode).firstOrNull;

    return MobileSheetSurface(
      fillFromTop: true,
      padded: false,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              spacing.space9,
              spacing.space2 * 2,
              spacing.space9,
              spacing.space7 - 2,
            ),
            child: Column(
              children: [
                const MobileSheetHandle(),
                SizedBox(height: spacing.space7 - 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '설정',
                        style: context.t.title.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    _CloseButton(onTap: ui.closeSheet),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: context.d.borderThin, color: colors.bgSelected),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                spacing.space9,
                spacing.space8,
                spacing.space9,
                spacing.space11 - 2,
              ),
              children: [
                MobileSelect<String>(
                  label: '번역 서비스',
                  value: engine.providerId,
                  items: [for (final p in providers) p.id],
                  itemLabel: (id) => ProviderRegistry.byId(id).displayName,
                  onChanged: (id) => engineNotifier.setProviderId(id),
                ),
                SizedBox(height: spacing.space9),
                _AuthCard(engine: engine, notifier: engineNotifier),
                SizedBox(height: spacing.space9),
                if (profiles.isNotEmpty) ...[
                  MobileSelect<String>(
                    label: '대상 언어',
                    value: targetCode,
                    items: [for (final p in profiles) p.mc],
                    itemLabel: (mc) =>
                        profiles.firstWhere((p) => p.mc == mc).displayName,
                    onChanged: settingsNotifier.setTargetLang,
                  ),
                  SizedBox(height: spacing.space5),
                  Row(
                    children: [
                      Text(
                        '출력 파일명',
                        style: context.t.codeSm.copyWith(
                          color: colors.textDisabled,
                        ),
                      ),
                      SizedBox(width: spacing.space5),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.space8 / 2,
                          vertical: spacing.space1,
                        ),
                        decoration: BoxDecoration(
                          color: colors.statusDoneBg,
                          borderRadius: context.r.md,
                        ),
                        child: Text(
                          targetProfile?.outputFile ?? '$targetCode.json',
                          style: context.t.codeSm.copyWith(
                            color: colors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing.space9),
                ],
                for (final toggle in ToggleId.values) ...[
                  _ToggleRow(
                    toggle: toggle,
                    value: settings == null
                        ? false
                        : toggle.read(settings.toggles),
                    onChanged: settings == null
                        ? null
                        : (value) => settingsNotifier.setToggle(toggle, value),
                  ),
                  SizedBox(height: spacing.space8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    return MobileTapTarget(
      onTap: onTap,
      semanticLabel: '설정 닫기',
      borderRadius: context.r.xl,
      child: Container(
        height: context.d.buttonSecondary + 2,
        padding: EdgeInsets.symmetric(horizontal: context.s.space7 - 1),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.bgRaised,
          borderRadius: context.r.xl,
          border: Border.all(
            color: colors.borderControl,
            width: context.d.borderThin,
          ),
        ),
        child: Text(
          '닫기',
          style: context.t.bodySm.copyWith(color: colors.textStrong),
        ),
      ),
    );
  }
}

/// Auth fields for the selected engine, plus the connection test.
///
/// The fields come from the provider definition, so a new engine in
/// `providers.json` shows up here without a code change (TECHNICAL.md 3.6).
class _AuthCard extends StatefulWidget {
  const _AuthCard({required this.engine, required this.notifier});

  final EngineSettings engine;
  final EngineSettingsController notifier;

  @override
  State<_AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<_AuthCard> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String fieldId, String value) {
    final existing = _controllers[fieldId];
    if (existing != null) {
      // Only adopt the stored value when the user is not the one who typed it,
      // otherwise loading a saved credential would fight the cursor.
      if (existing.text.isEmpty && value.isNotEmpty) existing.text = value;
      return existing;
    }
    return _controllers[fieldId] = TextEditingController(text: value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final spacing = context.s;
    final engine = widget.engine;
    final provider = engine.provider;
    final verified = engine.isVerified;

    return Container(
      padding: EdgeInsets.all(spacing.space7),
      decoration: BoxDecoration(
        color: colors.bgSelected,
        borderRadius: context.r.r3xl,
        border: Border.all(
          color: colors.borderPanel,
          width: context.d.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${provider.displayName} 인증',
                  style: context.t.caption.copyWith(color: colors.textTertiary),
                ),
              ),
              Container(
                height: 19,
                padding: EdgeInsets.symmetric(horizontal: spacing.space8 / 2),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: verified ? colors.statusDoneBg : colors.statusWaitBg,
                  borderRadius: context.r.md,
                ),
                child: Text(
                  verified ? '연결됨' : '미확인',
                  style: context.t.chip.copyWith(
                    color: verified ? colors.accent : colors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.space7 - 2),
          for (final field in provider.authFields) ...[
            Text(
              field.label,
              style: context.t.micro.copyWith(color: colors.textMuted),
            ),
            SizedBox(height: spacing.space3),
            SizedBox(
              height: context.m.authField,
              child: TextField(
                controller: _controllerFor(
                  field.id,
                  engine.credentials[field.id] ?? '',
                ),
                obscureText: field.isSecret,
                autocorrect: false,
                enableSuggestions: false,
                onChanged: (value) =>
                    widget.notifier.setCredential(field.id, value),
                style: context.t.codeBody.copyWith(color: colors.textStrong),
                decoration: InputDecoration(
                  hintText: field.placeholder,
                  hintStyle: context.t.codeSm.copyWith(
                    color: colors.textDisabled,
                  ),
                  filled: true,
                  fillColor: colors.bgBar,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: spacing.space7 - 1,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: context.r.r3xl,
                    borderSide: BorderSide(color: colors.borderDashed),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: context.r.r3xl,
                    borderSide: BorderSide(color: colors.borderDashed),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: context.r.r3xl,
                    borderSide: BorderSide(color: colors.accent),
                  ),
                ),
              ),
            ),
            SizedBox(height: spacing.space6),
          ],
          if (provider.models.length > 1) ...[
            MobileSelect<String>(
              label: '모델',
              value: engine.model,
              items: provider.models,
              compact: true,
              onChanged: widget.notifier.setModel,
            ),
            SizedBox(height: spacing.space6),
          ],
          SizedBox(
            width: double.infinity,
            child: MobileTapTarget(
              onTap: engine.isTesting
                  ? null
                  : () => widget.notifier.testConnection(),
              semanticLabel: '연결 확인',
              borderRadius: context.r.r3xl,
              child: Container(
                height: context.d.buttonPrimary,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.bgRaisedHover,
                  borderRadius: context.r.r3xl,
                  border: Border.all(
                    color: colors.borderDashed,
                    width: context.d.borderThin,
                  ),
                ),
                child: Text(
                  engine.isTesting ? '확인 중…' : '연결 확인',
                  style: context.t.bodySm.copyWith(color: colors.textStrong),
                ),
              ),
            ),
          ),
          if (engine.statusMessage != null) ...[
            SizedBox(height: spacing.space5),
            Text(
              engine.statusMessage!,
              style: context.t.micro.copyWith(
                color: verified ? colors.accent : colors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.toggle,
    required this.value,
    required this.onChanged,
  });

  final ToggleId toggle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                toggle.label,
                style: context.t.body.copyWith(color: colors.textStrong),
              ),
              SizedBox(height: context.s.space1 + 1),
              Text(
                toggle.description,
                style: context.t.micro.copyWith(color: colors.textFaint),
              ),
            ],
          ),
        ),
        SizedBox(width: context.s.space8),
        MobileToggle(
          value: value,
          onChanged: onChanged,
          semanticLabel: toggle.label,
        ),
      ],
    );
  }
}
