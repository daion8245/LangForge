import 'dart:async';

class AuthField {
  final String id;
  final String label;
  final bool isSecret;
  final String? helpUrl;

  const AuthField({
    required this.id,
    required this.label,
    this.isSecret = true,
    this.helpUrl,
  });
}

class AuthValues {
  final Map<String, String> values;

  const AuthValues(this.values);

  String? get(String fieldId) => values[fieldId];
}

class BatchLimits {
  final int maxTextsPerRequest;
  final int maxCharsPerRequest;
  final int maxConcurrentRequests;
  final Duration requestTimeout;

  const BatchLimits({
    this.maxTextsPerRequest = 50,
    this.maxCharsPerRequest = 8000,
    this.maxConcurrentRequests = 4,
    this.requestTimeout = const Duration(seconds: 30),
  });
}

class CancellationToken {
  bool _isCancelled = false;
  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
  }
}

class TranslationRequest {
  /// List of protected texts to be translated.
  /// NOTE: JSON keys MUST NOT be included in this request.
  final List<String> texts;
  final String sourceCode;
  final String targetCode;
  final String? model;
  final AuthValues auth;
  final CancellationToken cancel;

  const TranslationRequest({
    required this.texts,
    required this.sourceCode,
    required this.targetCode,
    this.model,
    required this.auth,
    required this.cancel,
  });
}

abstract interface class TranslationProvider {
  String get id;
  String get displayName;
  List<AuthField> get authFields;
  List<String> get models;
  BatchLimits get limits;

  /// Verifies API credentials with a lightweight ping request.
  Future<void> verify(AuthValues auth);

  /// Translates a list of masked texts. Returns translated strings preserving length & order.
  /// NOTE: JSON key MUST NOT pass through this interface.
  Future<List<String>> translate(TranslationRequest request);
}
