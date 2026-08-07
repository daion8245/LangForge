import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';

abstract final class CredentialStore {
  static const _storage = FlutterSecureStorage(wOptions: WindowsOptions());

  /// Only holds keys the OS store refused to take. TECHNICAL.md 9.2 forbids a
  /// global cache of credentials that were stored successfully — this is the
  /// session-only substitute of AC-11.4, not a write-through cache.
  static final Map<String, String> _sessionFallback = {};

  static final Logger _log = Logger('CredentialStore');

  /// True once any credential has had to fall back to memory. The UI shows the
  /// "앱을 닫으면 다시 입력해야 합니다" banner off this (AC-11.4).
  static bool get isUsingSessionFallback => _sessionFallback.isNotEmpty;

  static String _key(String providerId, String fieldId) =>
      'LangForge/$providerId/$fieldId';

  /// Saves a credential to the OS credential manager.
  ///
  /// Returns true when it reached secure storage, false when it is only held
  /// in memory for this session.
  static Future<bool> saveCredential(
    String providerId,
    String fieldId,
    String value,
  ) async {
    final k = _key(providerId, fieldId);
    try {
      await _storage.write(key: k, value: value);
      _sessionFallback.remove(k);
      return true;
    } catch (e) {
      // The value itself is never logged — only that the write failed.
      _log.warning(
        'Secure storage write failed; keeping key in session memory',
        e,
      );
      _sessionFallback[k] = value;
      return false;
    }
  }

  /// Reads a credential securely from OS credential manager.
  static Future<String?> readCredential(
    String providerId,
    String fieldId,
  ) async {
    final k = _key(providerId, fieldId);
    try {
      final val = await _storage.read(key: k);
      if (val != null) return val;
    } catch (e) {
      _log.warning('Secure storage read failed; trying session memory', e);
    }
    return _sessionFallback[k];
  }

  /// Deletes a credential.
  static Future<void> deleteCredential(
    String providerId,
    String fieldId,
  ) async {
    final k = _key(providerId, fieldId);
    _sessionFallback.remove(k);
    try {
      await _storage.delete(key: k);
    } catch (e) {
      _log.warning('Secure storage delete failed', e);
    }
  }

  /// Removes every credential belonging to one provider (TECHNICAL.md 9.2).
  static Future<void> deleteProvider(String providerId) async {
    final prefix = 'LangForge/$providerId/';
    _sessionFallback.removeWhere((key, _) => key.startsWith(prefix));
    try {
      final all = await _storage.readAll();
      for (final key in all.keys.where((k) => k.startsWith(prefix))) {
        await _storage.delete(key: key);
      }
    } catch (e) {
      _log.warning('Secure storage provider delete failed', e);
    }
  }
}
