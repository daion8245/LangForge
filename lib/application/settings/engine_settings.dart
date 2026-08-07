import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/provider/translation_error.dart';
import '../../domain/provider/translation_provider.dart';
import '../../infrastructure/provider/provider_registry.dart';
import '../../infrastructure/security/credential_store.dart';

/// Engine, model and credential state for the translation run.
///
/// Lifted out of the settings panel so it survives the panel moving between
/// its docked position and the end drawer, and so a keyboard shortcut can
/// start a run without the panel being on screen (EXPERIENCE.md 8).
class EngineSettings {
  const EngineSettings({
    required this.providerId,
    required this.model,
    this.apiKey = '',
    this.isVerified = false,
    this.isTesting = false,
    this.statusMessage,
    this.usesSessionOnlyStorage = false,
  });

  final String providerId;
  final String model;

  /// Held in memory only for the length of the session. It is written to the
  /// OS credential store, never to the project file (AC-10.6).
  final String apiKey;

  final bool isVerified;
  final bool isTesting;
  final String? statusMessage;

  /// The OS credential store refused the key, so it will be gone on restart
  /// (AC-11.4).
  final bool usesSessionOnlyStorage;

  TranslationProvider get provider => ProviderRegistry.byId(providerId);

  /// Which required auth fields are still empty (AC-5.1).
  List<String> get missingFieldLabels {
    final values = {'apiKey': apiKey.trim()};
    return provider.authFields
        .where((field) => (values[field.id] ?? '').isEmpty)
        .map((field) => field.label)
        .toList();
  }

  AuthValues get authValues => AuthValues({'apiKey': apiKey});

  EngineSettings copyWith({
    String? providerId,
    String? model,
    String? apiKey,
    bool? isVerified,
    bool? isTesting,
    String? statusMessage,
    bool? usesSessionOnlyStorage,
    bool clearStatus = false,
  }) {
    return EngineSettings(
      providerId: providerId ?? this.providerId,
      model: model ?? this.model,
      apiKey: apiKey ?? this.apiKey,
      isVerified: isVerified ?? this.isVerified,
      isTesting: isTesting ?? this.isTesting,
      statusMessage: clearStatus ? null : (statusMessage ?? this.statusMessage),
      usesSessionOnlyStorage:
          usesSessionOnlyStorage ?? this.usesSessionOnlyStorage,
    );
  }
}

class EngineSettingsController extends Notifier<EngineSettings> {
  @override
  EngineSettings build() {
    final provider = ProviderRegistry.byId(ProviderRegistry.defaultProviderId);
    return EngineSettings(
      providerId: provider.id,
      model: provider.models.first,
    );
  }

  /// Pulls a previously stored key out of the OS credential store.
  Future<void> loadStoredKey() async {
    final stored = await CredentialStore.readCredential(
      state.providerId,
      'apiKey',
    );
    if (stored == null || stored.isEmpty) return;
    state = state.copyWith(apiKey: stored);
  }

  Future<void> setApiKey(String value) async {
    // Changing the key invalidates whatever the last connection test proved.
    state = state.copyWith(apiKey: value, isVerified: false, clearStatus: true);

    if (value.trim().isEmpty) return;
    final persisted = await CredentialStore.saveCredential(
      state.providerId,
      'apiKey',
      value,
    );
    if (!persisted) {
      state = state.copyWith(
        usesSessionOnlyStorage: true,
        statusMessage:
            '자격 증명 저장소에 접근할 수 없어 이번 세션에만 키를 보관합니다. 앱을 닫으면 다시 입력해야 합니다.',
      );
    }
  }

  void setModel(String model) => state = state.copyWith(model: model);

  Future<void> setProviderId(String providerId) async {
    if (providerId == state.providerId) return;
    final provider = ProviderRegistry.byId(providerId);
    state = EngineSettings(
      providerId: providerId,
      model: provider.models.isEmpty ? '' : provider.models.first,
    );
    await loadStoredKey();
  }

  /// AC-5.2 — verifies the key with a real request.
  Future<void> testConnection() async {
    final missing = state.missingFieldLabels;
    if (missing.isNotEmpty) {
      state = state.copyWith(
        isVerified: false,
        statusMessage: '${missing.join(' · ')} 항목이 비어 있습니다.',
      );
      return;
    }

    state = state.copyWith(isTesting: true, clearStatus: true);
    try {
      await state.provider.verify(state.authValues);
      state = state.copyWith(
        isTesting: false,
        isVerified: true,
        statusMessage: '연결 성공! API 키가 유효합니다.',
      );
    } on TranslationError catch (error) {
      state = state.copyWith(
        isTesting: false,
        isVerified: false,
        statusMessage: '연결 실패: ${error.message}',
      );
    } catch (error) {
      state = state.copyWith(
        isTesting: false,
        isVerified: false,
        statusMessage: '연결 오류: $error',
      );
    }
  }

  void reportMissingFields() {
    final missing = state.missingFieldLabels;
    if (missing.isEmpty) return;
    state = state.copyWith(
      statusMessage: '${missing.join(' · ')} 항목이 비어 있습니다.',
    );
  }

  Future<void> forgetKey() async {
    await CredentialStore.deleteProvider(state.providerId);
    state = state.copyWith(
      apiKey: '',
      isVerified: false,
      usesSessionOnlyStorage: false,
      statusMessage: '저장된 API 키를 삭제했습니다.',
    );
  }
}

final engineSettingsProvider =
    NotifierProvider<EngineSettingsController, EngineSettings>(
      EngineSettingsController.new,
    );
