import '../../domain/provider/translation_provider.dart';

/// One provider entry from `assets/data/providers.json`.
class ProviderDefinition {
  const ProviderDefinition({
    required this.id,
    required this.displayName,
    required this.authFields,
    required this.models,
    required this.limits,
    this.baseUrl,
    this.translatePath,
    this.endpoints = const {},
  });

  final String id;
  final String displayName;
  final List<AuthField> authFields;
  final List<String> models;
  final BatchLimits limits;
  final String? baseUrl;
  final String? translatePath;
  final Map<String, String> endpoints;

  String translateUrl({String? model}) {
    if (endpoints.isNotEmpty) {
      throw StateError(
        'Provider $id uses named endpoints; pick free/pro explicitly',
      );
    }
    final base = baseUrl;
    if (base == null) {
      throw StateError('Provider $id has no baseUrl');
    }
    final path = translatePath;
    if (path == null || path.isEmpty) return base;
    final resolved = path.replaceAll('{model}', model ?? models.first);
    if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
      return resolved;
    }
    final baseTrimmed = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    final pathTrimmed = resolved.startsWith('/') ? resolved : '/$resolved';
    return '$baseTrimmed$pathTrimmed';
  }

  factory ProviderDefinition.fromJson(Map<String, dynamic> json) {
    final modelsJson = (json['models'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    final modelIds = modelsJson
        .map((m) => m['id'] as String)
        .toList(growable: false);

    final authJson = (json['authFields'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    final authFields = authJson
        .map(
          (field) => AuthField(
            id: field['id'] as String,
            label: field['label'] as String,
            isSecret: field['isSecret'] as bool? ?? true,
            helpUrl: field['helpUrl'] as String?,
            placeholder: field['placeholder'] as String?,
          ),
        )
        .toList(growable: false);

    final limitsJson = json['limits'] as Map<String, dynamic>? ?? const {};
    final limits = BatchLimits(
      maxTextsPerRequest: limitsJson['maxTextsPerRequest'] as int? ?? 50,
      maxCharsPerRequest: limitsJson['maxCharsPerRequest'] as int? ?? 8000,
      maxConcurrentRequests: limitsJson['maxConcurrentRequests'] as int? ?? 4,
      requestTimeout: Duration(
        seconds: limitsJson['requestTimeoutSeconds'] as int? ?? 30,
      ),
    );

    final endpointsJson = json['endpoints'] as Map<String, dynamic>?;
    final endpoints = <String, String>{
      if (endpointsJson != null)
        for (final entry in endpointsJson.entries)
          entry.key: entry.value as String,
    };

    return ProviderDefinition(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      authFields: authFields,
      models: modelIds,
      limits: limits,
      baseUrl: json['baseUrl'] as String?,
      translatePath: json['translatePath'] as String?,
      endpoints: endpoints,
    );
  }
}
