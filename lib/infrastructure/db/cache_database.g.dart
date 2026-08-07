// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_database.dart';

// ignore_for_file: type=lint
class $CacheEntriesTable extends CacheEntries
    with TableInfo<$CacheEntriesTable, CacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceHashMeta = const VerificationMeta(
    'sourceHash',
  );
  @override
  late final GeneratedColumn<String> sourceHash = GeneratedColumn<String>(
    'source_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceLangCodeMeta = const VerificationMeta(
    'sourceLangCode',
  );
  @override
  late final GeneratedColumn<String> sourceLangCode = GeneratedColumn<String>(
    'source_lang_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetLangCodeMeta = const VerificationMeta(
    'targetLangCode',
  );
  @override
  late final GeneratedColumn<String> targetLangCode = GeneratedColumn<String>(
    'target_lang_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _glossaryFingerprintMeta =
      const VerificationMeta('glossaryFingerprint');
  @override
  late final GeneratedColumn<String> glossaryFingerprint =
      GeneratedColumn<String>(
        'glossary_fingerprint',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _protectorVersionMeta = const VerificationMeta(
    'protectorVersion',
  );
  @override
  late final GeneratedColumn<String> protectorVersion = GeneratedColumn<String>(
    'protector_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _postProcessorVersionMeta =
      const VerificationMeta('postProcessorVersion');
  @override
  late final GeneratedColumn<String> postProcessorVersion =
      GeneratedColumn<String>(
        'post_processor_version',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _translationMeta = const VerificationMeta(
    'translation',
  );
  @override
  late final GeneratedColumn<String> translation = GeneratedColumn<String>(
    'translation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTextMeta = const VerificationMeta(
    'sourceText',
  );
  @override
  late final GeneratedColumn<String> sourceText = GeneratedColumn<String>(
    'source_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sourceHash,
    sourceLangCode,
    targetLangCode,
    providerId,
    modelId,
    glossaryFingerprint,
    protectorVersion,
    postProcessorVersion,
    kind,
    translation,
    sourceText,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_hash')) {
      context.handle(
        _sourceHashMeta,
        sourceHash.isAcceptableOrUnknown(data['source_hash']!, _sourceHashMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceHashMeta);
    }
    if (data.containsKey('source_lang_code')) {
      context.handle(
        _sourceLangCodeMeta,
        sourceLangCode.isAcceptableOrUnknown(
          data['source_lang_code']!,
          _sourceLangCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceLangCodeMeta);
    }
    if (data.containsKey('target_lang_code')) {
      context.handle(
        _targetLangCodeMeta,
        targetLangCode.isAcceptableOrUnknown(
          data['target_lang_code']!,
          _targetLangCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetLangCodeMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('glossary_fingerprint')) {
      context.handle(
        _glossaryFingerprintMeta,
        glossaryFingerprint.isAcceptableOrUnknown(
          data['glossary_fingerprint']!,
          _glossaryFingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_glossaryFingerprintMeta);
    }
    if (data.containsKey('protector_version')) {
      context.handle(
        _protectorVersionMeta,
        protectorVersion.isAcceptableOrUnknown(
          data['protector_version']!,
          _protectorVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_protectorVersionMeta);
    }
    if (data.containsKey('post_processor_version')) {
      context.handle(
        _postProcessorVersionMeta,
        postProcessorVersion.isAcceptableOrUnknown(
          data['post_processor_version']!,
          _postProcessorVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_postProcessorVersionMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('translation')) {
      context.handle(
        _translationMeta,
        translation.isAcceptableOrUnknown(
          data['translation']!,
          _translationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translationMeta);
    }
    if (data.containsKey('source_text')) {
      context.handle(
        _sourceTextMeta,
        sourceText.isAcceptableOrUnknown(data['source_text']!, _sourceTextMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTextMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    sourceHash,
    sourceLangCode,
    targetLangCode,
    providerId,
    modelId,
    glossaryFingerprint,
    protectorVersion,
    postProcessorVersion,
    kind,
  };
  @override
  CacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheEntry(
      sourceHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_hash'],
      )!,
      sourceLangCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_lang_code'],
      )!,
      targetLangCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_lang_code'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      glossaryFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}glossary_fingerprint'],
      )!,
      protectorVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}protector_version'],
      )!,
      postProcessorVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}post_processor_version'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      translation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation'],
      )!,
      sourceText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_text'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CacheEntriesTable createAlias(String alias) {
    return $CacheEntriesTable(attachedDatabase, alias);
  }
}

class CacheEntry extends DataClass implements Insertable<CacheEntry> {
  final String sourceHash;
  final String sourceLangCode;
  final String targetLangCode;
  final String providerId;
  final String modelId;
  final String glossaryFingerprint;
  final String protectorVersion;
  final String postProcessorVersion;

  /// [CacheKind] wire name.
  final String kind;
  final String translation;

  /// Debug only — never part of the lookup key.
  final String sourceText;
  final DateTime updatedAt;
  const CacheEntry({
    required this.sourceHash,
    required this.sourceLangCode,
    required this.targetLangCode,
    required this.providerId,
    required this.modelId,
    required this.glossaryFingerprint,
    required this.protectorVersion,
    required this.postProcessorVersion,
    required this.kind,
    required this.translation,
    required this.sourceText,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_hash'] = Variable<String>(sourceHash);
    map['source_lang_code'] = Variable<String>(sourceLangCode);
    map['target_lang_code'] = Variable<String>(targetLangCode);
    map['provider_id'] = Variable<String>(providerId);
    map['model_id'] = Variable<String>(modelId);
    map['glossary_fingerprint'] = Variable<String>(glossaryFingerprint);
    map['protector_version'] = Variable<String>(protectorVersion);
    map['post_processor_version'] = Variable<String>(postProcessorVersion);
    map['kind'] = Variable<String>(kind);
    map['translation'] = Variable<String>(translation);
    map['source_text'] = Variable<String>(sourceText);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return CacheEntriesCompanion(
      sourceHash: Value(sourceHash),
      sourceLangCode: Value(sourceLangCode),
      targetLangCode: Value(targetLangCode),
      providerId: Value(providerId),
      modelId: Value(modelId),
      glossaryFingerprint: Value(glossaryFingerprint),
      protectorVersion: Value(protectorVersion),
      postProcessorVersion: Value(postProcessorVersion),
      kind: Value(kind),
      translation: Value(translation),
      sourceText: Value(sourceText),
      updatedAt: Value(updatedAt),
    );
  }

  factory CacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheEntry(
      sourceHash: serializer.fromJson<String>(json['sourceHash']),
      sourceLangCode: serializer.fromJson<String>(json['sourceLangCode']),
      targetLangCode: serializer.fromJson<String>(json['targetLangCode']),
      providerId: serializer.fromJson<String>(json['providerId']),
      modelId: serializer.fromJson<String>(json['modelId']),
      glossaryFingerprint: serializer.fromJson<String>(
        json['glossaryFingerprint'],
      ),
      protectorVersion: serializer.fromJson<String>(json['protectorVersion']),
      postProcessorVersion: serializer.fromJson<String>(
        json['postProcessorVersion'],
      ),
      kind: serializer.fromJson<String>(json['kind']),
      translation: serializer.fromJson<String>(json['translation']),
      sourceText: serializer.fromJson<String>(json['sourceText']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceHash': serializer.toJson<String>(sourceHash),
      'sourceLangCode': serializer.toJson<String>(sourceLangCode),
      'targetLangCode': serializer.toJson<String>(targetLangCode),
      'providerId': serializer.toJson<String>(providerId),
      'modelId': serializer.toJson<String>(modelId),
      'glossaryFingerprint': serializer.toJson<String>(glossaryFingerprint),
      'protectorVersion': serializer.toJson<String>(protectorVersion),
      'postProcessorVersion': serializer.toJson<String>(postProcessorVersion),
      'kind': serializer.toJson<String>(kind),
      'translation': serializer.toJson<String>(translation),
      'sourceText': serializer.toJson<String>(sourceText),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CacheEntry copyWith({
    String? sourceHash,
    String? sourceLangCode,
    String? targetLangCode,
    String? providerId,
    String? modelId,
    String? glossaryFingerprint,
    String? protectorVersion,
    String? postProcessorVersion,
    String? kind,
    String? translation,
    String? sourceText,
    DateTime? updatedAt,
  }) => CacheEntry(
    sourceHash: sourceHash ?? this.sourceHash,
    sourceLangCode: sourceLangCode ?? this.sourceLangCode,
    targetLangCode: targetLangCode ?? this.targetLangCode,
    providerId: providerId ?? this.providerId,
    modelId: modelId ?? this.modelId,
    glossaryFingerprint: glossaryFingerprint ?? this.glossaryFingerprint,
    protectorVersion: protectorVersion ?? this.protectorVersion,
    postProcessorVersion: postProcessorVersion ?? this.postProcessorVersion,
    kind: kind ?? this.kind,
    translation: translation ?? this.translation,
    sourceText: sourceText ?? this.sourceText,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CacheEntry copyWithCompanion(CacheEntriesCompanion data) {
    return CacheEntry(
      sourceHash: data.sourceHash.present
          ? data.sourceHash.value
          : this.sourceHash,
      sourceLangCode: data.sourceLangCode.present
          ? data.sourceLangCode.value
          : this.sourceLangCode,
      targetLangCode: data.targetLangCode.present
          ? data.targetLangCode.value
          : this.targetLangCode,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      glossaryFingerprint: data.glossaryFingerprint.present
          ? data.glossaryFingerprint.value
          : this.glossaryFingerprint,
      protectorVersion: data.protectorVersion.present
          ? data.protectorVersion.value
          : this.protectorVersion,
      postProcessorVersion: data.postProcessorVersion.present
          ? data.postProcessorVersion.value
          : this.postProcessorVersion,
      kind: data.kind.present ? data.kind.value : this.kind,
      translation: data.translation.present
          ? data.translation.value
          : this.translation,
      sourceText: data.sourceText.present
          ? data.sourceText.value
          : this.sourceText,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheEntry(')
          ..write('sourceHash: $sourceHash, ')
          ..write('sourceLangCode: $sourceLangCode, ')
          ..write('targetLangCode: $targetLangCode, ')
          ..write('providerId: $providerId, ')
          ..write('modelId: $modelId, ')
          ..write('glossaryFingerprint: $glossaryFingerprint, ')
          ..write('protectorVersion: $protectorVersion, ')
          ..write('postProcessorVersion: $postProcessorVersion, ')
          ..write('kind: $kind, ')
          ..write('translation: $translation, ')
          ..write('sourceText: $sourceText, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sourceHash,
    sourceLangCode,
    targetLangCode,
    providerId,
    modelId,
    glossaryFingerprint,
    protectorVersion,
    postProcessorVersion,
    kind,
    translation,
    sourceText,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheEntry &&
          other.sourceHash == this.sourceHash &&
          other.sourceLangCode == this.sourceLangCode &&
          other.targetLangCode == this.targetLangCode &&
          other.providerId == this.providerId &&
          other.modelId == this.modelId &&
          other.glossaryFingerprint == this.glossaryFingerprint &&
          other.protectorVersion == this.protectorVersion &&
          other.postProcessorVersion == this.postProcessorVersion &&
          other.kind == this.kind &&
          other.translation == this.translation &&
          other.sourceText == this.sourceText &&
          other.updatedAt == this.updatedAt);
}

class CacheEntriesCompanion extends UpdateCompanion<CacheEntry> {
  final Value<String> sourceHash;
  final Value<String> sourceLangCode;
  final Value<String> targetLangCode;
  final Value<String> providerId;
  final Value<String> modelId;
  final Value<String> glossaryFingerprint;
  final Value<String> protectorVersion;
  final Value<String> postProcessorVersion;
  final Value<String> kind;
  final Value<String> translation;
  final Value<String> sourceText;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CacheEntriesCompanion({
    this.sourceHash = const Value.absent(),
    this.sourceLangCode = const Value.absent(),
    this.targetLangCode = const Value.absent(),
    this.providerId = const Value.absent(),
    this.modelId = const Value.absent(),
    this.glossaryFingerprint = const Value.absent(),
    this.protectorVersion = const Value.absent(),
    this.postProcessorVersion = const Value.absent(),
    this.kind = const Value.absent(),
    this.translation = const Value.absent(),
    this.sourceText = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheEntriesCompanion.insert({
    required String sourceHash,
    required String sourceLangCode,
    required String targetLangCode,
    required String providerId,
    required String modelId,
    required String glossaryFingerprint,
    required String protectorVersion,
    required String postProcessorVersion,
    required String kind,
    required String translation,
    required String sourceText,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : sourceHash = Value(sourceHash),
       sourceLangCode = Value(sourceLangCode),
       targetLangCode = Value(targetLangCode),
       providerId = Value(providerId),
       modelId = Value(modelId),
       glossaryFingerprint = Value(glossaryFingerprint),
       protectorVersion = Value(protectorVersion),
       postProcessorVersion = Value(postProcessorVersion),
       kind = Value(kind),
       translation = Value(translation),
       sourceText = Value(sourceText),
       updatedAt = Value(updatedAt);
  static Insertable<CacheEntry> custom({
    Expression<String>? sourceHash,
    Expression<String>? sourceLangCode,
    Expression<String>? targetLangCode,
    Expression<String>? providerId,
    Expression<String>? modelId,
    Expression<String>? glossaryFingerprint,
    Expression<String>? protectorVersion,
    Expression<String>? postProcessorVersion,
    Expression<String>? kind,
    Expression<String>? translation,
    Expression<String>? sourceText,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceHash != null) 'source_hash': sourceHash,
      if (sourceLangCode != null) 'source_lang_code': sourceLangCode,
      if (targetLangCode != null) 'target_lang_code': targetLangCode,
      if (providerId != null) 'provider_id': providerId,
      if (modelId != null) 'model_id': modelId,
      if (glossaryFingerprint != null)
        'glossary_fingerprint': glossaryFingerprint,
      if (protectorVersion != null) 'protector_version': protectorVersion,
      if (postProcessorVersion != null)
        'post_processor_version': postProcessorVersion,
      if (kind != null) 'kind': kind,
      if (translation != null) 'translation': translation,
      if (sourceText != null) 'source_text': sourceText,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CacheEntriesCompanion copyWith({
    Value<String>? sourceHash,
    Value<String>? sourceLangCode,
    Value<String>? targetLangCode,
    Value<String>? providerId,
    Value<String>? modelId,
    Value<String>? glossaryFingerprint,
    Value<String>? protectorVersion,
    Value<String>? postProcessorVersion,
    Value<String>? kind,
    Value<String>? translation,
    Value<String>? sourceText,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CacheEntriesCompanion(
      sourceHash: sourceHash ?? this.sourceHash,
      sourceLangCode: sourceLangCode ?? this.sourceLangCode,
      targetLangCode: targetLangCode ?? this.targetLangCode,
      providerId: providerId ?? this.providerId,
      modelId: modelId ?? this.modelId,
      glossaryFingerprint: glossaryFingerprint ?? this.glossaryFingerprint,
      protectorVersion: protectorVersion ?? this.protectorVersion,
      postProcessorVersion: postProcessorVersion ?? this.postProcessorVersion,
      kind: kind ?? this.kind,
      translation: translation ?? this.translation,
      sourceText: sourceText ?? this.sourceText,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceHash.present) {
      map['source_hash'] = Variable<String>(sourceHash.value);
    }
    if (sourceLangCode.present) {
      map['source_lang_code'] = Variable<String>(sourceLangCode.value);
    }
    if (targetLangCode.present) {
      map['target_lang_code'] = Variable<String>(targetLangCode.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (glossaryFingerprint.present) {
      map['glossary_fingerprint'] = Variable<String>(glossaryFingerprint.value);
    }
    if (protectorVersion.present) {
      map['protector_version'] = Variable<String>(protectorVersion.value);
    }
    if (postProcessorVersion.present) {
      map['post_processor_version'] = Variable<String>(
        postProcessorVersion.value,
      );
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (translation.present) {
      map['translation'] = Variable<String>(translation.value);
    }
    if (sourceText.present) {
      map['source_text'] = Variable<String>(sourceText.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheEntriesCompanion(')
          ..write('sourceHash: $sourceHash, ')
          ..write('sourceLangCode: $sourceLangCode, ')
          ..write('targetLangCode: $targetLangCode, ')
          ..write('providerId: $providerId, ')
          ..write('modelId: $modelId, ')
          ..write('glossaryFingerprint: $glossaryFingerprint, ')
          ..write('protectorVersion: $protectorVersion, ')
          ..write('postProcessorVersion: $postProcessorVersion, ')
          ..write('kind: $kind, ')
          ..write('translation: $translation, ')
          ..write('sourceText: $sourceText, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$CacheDatabase extends GeneratedDatabase {
  _$CacheDatabase(QueryExecutor e) : super(e);
  $CacheDatabaseManager get managers => $CacheDatabaseManager(this);
  late final $CacheEntriesTable cacheEntries = $CacheEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [cacheEntries];
}

typedef $$CacheEntriesTableCreateCompanionBuilder =
    CacheEntriesCompanion Function({
      required String sourceHash,
      required String sourceLangCode,
      required String targetLangCode,
      required String providerId,
      required String modelId,
      required String glossaryFingerprint,
      required String protectorVersion,
      required String postProcessorVersion,
      required String kind,
      required String translation,
      required String sourceText,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CacheEntriesTableUpdateCompanionBuilder =
    CacheEntriesCompanion Function({
      Value<String> sourceHash,
      Value<String> sourceLangCode,
      Value<String> targetLangCode,
      Value<String> providerId,
      Value<String> modelId,
      Value<String> glossaryFingerprint,
      Value<String> protectorVersion,
      Value<String> postProcessorVersion,
      Value<String> kind,
      Value<String> translation,
      Value<String> sourceText,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CacheEntriesTableFilterComposer
    extends Composer<_$CacheDatabase, $CacheEntriesTable> {
  $$CacheEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceHash => $composableBuilder(
    column: $table.sourceHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceLangCode => $composableBuilder(
    column: $table.sourceLangCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetLangCode => $composableBuilder(
    column: $table.targetLangCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get glossaryFingerprint => $composableBuilder(
    column: $table.glossaryFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get protectorVersion => $composableBuilder(
    column: $table.protectorVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postProcessorVersion => $composableBuilder(
    column: $table.postProcessorVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceText => $composableBuilder(
    column: $table.sourceText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CacheEntriesTableOrderingComposer
    extends Composer<_$CacheDatabase, $CacheEntriesTable> {
  $$CacheEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceHash => $composableBuilder(
    column: $table.sourceHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceLangCode => $composableBuilder(
    column: $table.sourceLangCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetLangCode => $composableBuilder(
    column: $table.targetLangCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get glossaryFingerprint => $composableBuilder(
    column: $table.glossaryFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get protectorVersion => $composableBuilder(
    column: $table.protectorVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postProcessorVersion => $composableBuilder(
    column: $table.postProcessorVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceText => $composableBuilder(
    column: $table.sourceText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CacheEntriesTableAnnotationComposer
    extends Composer<_$CacheDatabase, $CacheEntriesTable> {
  $$CacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceHash => $composableBuilder(
    column: $table.sourceHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceLangCode => $composableBuilder(
    column: $table.sourceLangCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetLangCode => $composableBuilder(
    column: $table.targetLangCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<String> get glossaryFingerprint => $composableBuilder(
    column: $table.glossaryFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get protectorVersion => $composableBuilder(
    column: $table.protectorVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get postProcessorVersion => $composableBuilder(
    column: $table.postProcessorVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceText => $composableBuilder(
    column: $table.sourceText,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CacheEntriesTableTableManager
    extends
        RootTableManager<
          _$CacheDatabase,
          $CacheEntriesTable,
          CacheEntry,
          $$CacheEntriesTableFilterComposer,
          $$CacheEntriesTableOrderingComposer,
          $$CacheEntriesTableAnnotationComposer,
          $$CacheEntriesTableCreateCompanionBuilder,
          $$CacheEntriesTableUpdateCompanionBuilder,
          (
            CacheEntry,
            BaseReferences<_$CacheDatabase, $CacheEntriesTable, CacheEntry>,
          ),
          CacheEntry,
          PrefetchHooks Function()
        > {
  $$CacheEntriesTableTableManager(_$CacheDatabase db, $CacheEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CacheEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceHash = const Value.absent(),
                Value<String> sourceLangCode = const Value.absent(),
                Value<String> targetLangCode = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> modelId = const Value.absent(),
                Value<String> glossaryFingerprint = const Value.absent(),
                Value<String> protectorVersion = const Value.absent(),
                Value<String> postProcessorVersion = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> translation = const Value.absent(),
                Value<String> sourceText = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheEntriesCompanion(
                sourceHash: sourceHash,
                sourceLangCode: sourceLangCode,
                targetLangCode: targetLangCode,
                providerId: providerId,
                modelId: modelId,
                glossaryFingerprint: glossaryFingerprint,
                protectorVersion: protectorVersion,
                postProcessorVersion: postProcessorVersion,
                kind: kind,
                translation: translation,
                sourceText: sourceText,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceHash,
                required String sourceLangCode,
                required String targetLangCode,
                required String providerId,
                required String modelId,
                required String glossaryFingerprint,
                required String protectorVersion,
                required String postProcessorVersion,
                required String kind,
                required String translation,
                required String sourceText,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CacheEntriesCompanion.insert(
                sourceHash: sourceHash,
                sourceLangCode: sourceLangCode,
                targetLangCode: targetLangCode,
                providerId: providerId,
                modelId: modelId,
                glossaryFingerprint: glossaryFingerprint,
                protectorVersion: protectorVersion,
                postProcessorVersion: postProcessorVersion,
                kind: kind,
                translation: translation,
                sourceText: sourceText,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CacheEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$CacheDatabase,
      $CacheEntriesTable,
      CacheEntry,
      $$CacheEntriesTableFilterComposer,
      $$CacheEntriesTableOrderingComposer,
      $$CacheEntriesTableAnnotationComposer,
      $$CacheEntriesTableCreateCompanionBuilder,
      $$CacheEntriesTableUpdateCompanionBuilder,
      (
        CacheEntry,
        BaseReferences<_$CacheDatabase, $CacheEntriesTable, CacheEntry>,
      ),
      CacheEntry,
      PrefetchHooks Function()
    >;

class $CacheDatabaseManager {
  final _$CacheDatabase _db;
  $CacheDatabaseManager(this._db);
  $$CacheEntriesTableTableManager get cacheEntries =>
      $$CacheEntriesTableTableManager(_db, _db.cacheEntries);
}
