import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/theme_extensions.dart';
import '../../../domain/provider/translation_error.dart';
import '../../../domain/provider/translation_provider.dart';
import '../../../infrastructure/provider/gemini_provider.dart';
import '../../../infrastructure/security/credential_store.dart';
import '../../common/lf_button.dart';
import '../../common/lf_text_field.dart';

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({
    super.key,
    required this.waitCount,
    required this.isTranslating,
    required this.onStartTranslation,
    required this.onPauseTranslation,
  });

  final int waitCount;
  final bool isTranslating;
  final void Function(
    TranslationProvider provider,
    AuthValues auth,
    String model,
  )
  onStartTranslation;
  final VoidCallback onPauseTranslation;

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  late TranslationProvider _selectedProvider;
  late String _selectedModel;
  final _apiKeyController = TextEditingController();

  bool _isTestingConnection = false;
  String? _connectionStatusMessage;
  bool _isConnectionOk = false;

  @override
  void initState() {
    super.initState();
    _selectedProvider = GeminiProvider();
    _selectedModel = _selectedProvider.models.first;
    _loadSavedKey();
  }

  Future<void> _loadSavedKey() async {
    final savedKey = await CredentialStore.readCredential(
      _selectedProvider.id,
      'apiKey',
    );
    if (savedKey != null && mounted) {
      setState(() {
        _apiKeyController.text = savedKey;
      });
    }
  }

  Future<void> _saveKey(String val) async {
    await CredentialStore.saveCredential(_selectedProvider.id, 'apiKey', val);
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTestingConnection = true;
      _connectionStatusMessage = null;
    });

    final auth = AuthValues({'apiKey': _apiKeyController.text});

    try {
      await _selectedProvider.verify(auth);
      if (mounted) {
        setState(() {
          _isConnectionOk = true;
          _connectionStatusMessage = '연결 성각! API 키가 유효합니다.';
        });
      }
    } on AuthError catch (e) {
      if (mounted) {
        setState(() {
          _isConnectionOk = false;
          _connectionStatusMessage = '연결 실패: ${e.message}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnectionOk = false;
          _connectionStatusMessage = '연결 오류: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTestingConnection = false;
        });
      }
    }
  }

  Future<void> _launchApiKeyUrl() async {
    final url = Uri.parse('https://aistudio.google.com/app/apikey');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final spacing = context.s;
    final typography = context.t;
    final radii = context.r;

    return Container(
      width: 336,
      decoration: BoxDecoration(
        color: colors.bgSurface,
        border: Border(left: BorderSide(color: colors.borderPanel, width: 1)),
      ),
      padding: EdgeInsets.all(spacing.space7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            '작업 및 엔진 설정',
            style: typography.overline.copyWith(color: colors.textFaint),
          ),
          SizedBox(height: spacing.space7),

          // Provider Dropdown
          Text(
            '번역 엔진',
            style: typography.caption.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: spacing.space3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: colors.bgRaised,
              borderRadius: radii.r2xl,
              border: Border.all(color: colors.borderControl, width: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedProvider.id,
                isExpanded: true,
                dropdownColor: colors.bgRaised,
                items: [
                  DropdownMenuItem(
                    value: _selectedProvider.id,
                    child: Text(
                      _selectedProvider.displayName,
                      style: typography.bodySm.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
          SizedBox(height: spacing.space6),

          // API Key Input Field
          Row(
            children: [
              Text(
                'Gemini API Key',
                style: typography.caption.copyWith(color: colors.textSecondary),
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
            placeholder: 'AIzaSy...',
            onChanged: (val) => _saveKey(val),
          ),
          SizedBox(height: spacing.space6),

          // Model Dropdown
          Text(
            '모델 선택',
            style: typography.caption.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: spacing.space3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: colors.bgRaised,
              borderRadius: radii.r2xl,
              border: Border.all(color: colors.borderControl, width: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedModel,
                isExpanded: true,
                dropdownColor: colors.bgRaised,
                items: _selectedProvider.models.map((m) {
                  return DropdownMenuItem(
                    value: m,
                    child: Text(
                      m,
                      style: typography.bodySm.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedModel = val);
                },
              ),
            ),
          ),
          SizedBox(height: spacing.space7),

          // Connection Test Button
          LfButton(
            onPressed: _isTestingConnection ? null : _testConnection,
            label: _isTestingConnection ? '검증 중...' : '연결 테스트',
            icon: const Icon(LucideIcons.plug, size: 16),
            style: LfButtonStyle.secondary,
          ),

          if (_connectionStatusMessage != null) ...[
            SizedBox(height: spacing.space4),
            Text(
              _connectionStatusMessage!,
              style: typography.caption.copyWith(
                color: _isConnectionOk ? colors.successText : colors.dangerText,
              ),
            ),
          ],

          const Spacer(),

          // Primary Translation Start / Pause Action Button
          if (widget.isTranslating)
            LfButton(
              onPressed: widget.onPauseTranslation,
              label: '번역 진행 중… (일시정지)',
              icon: const Icon(LucideIcons.pause, size: 16),
              style: LfButtonStyle.secondary,
            )
          else
            LfButton(
              onPressed: widget.waitCount == 0
                  ? null
                  : () {
                      final auth = AuthValues({
                        'apiKey': _apiKeyController.text,
                      });
                      widget.onStartTranslation(
                        _selectedProvider,
                        auth,
                        _selectedModel,
                      );
                    },
              label: widget.waitCount == 0
                  ? '번역 대기 항목 없음'
                  : '대기 항목 번역 시작 (${widget.waitCount})',
              icon: const Icon(LucideIcons.play, size: 16),
              style: LfButtonStyle.primary,
            ),
        ],
      ),
    );
  }
}
