import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract final class CredentialStore {
  static const _storage = FlutterSecureStorage(wOptions: WindowsOptions());
  static final Map<String, String> _memoryFallback = {};

  static String _key(String providerId, String fieldId) =>
      'langforge_${providerId}_$fieldId';

  /// Saves a credential securely in OS credential manager (with in-memory fallback).
  static Future<void> saveCredential(
    String providerId,
    String fieldId,
    String value,
  ) async {
    final k = _key(providerId, fieldId);
    _memoryFallback[k] = value;
    try {
      await _storage.write(key: k, value: value);
    } catch (_) {}
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
    } catch (_) {}
    return _memoryFallback[k];
  }

  /// Deletes a credential.
  static Future<void> deleteCredential(
    String providerId,
    String fieldId,
  ) async {
    final k = _key(providerId, fieldId);
    _memoryFallback.remove(k);
    try {
      await _storage.delete(key: k);
    } catch (_) {}
  }
}
