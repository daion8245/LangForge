// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProjectMetaTable extends ProjectMeta
    with TableInfo<$ProjectMetaTable, ProjectMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<String> schemaVersion = GeneratedColumn<String>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appVersionMeta = const VerificationMeta(
    'appVersion',
  );
  @override
  late final GeneratedColumn<String> appVersion = GeneratedColumn<String>(
    'app_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
  static const VerificationMeta _sourceLangCodeMeta = const VerificationMeta(
    'sourceLangCode',
  );
  @override
  late final GeneratedColumn<String> sourceLangCode = GeneratedColumn<String>(
    'source_lang_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en_us'),
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
    requiredDuringInsert: false,
    defaultValue: const Constant('ko_kr'),
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outputFormatMeta = const VerificationMeta(
    'outputFormat',
  );
  @override
  late final GeneratedColumn<String> outputFormat = GeneratedColumn<String>(
    'output_format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pack_zip'),
  );
  static const VerificationMeta _mcVersionMeta = const VerificationMeta(
    'mcVersion',
  );
  @override
  late final GeneratedColumn<String> mcVersion = GeneratedColumn<String>(
    'mc_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('1.20.1'),
  );
  static const VerificationMeta _packIconModeMeta = const VerificationMeta(
    'packIconMode',
  );
  @override
  late final GeneratedColumn<String> packIconMode = GeneratedColumn<String>(
    'pack_icon_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('default'),
  );
  static const VerificationMeta _packIconPathMeta = const VerificationMeta(
    'packIconPath',
  );
  @override
  late final GeneratedColumn<String> packIconPath = GeneratedColumn<String>(
    'pack_icon_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _togglesJsonMeta = const VerificationMeta(
    'togglesJson',
  );
  @override
  late final GeneratedColumn<String> togglesJson = GeneratedColumn<String>(
    'toggles_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    schemaVersion,
    appVersion,
    createdAt,
    updatedAt,
    sourceLangCode,
    targetLangCode,
    providerId,
    modelId,
    outputFormat,
    mcVersion,
    packIconMode,
    packIconPath,
    togglesJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('app_version')) {
      context.handle(
        _appVersionMeta,
        appVersion.isAcceptableOrUnknown(data['app_version']!, _appVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_appVersionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('source_lang_code')) {
      context.handle(
        _sourceLangCodeMeta,
        sourceLangCode.isAcceptableOrUnknown(
          data['source_lang_code']!,
          _sourceLangCodeMeta,
        ),
      );
    }
    if (data.containsKey('target_lang_code')) {
      context.handle(
        _targetLangCodeMeta,
        targetLangCode.isAcceptableOrUnknown(
          data['target_lang_code']!,
          _targetLangCodeMeta,
        ),
      );
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    }
    if (data.containsKey('output_format')) {
      context.handle(
        _outputFormatMeta,
        outputFormat.isAcceptableOrUnknown(
          data['output_format']!,
          _outputFormatMeta,
        ),
      );
    }
    if (data.containsKey('mc_version')) {
      context.handle(
        _mcVersionMeta,
        mcVersion.isAcceptableOrUnknown(data['mc_version']!, _mcVersionMeta),
      );
    }
    if (data.containsKey('pack_icon_mode')) {
      context.handle(
        _packIconModeMeta,
        packIconMode.isAcceptableOrUnknown(
          data['pack_icon_mode']!,
          _packIconModeMeta,
        ),
      );
    }
    if (data.containsKey('pack_icon_path')) {
      context.handle(
        _packIconPathMeta,
        packIconPath.isAcceptableOrUnknown(
          data['pack_icon_path']!,
          _packIconPathMeta,
        ),
      );
    }
    if (data.containsKey('toggles_json')) {
      context.handle(
        _togglesJsonMeta,
        togglesJson.isAcceptableOrUnknown(
          data['toggles_json']!,
          _togglesJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectMetaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schema_version'],
      )!,
      appVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_version'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
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
      ),
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      ),
      outputFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}output_format'],
      )!,
      mcVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mc_version'],
      )!,
      packIconMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_icon_mode'],
      )!,
      packIconPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_icon_path'],
      ),
      togglesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}toggles_json'],
      )!,
    );
  }

  @override
  $ProjectMetaTable createAlias(String alias) {
    return $ProjectMetaTable(attachedDatabase, alias);
  }
}

class ProjectMetaData extends DataClass implements Insertable<ProjectMetaData> {
  final int id;
  final String name;
  final String schemaVersion;
  final String appVersion;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String sourceLangCode;
  final String targetLangCode;
  final String? providerId;
  final String? modelId;
  final String outputFormat;
  final String mcVersion;
  final String packIconMode;
  final String? packIconPath;
  final String togglesJson;
  const ProjectMetaData({
    required this.id,
    required this.name,
    required this.schemaVersion,
    required this.appVersion,
    required this.createdAt,
    required this.updatedAt,
    required this.sourceLangCode,
    required this.targetLangCode,
    this.providerId,
    this.modelId,
    required this.outputFormat,
    required this.mcVersion,
    required this.packIconMode,
    this.packIconPath,
    required this.togglesJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['schema_version'] = Variable<String>(schemaVersion);
    map['app_version'] = Variable<String>(appVersion);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['source_lang_code'] = Variable<String>(sourceLangCode);
    map['target_lang_code'] = Variable<String>(targetLangCode);
    if (!nullToAbsent || providerId != null) {
      map['provider_id'] = Variable<String>(providerId);
    }
    if (!nullToAbsent || modelId != null) {
      map['model_id'] = Variable<String>(modelId);
    }
    map['output_format'] = Variable<String>(outputFormat);
    map['mc_version'] = Variable<String>(mcVersion);
    map['pack_icon_mode'] = Variable<String>(packIconMode);
    if (!nullToAbsent || packIconPath != null) {
      map['pack_icon_path'] = Variable<String>(packIconPath);
    }
    map['toggles_json'] = Variable<String>(togglesJson);
    return map;
  }

  ProjectMetaCompanion toCompanion(bool nullToAbsent) {
    return ProjectMetaCompanion(
      id: Value(id),
      name: Value(name),
      schemaVersion: Value(schemaVersion),
      appVersion: Value(appVersion),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      sourceLangCode: Value(sourceLangCode),
      targetLangCode: Value(targetLangCode),
      providerId: providerId == null && nullToAbsent
          ? const Value.absent()
          : Value(providerId),
      modelId: modelId == null && nullToAbsent
          ? const Value.absent()
          : Value(modelId),
      outputFormat: Value(outputFormat),
      mcVersion: Value(mcVersion),
      packIconMode: Value(packIconMode),
      packIconPath: packIconPath == null && nullToAbsent
          ? const Value.absent()
          : Value(packIconPath),
      togglesJson: Value(togglesJson),
    );
  }

  factory ProjectMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectMetaData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      schemaVersion: serializer.fromJson<String>(json['schemaVersion']),
      appVersion: serializer.fromJson<String>(json['appVersion']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      sourceLangCode: serializer.fromJson<String>(json['sourceLangCode']),
      targetLangCode: serializer.fromJson<String>(json['targetLangCode']),
      providerId: serializer.fromJson<String?>(json['providerId']),
      modelId: serializer.fromJson<String?>(json['modelId']),
      outputFormat: serializer.fromJson<String>(json['outputFormat']),
      mcVersion: serializer.fromJson<String>(json['mcVersion']),
      packIconMode: serializer.fromJson<String>(json['packIconMode']),
      packIconPath: serializer.fromJson<String?>(json['packIconPath']),
      togglesJson: serializer.fromJson<String>(json['togglesJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'schemaVersion': serializer.toJson<String>(schemaVersion),
      'appVersion': serializer.toJson<String>(appVersion),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'sourceLangCode': serializer.toJson<String>(sourceLangCode),
      'targetLangCode': serializer.toJson<String>(targetLangCode),
      'providerId': serializer.toJson<String?>(providerId),
      'modelId': serializer.toJson<String?>(modelId),
      'outputFormat': serializer.toJson<String>(outputFormat),
      'mcVersion': serializer.toJson<String>(mcVersion),
      'packIconMode': serializer.toJson<String>(packIconMode),
      'packIconPath': serializer.toJson<String?>(packIconPath),
      'togglesJson': serializer.toJson<String>(togglesJson),
    };
  }

  ProjectMetaData copyWith({
    int? id,
    String? name,
    String? schemaVersion,
    String? appVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sourceLangCode,
    String? targetLangCode,
    Value<String?> providerId = const Value.absent(),
    Value<String?> modelId = const Value.absent(),
    String? outputFormat,
    String? mcVersion,
    String? packIconMode,
    Value<String?> packIconPath = const Value.absent(),
    String? togglesJson,
  }) => ProjectMetaData(
    id: id ?? this.id,
    name: name ?? this.name,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    appVersion: appVersion ?? this.appVersion,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    sourceLangCode: sourceLangCode ?? this.sourceLangCode,
    targetLangCode: targetLangCode ?? this.targetLangCode,
    providerId: providerId.present ? providerId.value : this.providerId,
    modelId: modelId.present ? modelId.value : this.modelId,
    outputFormat: outputFormat ?? this.outputFormat,
    mcVersion: mcVersion ?? this.mcVersion,
    packIconMode: packIconMode ?? this.packIconMode,
    packIconPath: packIconPath.present ? packIconPath.value : this.packIconPath,
    togglesJson: togglesJson ?? this.togglesJson,
  );
  ProjectMetaData copyWithCompanion(ProjectMetaCompanion data) {
    return ProjectMetaData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      appVersion: data.appVersion.present
          ? data.appVersion.value
          : this.appVersion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
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
      outputFormat: data.outputFormat.present
          ? data.outputFormat.value
          : this.outputFormat,
      mcVersion: data.mcVersion.present ? data.mcVersion.value : this.mcVersion,
      packIconMode: data.packIconMode.present
          ? data.packIconMode.value
          : this.packIconMode,
      packIconPath: data.packIconPath.present
          ? data.packIconPath.value
          : this.packIconPath,
      togglesJson: data.togglesJson.present
          ? data.togglesJson.value
          : this.togglesJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectMetaData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('appVersion: $appVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sourceLangCode: $sourceLangCode, ')
          ..write('targetLangCode: $targetLangCode, ')
          ..write('providerId: $providerId, ')
          ..write('modelId: $modelId, ')
          ..write('outputFormat: $outputFormat, ')
          ..write('mcVersion: $mcVersion, ')
          ..write('packIconMode: $packIconMode, ')
          ..write('packIconPath: $packIconPath, ')
          ..write('togglesJson: $togglesJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    schemaVersion,
    appVersion,
    createdAt,
    updatedAt,
    sourceLangCode,
    targetLangCode,
    providerId,
    modelId,
    outputFormat,
    mcVersion,
    packIconMode,
    packIconPath,
    togglesJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectMetaData &&
          other.id == this.id &&
          other.name == this.name &&
          other.schemaVersion == this.schemaVersion &&
          other.appVersion == this.appVersion &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.sourceLangCode == this.sourceLangCode &&
          other.targetLangCode == this.targetLangCode &&
          other.providerId == this.providerId &&
          other.modelId == this.modelId &&
          other.outputFormat == this.outputFormat &&
          other.mcVersion == this.mcVersion &&
          other.packIconMode == this.packIconMode &&
          other.packIconPath == this.packIconPath &&
          other.togglesJson == this.togglesJson);
}

class ProjectMetaCompanion extends UpdateCompanion<ProjectMetaData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> schemaVersion;
  final Value<String> appVersion;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> sourceLangCode;
  final Value<String> targetLangCode;
  final Value<String?> providerId;
  final Value<String?> modelId;
  final Value<String> outputFormat;
  final Value<String> mcVersion;
  final Value<String> packIconMode;
  final Value<String?> packIconPath;
  final Value<String> togglesJson;
  const ProjectMetaCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.sourceLangCode = const Value.absent(),
    this.targetLangCode = const Value.absent(),
    this.providerId = const Value.absent(),
    this.modelId = const Value.absent(),
    this.outputFormat = const Value.absent(),
    this.mcVersion = const Value.absent(),
    this.packIconMode = const Value.absent(),
    this.packIconPath = const Value.absent(),
    this.togglesJson = const Value.absent(),
  });
  ProjectMetaCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String schemaVersion,
    required String appVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.sourceLangCode = const Value.absent(),
    this.targetLangCode = const Value.absent(),
    this.providerId = const Value.absent(),
    this.modelId = const Value.absent(),
    this.outputFormat = const Value.absent(),
    this.mcVersion = const Value.absent(),
    this.packIconMode = const Value.absent(),
    this.packIconPath = const Value.absent(),
    this.togglesJson = const Value.absent(),
  }) : name = Value(name),
       schemaVersion = Value(schemaVersion),
       appVersion = Value(appVersion),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ProjectMetaData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? schemaVersion,
    Expression<String>? appVersion,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? sourceLangCode,
    Expression<String>? targetLangCode,
    Expression<String>? providerId,
    Expression<String>? modelId,
    Expression<String>? outputFormat,
    Expression<String>? mcVersion,
    Expression<String>? packIconMode,
    Expression<String>? packIconPath,
    Expression<String>? togglesJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (appVersion != null) 'app_version': appVersion,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (sourceLangCode != null) 'source_lang_code': sourceLangCode,
      if (targetLangCode != null) 'target_lang_code': targetLangCode,
      if (providerId != null) 'provider_id': providerId,
      if (modelId != null) 'model_id': modelId,
      if (outputFormat != null) 'output_format': outputFormat,
      if (mcVersion != null) 'mc_version': mcVersion,
      if (packIconMode != null) 'pack_icon_mode': packIconMode,
      if (packIconPath != null) 'pack_icon_path': packIconPath,
      if (togglesJson != null) 'toggles_json': togglesJson,
    });
  }

  ProjectMetaCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? schemaVersion,
    Value<String>? appVersion,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? sourceLangCode,
    Value<String>? targetLangCode,
    Value<String?>? providerId,
    Value<String?>? modelId,
    Value<String>? outputFormat,
    Value<String>? mcVersion,
    Value<String>? packIconMode,
    Value<String?>? packIconPath,
    Value<String>? togglesJson,
  }) {
    return ProjectMetaCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      appVersion: appVersion ?? this.appVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sourceLangCode: sourceLangCode ?? this.sourceLangCode,
      targetLangCode: targetLangCode ?? this.targetLangCode,
      providerId: providerId ?? this.providerId,
      modelId: modelId ?? this.modelId,
      outputFormat: outputFormat ?? this.outputFormat,
      mcVersion: mcVersion ?? this.mcVersion,
      packIconMode: packIconMode ?? this.packIconMode,
      packIconPath: packIconPath ?? this.packIconPath,
      togglesJson: togglesJson ?? this.togglesJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<String>(schemaVersion.value);
    }
    if (appVersion.present) {
      map['app_version'] = Variable<String>(appVersion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
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
    if (outputFormat.present) {
      map['output_format'] = Variable<String>(outputFormat.value);
    }
    if (mcVersion.present) {
      map['mc_version'] = Variable<String>(mcVersion.value);
    }
    if (packIconMode.present) {
      map['pack_icon_mode'] = Variable<String>(packIconMode.value);
    }
    if (packIconPath.present) {
      map['pack_icon_path'] = Variable<String>(packIconPath.value);
    }
    if (togglesJson.present) {
      map['toggles_json'] = Variable<String>(togglesJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectMetaCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('appVersion: $appVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sourceLangCode: $sourceLangCode, ')
          ..write('targetLangCode: $targetLangCode, ')
          ..write('providerId: $providerId, ')
          ..write('modelId: $modelId, ')
          ..write('outputFormat: $outputFormat, ')
          ..write('mcVersion: $mcVersion, ')
          ..write('packIconMode: $packIconMode, ')
          ..write('packIconPath: $packIconPath, ')
          ..write('togglesJson: $togglesJson')
          ..write(')'))
        .toString();
  }
}

class $InputFilesTable extends InputFiles
    with TableInfo<$InputFilesTable, InputFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InputFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalNameMeta = const VerificationMeta(
    'originalName',
  );
  @override
  late final GeneratedColumn<String> originalName = GeneratedColumn<String>(
    'original_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _absolutePathMeta = const VerificationMeta(
    'absolutePath',
  );
  @override
  late final GeneratedColumn<String> absolutePath = GeneratedColumn<String>(
    'absolute_path',
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
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _scanStateMeta = const VerificationMeta(
    'scanState',
  );
  @override
  late final GeneratedColumn<String> scanState = GeneratedColumn<String>(
    'scan_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rejectReasonMeta = const VerificationMeta(
    'rejectReason',
  );
  @override
  late final GeneratedColumn<String> rejectReason = GeneratedColumn<String>(
    'reject_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    originalName,
    absolutePath,
    kind,
    sizeBytes,
    sha256,
    addedAt,
    enabled,
    scanState,
    rejectReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'input_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<InputFile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('original_name')) {
      context.handle(
        _originalNameMeta,
        originalName.isAcceptableOrUnknown(
          data['original_name']!,
          _originalNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalNameMeta);
    }
    if (data.containsKey('absolute_path')) {
      context.handle(
        _absolutePathMeta,
        absolutePath.isAcceptableOrUnknown(
          data['absolute_path']!,
          _absolutePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_absolutePathMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('scan_state')) {
      context.handle(
        _scanStateMeta,
        scanState.isAcceptableOrUnknown(data['scan_state']!, _scanStateMeta),
      );
    } else if (isInserting) {
      context.missing(_scanStateMeta);
    }
    if (data.containsKey('reject_reason')) {
      context.handle(
        _rejectReasonMeta,
        rejectReason.isAcceptableOrUnknown(
          data['reject_reason']!,
          _rejectReasonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InputFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InputFile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      originalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_name'],
      )!,
      absolutePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}absolute_path'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      scanState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scan_state'],
      )!,
      rejectReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reject_reason'],
      ),
    );
  }

  @override
  $InputFilesTable createAlias(String alias) {
    return $InputFilesTable(attachedDatabase, alias);
  }
}

class InputFile extends DataClass implements Insertable<InputFile> {
  final String id;
  final String originalName;
  final String absolutePath;
  final String kind;
  final int sizeBytes;
  final String sha256;
  final DateTime addedAt;
  final bool enabled;
  final String scanState;
  final String? rejectReason;
  const InputFile({
    required this.id,
    required this.originalName,
    required this.absolutePath,
    required this.kind,
    required this.sizeBytes,
    required this.sha256,
    required this.addedAt,
    required this.enabled,
    required this.scanState,
    this.rejectReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['original_name'] = Variable<String>(originalName);
    map['absolute_path'] = Variable<String>(absolutePath);
    map['kind'] = Variable<String>(kind);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['sha256'] = Variable<String>(sha256);
    map['added_at'] = Variable<DateTime>(addedAt);
    map['enabled'] = Variable<bool>(enabled);
    map['scan_state'] = Variable<String>(scanState);
    if (!nullToAbsent || rejectReason != null) {
      map['reject_reason'] = Variable<String>(rejectReason);
    }
    return map;
  }

  InputFilesCompanion toCompanion(bool nullToAbsent) {
    return InputFilesCompanion(
      id: Value(id),
      originalName: Value(originalName),
      absolutePath: Value(absolutePath),
      kind: Value(kind),
      sizeBytes: Value(sizeBytes),
      sha256: Value(sha256),
      addedAt: Value(addedAt),
      enabled: Value(enabled),
      scanState: Value(scanState),
      rejectReason: rejectReason == null && nullToAbsent
          ? const Value.absent()
          : Value(rejectReason),
    );
  }

  factory InputFile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InputFile(
      id: serializer.fromJson<String>(json['id']),
      originalName: serializer.fromJson<String>(json['originalName']),
      absolutePath: serializer.fromJson<String>(json['absolutePath']),
      kind: serializer.fromJson<String>(json['kind']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      sha256: serializer.fromJson<String>(json['sha256']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      scanState: serializer.fromJson<String>(json['scanState']),
      rejectReason: serializer.fromJson<String?>(json['rejectReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'originalName': serializer.toJson<String>(originalName),
      'absolutePath': serializer.toJson<String>(absolutePath),
      'kind': serializer.toJson<String>(kind),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'sha256': serializer.toJson<String>(sha256),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'enabled': serializer.toJson<bool>(enabled),
      'scanState': serializer.toJson<String>(scanState),
      'rejectReason': serializer.toJson<String?>(rejectReason),
    };
  }

  InputFile copyWith({
    String? id,
    String? originalName,
    String? absolutePath,
    String? kind,
    int? sizeBytes,
    String? sha256,
    DateTime? addedAt,
    bool? enabled,
    String? scanState,
    Value<String?> rejectReason = const Value.absent(),
  }) => InputFile(
    id: id ?? this.id,
    originalName: originalName ?? this.originalName,
    absolutePath: absolutePath ?? this.absolutePath,
    kind: kind ?? this.kind,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    sha256: sha256 ?? this.sha256,
    addedAt: addedAt ?? this.addedAt,
    enabled: enabled ?? this.enabled,
    scanState: scanState ?? this.scanState,
    rejectReason: rejectReason.present ? rejectReason.value : this.rejectReason,
  );
  InputFile copyWithCompanion(InputFilesCompanion data) {
    return InputFile(
      id: data.id.present ? data.id.value : this.id,
      originalName: data.originalName.present
          ? data.originalName.value
          : this.originalName,
      absolutePath: data.absolutePath.present
          ? data.absolutePath.value
          : this.absolutePath,
      kind: data.kind.present ? data.kind.value : this.kind,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      scanState: data.scanState.present ? data.scanState.value : this.scanState,
      rejectReason: data.rejectReason.present
          ? data.rejectReason.value
          : this.rejectReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InputFile(')
          ..write('id: $id, ')
          ..write('originalName: $originalName, ')
          ..write('absolutePath: $absolutePath, ')
          ..write('kind: $kind, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('sha256: $sha256, ')
          ..write('addedAt: $addedAt, ')
          ..write('enabled: $enabled, ')
          ..write('scanState: $scanState, ')
          ..write('rejectReason: $rejectReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    originalName,
    absolutePath,
    kind,
    sizeBytes,
    sha256,
    addedAt,
    enabled,
    scanState,
    rejectReason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InputFile &&
          other.id == this.id &&
          other.originalName == this.originalName &&
          other.absolutePath == this.absolutePath &&
          other.kind == this.kind &&
          other.sizeBytes == this.sizeBytes &&
          other.sha256 == this.sha256 &&
          other.addedAt == this.addedAt &&
          other.enabled == this.enabled &&
          other.scanState == this.scanState &&
          other.rejectReason == this.rejectReason);
}

class InputFilesCompanion extends UpdateCompanion<InputFile> {
  final Value<String> id;
  final Value<String> originalName;
  final Value<String> absolutePath;
  final Value<String> kind;
  final Value<int> sizeBytes;
  final Value<String> sha256;
  final Value<DateTime> addedAt;
  final Value<bool> enabled;
  final Value<String> scanState;
  final Value<String?> rejectReason;
  final Value<int> rowid;
  const InputFilesCompanion({
    this.id = const Value.absent(),
    this.originalName = const Value.absent(),
    this.absolutePath = const Value.absent(),
    this.kind = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.enabled = const Value.absent(),
    this.scanState = const Value.absent(),
    this.rejectReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InputFilesCompanion.insert({
    required String id,
    required String originalName,
    required String absolutePath,
    required String kind,
    required int sizeBytes,
    required String sha256,
    required DateTime addedAt,
    this.enabled = const Value.absent(),
    required String scanState,
    this.rejectReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       originalName = Value(originalName),
       absolutePath = Value(absolutePath),
       kind = Value(kind),
       sizeBytes = Value(sizeBytes),
       sha256 = Value(sha256),
       addedAt = Value(addedAt),
       scanState = Value(scanState);
  static Insertable<InputFile> custom({
    Expression<String>? id,
    Expression<String>? originalName,
    Expression<String>? absolutePath,
    Expression<String>? kind,
    Expression<int>? sizeBytes,
    Expression<String>? sha256,
    Expression<DateTime>? addedAt,
    Expression<bool>? enabled,
    Expression<String>? scanState,
    Expression<String>? rejectReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (originalName != null) 'original_name': originalName,
      if (absolutePath != null) 'absolute_path': absolutePath,
      if (kind != null) 'kind': kind,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (sha256 != null) 'sha256': sha256,
      if (addedAt != null) 'added_at': addedAt,
      if (enabled != null) 'enabled': enabled,
      if (scanState != null) 'scan_state': scanState,
      if (rejectReason != null) 'reject_reason': rejectReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InputFilesCompanion copyWith({
    Value<String>? id,
    Value<String>? originalName,
    Value<String>? absolutePath,
    Value<String>? kind,
    Value<int>? sizeBytes,
    Value<String>? sha256,
    Value<DateTime>? addedAt,
    Value<bool>? enabled,
    Value<String>? scanState,
    Value<String?>? rejectReason,
    Value<int>? rowid,
  }) {
    return InputFilesCompanion(
      id: id ?? this.id,
      originalName: originalName ?? this.originalName,
      absolutePath: absolutePath ?? this.absolutePath,
      kind: kind ?? this.kind,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      sha256: sha256 ?? this.sha256,
      addedAt: addedAt ?? this.addedAt,
      enabled: enabled ?? this.enabled,
      scanState: scanState ?? this.scanState,
      rejectReason: rejectReason ?? this.rejectReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (originalName.present) {
      map['original_name'] = Variable<String>(originalName.value);
    }
    if (absolutePath.present) {
      map['absolute_path'] = Variable<String>(absolutePath.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (scanState.present) {
      map['scan_state'] = Variable<String>(scanState.value);
    }
    if (rejectReason.present) {
      map['reject_reason'] = Variable<String>(rejectReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InputFilesCompanion(')
          ..write('id: $id, ')
          ..write('originalName: $originalName, ')
          ..write('absolutePath: $absolutePath, ')
          ..write('kind: $kind, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('sha256: $sha256, ')
          ..write('addedAt: $addedAt, ')
          ..write('enabled: $enabled, ')
          ..write('scanState: $scanState, ')
          ..write('rejectReason: $rejectReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NamespacesTable extends Namespaces
    with TableInfo<$NamespacesTable, Namespace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NamespacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inputFileIdMeta = const VerificationMeta(
    'inputFileId',
  );
  @override
  late final GeneratedColumn<String> inputFileId = GeneratedColumn<String>(
    'input_file_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES input_files (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceOverrideMeta = const VerificationMeta(
    'sourceOverride',
  );
  @override
  late final GeneratedColumn<String> sourceOverride = GeneratedColumn<String>(
    'source_override',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _excludedMeta = const VerificationMeta(
    'excluded',
  );
  @override
  late final GeneratedColumn<bool> excluded = GeneratedColumn<bool>(
    'excluded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("excluded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _selectedMeta = const VerificationMeta(
    'selected',
  );
  @override
  late final GeneratedColumn<bool> selected = GeneratedColumn<bool>(
    'selected',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("selected" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _keyCountMeta = const VerificationMeta(
    'keyCount',
  );
  @override
  late final GeneratedColumn<int> keyCount = GeneratedColumn<int>(
    'key_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorLineMeta = const VerificationMeta(
    'errorLine',
  );
  @override
  late final GeneratedColumn<int> errorLine = GeneratedColumn<int>(
    'error_line',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    inputFileId,
    name,
    state,
    sourceOverride,
    excluded,
    selected,
    keyCount,
    errorMessage,
    errorLine,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'namespaces';
  @override
  VerificationContext validateIntegrity(
    Insertable<Namespace> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('input_file_id')) {
      context.handle(
        _inputFileIdMeta,
        inputFileId.isAcceptableOrUnknown(
          data['input_file_id']!,
          _inputFileIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inputFileIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('source_override')) {
      context.handle(
        _sourceOverrideMeta,
        sourceOverride.isAcceptableOrUnknown(
          data['source_override']!,
          _sourceOverrideMeta,
        ),
      );
    }
    if (data.containsKey('excluded')) {
      context.handle(
        _excludedMeta,
        excluded.isAcceptableOrUnknown(data['excluded']!, _excludedMeta),
      );
    }
    if (data.containsKey('selected')) {
      context.handle(
        _selectedMeta,
        selected.isAcceptableOrUnknown(data['selected']!, _selectedMeta),
      );
    }
    if (data.containsKey('key_count')) {
      context.handle(
        _keyCountMeta,
        keyCount.isAcceptableOrUnknown(data['key_count']!, _keyCountMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('error_line')) {
      context.handle(
        _errorLineMeta,
        errorLine.isAcceptableOrUnknown(data['error_line']!, _errorLineMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Namespace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Namespace(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      inputFileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}input_file_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      sourceOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_override'],
      ),
      excluded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}excluded'],
      )!,
      selected: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}selected'],
      )!,
      keyCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}key_count'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      errorLine: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}error_line'],
      ),
    );
  }

  @override
  $NamespacesTable createAlias(String alias) {
    return $NamespacesTable(attachedDatabase, alias);
  }
}

class Namespace extends DataClass implements Insertable<Namespace> {
  final String id;
  final String inputFileId;
  final String name;
  final String state;
  final String? sourceOverride;
  final bool excluded;
  final bool selected;
  final int keyCount;
  final String? errorMessage;
  final int? errorLine;
  const Namespace({
    required this.id,
    required this.inputFileId,
    required this.name,
    required this.state,
    this.sourceOverride,
    required this.excluded,
    required this.selected,
    required this.keyCount,
    this.errorMessage,
    this.errorLine,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['input_file_id'] = Variable<String>(inputFileId);
    map['name'] = Variable<String>(name);
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || sourceOverride != null) {
      map['source_override'] = Variable<String>(sourceOverride);
    }
    map['excluded'] = Variable<bool>(excluded);
    map['selected'] = Variable<bool>(selected);
    map['key_count'] = Variable<int>(keyCount);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || errorLine != null) {
      map['error_line'] = Variable<int>(errorLine);
    }
    return map;
  }

  NamespacesCompanion toCompanion(bool nullToAbsent) {
    return NamespacesCompanion(
      id: Value(id),
      inputFileId: Value(inputFileId),
      name: Value(name),
      state: Value(state),
      sourceOverride: sourceOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceOverride),
      excluded: Value(excluded),
      selected: Value(selected),
      keyCount: Value(keyCount),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      errorLine: errorLine == null && nullToAbsent
          ? const Value.absent()
          : Value(errorLine),
    );
  }

  factory Namespace.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Namespace(
      id: serializer.fromJson<String>(json['id']),
      inputFileId: serializer.fromJson<String>(json['inputFileId']),
      name: serializer.fromJson<String>(json['name']),
      state: serializer.fromJson<String>(json['state']),
      sourceOverride: serializer.fromJson<String?>(json['sourceOverride']),
      excluded: serializer.fromJson<bool>(json['excluded']),
      selected: serializer.fromJson<bool>(json['selected']),
      keyCount: serializer.fromJson<int>(json['keyCount']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      errorLine: serializer.fromJson<int?>(json['errorLine']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'inputFileId': serializer.toJson<String>(inputFileId),
      'name': serializer.toJson<String>(name),
      'state': serializer.toJson<String>(state),
      'sourceOverride': serializer.toJson<String?>(sourceOverride),
      'excluded': serializer.toJson<bool>(excluded),
      'selected': serializer.toJson<bool>(selected),
      'keyCount': serializer.toJson<int>(keyCount),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'errorLine': serializer.toJson<int?>(errorLine),
    };
  }

  Namespace copyWith({
    String? id,
    String? inputFileId,
    String? name,
    String? state,
    Value<String?> sourceOverride = const Value.absent(),
    bool? excluded,
    bool? selected,
    int? keyCount,
    Value<String?> errorMessage = const Value.absent(),
    Value<int?> errorLine = const Value.absent(),
  }) => Namespace(
    id: id ?? this.id,
    inputFileId: inputFileId ?? this.inputFileId,
    name: name ?? this.name,
    state: state ?? this.state,
    sourceOverride: sourceOverride.present
        ? sourceOverride.value
        : this.sourceOverride,
    excluded: excluded ?? this.excluded,
    selected: selected ?? this.selected,
    keyCount: keyCount ?? this.keyCount,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    errorLine: errorLine.present ? errorLine.value : this.errorLine,
  );
  Namespace copyWithCompanion(NamespacesCompanion data) {
    return Namespace(
      id: data.id.present ? data.id.value : this.id,
      inputFileId: data.inputFileId.present
          ? data.inputFileId.value
          : this.inputFileId,
      name: data.name.present ? data.name.value : this.name,
      state: data.state.present ? data.state.value : this.state,
      sourceOverride: data.sourceOverride.present
          ? data.sourceOverride.value
          : this.sourceOverride,
      excluded: data.excluded.present ? data.excluded.value : this.excluded,
      selected: data.selected.present ? data.selected.value : this.selected,
      keyCount: data.keyCount.present ? data.keyCount.value : this.keyCount,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      errorLine: data.errorLine.present ? data.errorLine.value : this.errorLine,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Namespace(')
          ..write('id: $id, ')
          ..write('inputFileId: $inputFileId, ')
          ..write('name: $name, ')
          ..write('state: $state, ')
          ..write('sourceOverride: $sourceOverride, ')
          ..write('excluded: $excluded, ')
          ..write('selected: $selected, ')
          ..write('keyCount: $keyCount, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('errorLine: $errorLine')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    inputFileId,
    name,
    state,
    sourceOverride,
    excluded,
    selected,
    keyCount,
    errorMessage,
    errorLine,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Namespace &&
          other.id == this.id &&
          other.inputFileId == this.inputFileId &&
          other.name == this.name &&
          other.state == this.state &&
          other.sourceOverride == this.sourceOverride &&
          other.excluded == this.excluded &&
          other.selected == this.selected &&
          other.keyCount == this.keyCount &&
          other.errorMessage == this.errorMessage &&
          other.errorLine == this.errorLine);
}

class NamespacesCompanion extends UpdateCompanion<Namespace> {
  final Value<String> id;
  final Value<String> inputFileId;
  final Value<String> name;
  final Value<String> state;
  final Value<String?> sourceOverride;
  final Value<bool> excluded;
  final Value<bool> selected;
  final Value<int> keyCount;
  final Value<String?> errorMessage;
  final Value<int?> errorLine;
  final Value<int> rowid;
  const NamespacesCompanion({
    this.id = const Value.absent(),
    this.inputFileId = const Value.absent(),
    this.name = const Value.absent(),
    this.state = const Value.absent(),
    this.sourceOverride = const Value.absent(),
    this.excluded = const Value.absent(),
    this.selected = const Value.absent(),
    this.keyCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.errorLine = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NamespacesCompanion.insert({
    required String id,
    required String inputFileId,
    required String name,
    required String state,
    this.sourceOverride = const Value.absent(),
    this.excluded = const Value.absent(),
    this.selected = const Value.absent(),
    this.keyCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.errorLine = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       inputFileId = Value(inputFileId),
       name = Value(name),
       state = Value(state);
  static Insertable<Namespace> custom({
    Expression<String>? id,
    Expression<String>? inputFileId,
    Expression<String>? name,
    Expression<String>? state,
    Expression<String>? sourceOverride,
    Expression<bool>? excluded,
    Expression<bool>? selected,
    Expression<int>? keyCount,
    Expression<String>? errorMessage,
    Expression<int>? errorLine,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (inputFileId != null) 'input_file_id': inputFileId,
      if (name != null) 'name': name,
      if (state != null) 'state': state,
      if (sourceOverride != null) 'source_override': sourceOverride,
      if (excluded != null) 'excluded': excluded,
      if (selected != null) 'selected': selected,
      if (keyCount != null) 'key_count': keyCount,
      if (errorMessage != null) 'error_message': errorMessage,
      if (errorLine != null) 'error_line': errorLine,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NamespacesCompanion copyWith({
    Value<String>? id,
    Value<String>? inputFileId,
    Value<String>? name,
    Value<String>? state,
    Value<String?>? sourceOverride,
    Value<bool>? excluded,
    Value<bool>? selected,
    Value<int>? keyCount,
    Value<String?>? errorMessage,
    Value<int?>? errorLine,
    Value<int>? rowid,
  }) {
    return NamespacesCompanion(
      id: id ?? this.id,
      inputFileId: inputFileId ?? this.inputFileId,
      name: name ?? this.name,
      state: state ?? this.state,
      sourceOverride: sourceOverride ?? this.sourceOverride,
      excluded: excluded ?? this.excluded,
      selected: selected ?? this.selected,
      keyCount: keyCount ?? this.keyCount,
      errorMessage: errorMessage ?? this.errorMessage,
      errorLine: errorLine ?? this.errorLine,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (inputFileId.present) {
      map['input_file_id'] = Variable<String>(inputFileId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (sourceOverride.present) {
      map['source_override'] = Variable<String>(sourceOverride.value);
    }
    if (excluded.present) {
      map['excluded'] = Variable<bool>(excluded.value);
    }
    if (selected.present) {
      map['selected'] = Variable<bool>(selected.value);
    }
    if (keyCount.present) {
      map['key_count'] = Variable<int>(keyCount.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (errorLine.present) {
      map['error_line'] = Variable<int>(errorLine.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NamespacesCompanion(')
          ..write('id: $id, ')
          ..write('inputFileId: $inputFileId, ')
          ..write('name: $name, ')
          ..write('state: $state, ')
          ..write('sourceOverride: $sourceOverride, ')
          ..write('excluded: $excluded, ')
          ..write('selected: $selected, ')
          ..write('keyCount: $keyCount, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('errorLine: $errorLine, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LanguageFilesTable extends LanguageFiles
    with TableInfo<$LanguageFilesTable, LanguageFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LanguageFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _namespaceIdMeta = const VerificationMeta(
    'namespaceId',
  );
  @override
  late final GeneratedColumn<String> namespaceId = GeneratedColumn<String>(
    'namespace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES namespaces (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _rawCodeMeta = const VerificationMeta(
    'rawCode',
  );
  @override
  late final GeneratedColumn<String> rawCode = GeneratedColumn<String>(
    'raw_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryPathMeta = const VerificationMeta(
    'entryPath',
  );
  @override
  late final GeneratedColumn<String> entryPath = GeneratedColumn<String>(
    'entry_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyCountMeta = const VerificationMeta(
    'keyCount',
  );
  @override
  late final GeneratedColumn<int> keyCount = GeneratedColumn<int>(
    'key_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    namespaceId,
    rawCode,
    code,
    entryPath,
    keyCount,
    role,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'language_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<LanguageFile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('namespace_id')) {
      context.handle(
        _namespaceIdMeta,
        namespaceId.isAcceptableOrUnknown(
          data['namespace_id']!,
          _namespaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_namespaceIdMeta);
    }
    if (data.containsKey('raw_code')) {
      context.handle(
        _rawCodeMeta,
        rawCode.isAcceptableOrUnknown(data['raw_code']!, _rawCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_rawCodeMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('entry_path')) {
      context.handle(
        _entryPathMeta,
        entryPath.isAcceptableOrUnknown(data['entry_path']!, _entryPathMeta),
      );
    } else if (isInserting) {
      context.missing(_entryPathMeta);
    }
    if (data.containsKey('key_count')) {
      context.handle(
        _keyCountMeta,
        keyCount.isAcceptableOrUnknown(data['key_count']!, _keyCountMeta),
      );
    } else if (isInserting) {
      context.missing(_keyCountMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LanguageFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LanguageFile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      namespaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}namespace_id'],
      )!,
      rawCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_code'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      entryPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_path'],
      )!,
      keyCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}key_count'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
    );
  }

  @override
  $LanguageFilesTable createAlias(String alias) {
    return $LanguageFilesTable(attachedDatabase, alias);
  }
}

class LanguageFile extends DataClass implements Insertable<LanguageFile> {
  final String id;
  final String namespaceId;
  final String rawCode;
  final String code;
  final String entryPath;
  final int keyCount;
  final String role;
  const LanguageFile({
    required this.id,
    required this.namespaceId,
    required this.rawCode,
    required this.code,
    required this.entryPath,
    required this.keyCount,
    required this.role,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['namespace_id'] = Variable<String>(namespaceId);
    map['raw_code'] = Variable<String>(rawCode);
    map['code'] = Variable<String>(code);
    map['entry_path'] = Variable<String>(entryPath);
    map['key_count'] = Variable<int>(keyCount);
    map['role'] = Variable<String>(role);
    return map;
  }

  LanguageFilesCompanion toCompanion(bool nullToAbsent) {
    return LanguageFilesCompanion(
      id: Value(id),
      namespaceId: Value(namespaceId),
      rawCode: Value(rawCode),
      code: Value(code),
      entryPath: Value(entryPath),
      keyCount: Value(keyCount),
      role: Value(role),
    );
  }

  factory LanguageFile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LanguageFile(
      id: serializer.fromJson<String>(json['id']),
      namespaceId: serializer.fromJson<String>(json['namespaceId']),
      rawCode: serializer.fromJson<String>(json['rawCode']),
      code: serializer.fromJson<String>(json['code']),
      entryPath: serializer.fromJson<String>(json['entryPath']),
      keyCount: serializer.fromJson<int>(json['keyCount']),
      role: serializer.fromJson<String>(json['role']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'namespaceId': serializer.toJson<String>(namespaceId),
      'rawCode': serializer.toJson<String>(rawCode),
      'code': serializer.toJson<String>(code),
      'entryPath': serializer.toJson<String>(entryPath),
      'keyCount': serializer.toJson<int>(keyCount),
      'role': serializer.toJson<String>(role),
    };
  }

  LanguageFile copyWith({
    String? id,
    String? namespaceId,
    String? rawCode,
    String? code,
    String? entryPath,
    int? keyCount,
    String? role,
  }) => LanguageFile(
    id: id ?? this.id,
    namespaceId: namespaceId ?? this.namespaceId,
    rawCode: rawCode ?? this.rawCode,
    code: code ?? this.code,
    entryPath: entryPath ?? this.entryPath,
    keyCount: keyCount ?? this.keyCount,
    role: role ?? this.role,
  );
  LanguageFile copyWithCompanion(LanguageFilesCompanion data) {
    return LanguageFile(
      id: data.id.present ? data.id.value : this.id,
      namespaceId: data.namespaceId.present
          ? data.namespaceId.value
          : this.namespaceId,
      rawCode: data.rawCode.present ? data.rawCode.value : this.rawCode,
      code: data.code.present ? data.code.value : this.code,
      entryPath: data.entryPath.present ? data.entryPath.value : this.entryPath,
      keyCount: data.keyCount.present ? data.keyCount.value : this.keyCount,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LanguageFile(')
          ..write('id: $id, ')
          ..write('namespaceId: $namespaceId, ')
          ..write('rawCode: $rawCode, ')
          ..write('code: $code, ')
          ..write('entryPath: $entryPath, ')
          ..write('keyCount: $keyCount, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, namespaceId, rawCode, code, entryPath, keyCount, role);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LanguageFile &&
          other.id == this.id &&
          other.namespaceId == this.namespaceId &&
          other.rawCode == this.rawCode &&
          other.code == this.code &&
          other.entryPath == this.entryPath &&
          other.keyCount == this.keyCount &&
          other.role == this.role);
}

class LanguageFilesCompanion extends UpdateCompanion<LanguageFile> {
  final Value<String> id;
  final Value<String> namespaceId;
  final Value<String> rawCode;
  final Value<String> code;
  final Value<String> entryPath;
  final Value<int> keyCount;
  final Value<String> role;
  final Value<int> rowid;
  const LanguageFilesCompanion({
    this.id = const Value.absent(),
    this.namespaceId = const Value.absent(),
    this.rawCode = const Value.absent(),
    this.code = const Value.absent(),
    this.entryPath = const Value.absent(),
    this.keyCount = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LanguageFilesCompanion.insert({
    required String id,
    required String namespaceId,
    required String rawCode,
    required String code,
    required String entryPath,
    required int keyCount,
    required String role,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       namespaceId = Value(namespaceId),
       rawCode = Value(rawCode),
       code = Value(code),
       entryPath = Value(entryPath),
       keyCount = Value(keyCount),
       role = Value(role);
  static Insertable<LanguageFile> custom({
    Expression<String>? id,
    Expression<String>? namespaceId,
    Expression<String>? rawCode,
    Expression<String>? code,
    Expression<String>? entryPath,
    Expression<int>? keyCount,
    Expression<String>? role,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (namespaceId != null) 'namespace_id': namespaceId,
      if (rawCode != null) 'raw_code': rawCode,
      if (code != null) 'code': code,
      if (entryPath != null) 'entry_path': entryPath,
      if (keyCount != null) 'key_count': keyCount,
      if (role != null) 'role': role,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LanguageFilesCompanion copyWith({
    Value<String>? id,
    Value<String>? namespaceId,
    Value<String>? rawCode,
    Value<String>? code,
    Value<String>? entryPath,
    Value<int>? keyCount,
    Value<String>? role,
    Value<int>? rowid,
  }) {
    return LanguageFilesCompanion(
      id: id ?? this.id,
      namespaceId: namespaceId ?? this.namespaceId,
      rawCode: rawCode ?? this.rawCode,
      code: code ?? this.code,
      entryPath: entryPath ?? this.entryPath,
      keyCount: keyCount ?? this.keyCount,
      role: role ?? this.role,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (namespaceId.present) {
      map['namespace_id'] = Variable<String>(namespaceId.value);
    }
    if (rawCode.present) {
      map['raw_code'] = Variable<String>(rawCode.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (entryPath.present) {
      map['entry_path'] = Variable<String>(entryPath.value);
    }
    if (keyCount.present) {
      map['key_count'] = Variable<int>(keyCount.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LanguageFilesCompanion(')
          ..write('id: $id, ')
          ..write('namespaceId: $namespaceId, ')
          ..write('rawCode: $rawCode, ')
          ..write('code: $code, ')
          ..write('entryPath: $entryPath, ')
          ..write('keyCount: $keyCount, ')
          ..write('role: $role, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntriesTable extends Entries with TableInfo<$EntriesTable, Entry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _namespaceIdMeta = const VerificationMeta(
    'namespaceId',
  );
  @override
  late final GeneratedColumn<String> namespaceId = GeneratedColumn<String>(
    'namespace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES namespaces (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyCategoryMeta = const VerificationMeta(
    'keyCategory',
  );
  @override
  late final GeneratedColumn<String> keyCategory = GeneratedColumn<String>(
    'key_category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _keyOrderMeta = const VerificationMeta(
    'keyOrder',
  );
  @override
  late final GeneratedColumn<int> keyOrder = GeneratedColumn<int>(
    'key_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _existingTranslationMeta =
      const VerificationMeta('existingTranslation');
  @override
  late final GeneratedColumn<String> existingTranslation =
      GeneratedColumn<String>(
        'existing_translation',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _newTranslationMeta = const VerificationMeta(
    'newTranslation',
  );
  @override
  late final GeneratedColumn<String> newTranslation = GeneratedColumn<String>(
    'new_translation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userTranslationMeta = const VerificationMeta(
    'userTranslation',
  );
  @override
  late final GeneratedColumn<String> userTranslation = GeneratedColumn<String>(
    'user_translation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userEditedMeta = const VerificationMeta(
    'userEdited',
  );
  @override
  late final GeneratedColumn<bool> userEdited = GeneratedColumn<bool>(
    'user_edited',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("user_edited" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _validationJsonMeta = const VerificationMeta(
    'validationJson',
  );
  @override
  late final GeneratedColumn<String> validationJson = GeneratedColumn<String>(
    'validation_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _warningsJsonMeta = const VerificationMeta(
    'warningsJson',
  );
  @override
  late final GeneratedColumn<String> warningsJson = GeneratedColumn<String>(
    'warnings_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    id,
    namespaceId,
    key,
    keyCategory,
    keyOrder,
    sourceText,
    existingTranslation,
    newTranslation,
    userTranslation,
    status,
    providerId,
    modelId,
    userEdited,
    validationJson,
    warningsJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<Entry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('namespace_id')) {
      context.handle(
        _namespaceIdMeta,
        namespaceId.isAcceptableOrUnknown(
          data['namespace_id']!,
          _namespaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_namespaceIdMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('key_category')) {
      context.handle(
        _keyCategoryMeta,
        keyCategory.isAcceptableOrUnknown(
          data['key_category']!,
          _keyCategoryMeta,
        ),
      );
    }
    if (data.containsKey('key_order')) {
      context.handle(
        _keyOrderMeta,
        keyOrder.isAcceptableOrUnknown(data['key_order']!, _keyOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_keyOrderMeta);
    }
    if (data.containsKey('source_text')) {
      context.handle(
        _sourceTextMeta,
        sourceText.isAcceptableOrUnknown(data['source_text']!, _sourceTextMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTextMeta);
    }
    if (data.containsKey('existing_translation')) {
      context.handle(
        _existingTranslationMeta,
        existingTranslation.isAcceptableOrUnknown(
          data['existing_translation']!,
          _existingTranslationMeta,
        ),
      );
    }
    if (data.containsKey('new_translation')) {
      context.handle(
        _newTranslationMeta,
        newTranslation.isAcceptableOrUnknown(
          data['new_translation']!,
          _newTranslationMeta,
        ),
      );
    }
    if (data.containsKey('user_translation')) {
      context.handle(
        _userTranslationMeta,
        userTranslation.isAcceptableOrUnknown(
          data['user_translation']!,
          _userTranslationMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    }
    if (data.containsKey('user_edited')) {
      context.handle(
        _userEditedMeta,
        userEdited.isAcceptableOrUnknown(data['user_edited']!, _userEditedMeta),
      );
    }
    if (data.containsKey('validation_json')) {
      context.handle(
        _validationJsonMeta,
        validationJson.isAcceptableOrUnknown(
          data['validation_json']!,
          _validationJsonMeta,
        ),
      );
    }
    if (data.containsKey('warnings_json')) {
      context.handle(
        _warningsJsonMeta,
        warningsJson.isAcceptableOrUnknown(
          data['warnings_json']!,
          _warningsJsonMeta,
        ),
      );
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Entry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Entry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      namespaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}namespace_id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      keyCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key_category'],
      ),
      keyOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}key_order'],
      )!,
      sourceText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_text'],
      )!,
      existingTranslation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}existing_translation'],
      ),
      newTranslation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_translation'],
      ),
      userTranslation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_translation'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      ),
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      ),
      userEdited: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}user_edited'],
      )!,
      validationJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}validation_json'],
      ),
      warningsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}warnings_json'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $EntriesTable createAlias(String alias) {
    return $EntriesTable(attachedDatabase, alias);
  }
}

class Entry extends DataClass implements Insertable<Entry> {
  final String id;
  final String namespaceId;
  final String key;
  final String? keyCategory;
  final int keyOrder;
  final String sourceText;
  final String? existingTranslation;
  final String? newTranslation;
  final String? userTranslation;
  final String status;
  final String? providerId;
  final String? modelId;
  final bool userEdited;
  final String? validationJson;
  final String? warningsJson;
  final DateTime updatedAt;
  const Entry({
    required this.id,
    required this.namespaceId,
    required this.key,
    this.keyCategory,
    required this.keyOrder,
    required this.sourceText,
    this.existingTranslation,
    this.newTranslation,
    this.userTranslation,
    required this.status,
    this.providerId,
    this.modelId,
    required this.userEdited,
    this.validationJson,
    this.warningsJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['namespace_id'] = Variable<String>(namespaceId);
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || keyCategory != null) {
      map['key_category'] = Variable<String>(keyCategory);
    }
    map['key_order'] = Variable<int>(keyOrder);
    map['source_text'] = Variable<String>(sourceText);
    if (!nullToAbsent || existingTranslation != null) {
      map['existing_translation'] = Variable<String>(existingTranslation);
    }
    if (!nullToAbsent || newTranslation != null) {
      map['new_translation'] = Variable<String>(newTranslation);
    }
    if (!nullToAbsent || userTranslation != null) {
      map['user_translation'] = Variable<String>(userTranslation);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || providerId != null) {
      map['provider_id'] = Variable<String>(providerId);
    }
    if (!nullToAbsent || modelId != null) {
      map['model_id'] = Variable<String>(modelId);
    }
    map['user_edited'] = Variable<bool>(userEdited);
    if (!nullToAbsent || validationJson != null) {
      map['validation_json'] = Variable<String>(validationJson);
    }
    if (!nullToAbsent || warningsJson != null) {
      map['warnings_json'] = Variable<String>(warningsJson);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EntriesCompanion toCompanion(bool nullToAbsent) {
    return EntriesCompanion(
      id: Value(id),
      namespaceId: Value(namespaceId),
      key: Value(key),
      keyCategory: keyCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(keyCategory),
      keyOrder: Value(keyOrder),
      sourceText: Value(sourceText),
      existingTranslation: existingTranslation == null && nullToAbsent
          ? const Value.absent()
          : Value(existingTranslation),
      newTranslation: newTranslation == null && nullToAbsent
          ? const Value.absent()
          : Value(newTranslation),
      userTranslation: userTranslation == null && nullToAbsent
          ? const Value.absent()
          : Value(userTranslation),
      status: Value(status),
      providerId: providerId == null && nullToAbsent
          ? const Value.absent()
          : Value(providerId),
      modelId: modelId == null && nullToAbsent
          ? const Value.absent()
          : Value(modelId),
      userEdited: Value(userEdited),
      validationJson: validationJson == null && nullToAbsent
          ? const Value.absent()
          : Value(validationJson),
      warningsJson: warningsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(warningsJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory Entry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Entry(
      id: serializer.fromJson<String>(json['id']),
      namespaceId: serializer.fromJson<String>(json['namespaceId']),
      key: serializer.fromJson<String>(json['key']),
      keyCategory: serializer.fromJson<String?>(json['keyCategory']),
      keyOrder: serializer.fromJson<int>(json['keyOrder']),
      sourceText: serializer.fromJson<String>(json['sourceText']),
      existingTranslation: serializer.fromJson<String?>(
        json['existingTranslation'],
      ),
      newTranslation: serializer.fromJson<String?>(json['newTranslation']),
      userTranslation: serializer.fromJson<String?>(json['userTranslation']),
      status: serializer.fromJson<String>(json['status']),
      providerId: serializer.fromJson<String?>(json['providerId']),
      modelId: serializer.fromJson<String?>(json['modelId']),
      userEdited: serializer.fromJson<bool>(json['userEdited']),
      validationJson: serializer.fromJson<String?>(json['validationJson']),
      warningsJson: serializer.fromJson<String?>(json['warningsJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'namespaceId': serializer.toJson<String>(namespaceId),
      'key': serializer.toJson<String>(key),
      'keyCategory': serializer.toJson<String?>(keyCategory),
      'keyOrder': serializer.toJson<int>(keyOrder),
      'sourceText': serializer.toJson<String>(sourceText),
      'existingTranslation': serializer.toJson<String?>(existingTranslation),
      'newTranslation': serializer.toJson<String?>(newTranslation),
      'userTranslation': serializer.toJson<String?>(userTranslation),
      'status': serializer.toJson<String>(status),
      'providerId': serializer.toJson<String?>(providerId),
      'modelId': serializer.toJson<String?>(modelId),
      'userEdited': serializer.toJson<bool>(userEdited),
      'validationJson': serializer.toJson<String?>(validationJson),
      'warningsJson': serializer.toJson<String?>(warningsJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Entry copyWith({
    String? id,
    String? namespaceId,
    String? key,
    Value<String?> keyCategory = const Value.absent(),
    int? keyOrder,
    String? sourceText,
    Value<String?> existingTranslation = const Value.absent(),
    Value<String?> newTranslation = const Value.absent(),
    Value<String?> userTranslation = const Value.absent(),
    String? status,
    Value<String?> providerId = const Value.absent(),
    Value<String?> modelId = const Value.absent(),
    bool? userEdited,
    Value<String?> validationJson = const Value.absent(),
    Value<String?> warningsJson = const Value.absent(),
    DateTime? updatedAt,
  }) => Entry(
    id: id ?? this.id,
    namespaceId: namespaceId ?? this.namespaceId,
    key: key ?? this.key,
    keyCategory: keyCategory.present ? keyCategory.value : this.keyCategory,
    keyOrder: keyOrder ?? this.keyOrder,
    sourceText: sourceText ?? this.sourceText,
    existingTranslation: existingTranslation.present
        ? existingTranslation.value
        : this.existingTranslation,
    newTranslation: newTranslation.present
        ? newTranslation.value
        : this.newTranslation,
    userTranslation: userTranslation.present
        ? userTranslation.value
        : this.userTranslation,
    status: status ?? this.status,
    providerId: providerId.present ? providerId.value : this.providerId,
    modelId: modelId.present ? modelId.value : this.modelId,
    userEdited: userEdited ?? this.userEdited,
    validationJson: validationJson.present
        ? validationJson.value
        : this.validationJson,
    warningsJson: warningsJson.present ? warningsJson.value : this.warningsJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Entry copyWithCompanion(EntriesCompanion data) {
    return Entry(
      id: data.id.present ? data.id.value : this.id,
      namespaceId: data.namespaceId.present
          ? data.namespaceId.value
          : this.namespaceId,
      key: data.key.present ? data.key.value : this.key,
      keyCategory: data.keyCategory.present
          ? data.keyCategory.value
          : this.keyCategory,
      keyOrder: data.keyOrder.present ? data.keyOrder.value : this.keyOrder,
      sourceText: data.sourceText.present
          ? data.sourceText.value
          : this.sourceText,
      existingTranslation: data.existingTranslation.present
          ? data.existingTranslation.value
          : this.existingTranslation,
      newTranslation: data.newTranslation.present
          ? data.newTranslation.value
          : this.newTranslation,
      userTranslation: data.userTranslation.present
          ? data.userTranslation.value
          : this.userTranslation,
      status: data.status.present ? data.status.value : this.status,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      userEdited: data.userEdited.present
          ? data.userEdited.value
          : this.userEdited,
      validationJson: data.validationJson.present
          ? data.validationJson.value
          : this.validationJson,
      warningsJson: data.warningsJson.present
          ? data.warningsJson.value
          : this.warningsJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Entry(')
          ..write('id: $id, ')
          ..write('namespaceId: $namespaceId, ')
          ..write('key: $key, ')
          ..write('keyCategory: $keyCategory, ')
          ..write('keyOrder: $keyOrder, ')
          ..write('sourceText: $sourceText, ')
          ..write('existingTranslation: $existingTranslation, ')
          ..write('newTranslation: $newTranslation, ')
          ..write('userTranslation: $userTranslation, ')
          ..write('status: $status, ')
          ..write('providerId: $providerId, ')
          ..write('modelId: $modelId, ')
          ..write('userEdited: $userEdited, ')
          ..write('validationJson: $validationJson, ')
          ..write('warningsJson: $warningsJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    namespaceId,
    key,
    keyCategory,
    keyOrder,
    sourceText,
    existingTranslation,
    newTranslation,
    userTranslation,
    status,
    providerId,
    modelId,
    userEdited,
    validationJson,
    warningsJson,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Entry &&
          other.id == this.id &&
          other.namespaceId == this.namespaceId &&
          other.key == this.key &&
          other.keyCategory == this.keyCategory &&
          other.keyOrder == this.keyOrder &&
          other.sourceText == this.sourceText &&
          other.existingTranslation == this.existingTranslation &&
          other.newTranslation == this.newTranslation &&
          other.userTranslation == this.userTranslation &&
          other.status == this.status &&
          other.providerId == this.providerId &&
          other.modelId == this.modelId &&
          other.userEdited == this.userEdited &&
          other.validationJson == this.validationJson &&
          other.warningsJson == this.warningsJson &&
          other.updatedAt == this.updatedAt);
}

class EntriesCompanion extends UpdateCompanion<Entry> {
  final Value<String> id;
  final Value<String> namespaceId;
  final Value<String> key;
  final Value<String?> keyCategory;
  final Value<int> keyOrder;
  final Value<String> sourceText;
  final Value<String?> existingTranslation;
  final Value<String?> newTranslation;
  final Value<String?> userTranslation;
  final Value<String> status;
  final Value<String?> providerId;
  final Value<String?> modelId;
  final Value<bool> userEdited;
  final Value<String?> validationJson;
  final Value<String?> warningsJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const EntriesCompanion({
    this.id = const Value.absent(),
    this.namespaceId = const Value.absent(),
    this.key = const Value.absent(),
    this.keyCategory = const Value.absent(),
    this.keyOrder = const Value.absent(),
    this.sourceText = const Value.absent(),
    this.existingTranslation = const Value.absent(),
    this.newTranslation = const Value.absent(),
    this.userTranslation = const Value.absent(),
    this.status = const Value.absent(),
    this.providerId = const Value.absent(),
    this.modelId = const Value.absent(),
    this.userEdited = const Value.absent(),
    this.validationJson = const Value.absent(),
    this.warningsJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntriesCompanion.insert({
    required String id,
    required String namespaceId,
    required String key,
    this.keyCategory = const Value.absent(),
    required int keyOrder,
    required String sourceText,
    this.existingTranslation = const Value.absent(),
    this.newTranslation = const Value.absent(),
    this.userTranslation = const Value.absent(),
    required String status,
    this.providerId = const Value.absent(),
    this.modelId = const Value.absent(),
    this.userEdited = const Value.absent(),
    this.validationJson = const Value.absent(),
    this.warningsJson = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       namespaceId = Value(namespaceId),
       key = Value(key),
       keyOrder = Value(keyOrder),
       sourceText = Value(sourceText),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<Entry> custom({
    Expression<String>? id,
    Expression<String>? namespaceId,
    Expression<String>? key,
    Expression<String>? keyCategory,
    Expression<int>? keyOrder,
    Expression<String>? sourceText,
    Expression<String>? existingTranslation,
    Expression<String>? newTranslation,
    Expression<String>? userTranslation,
    Expression<String>? status,
    Expression<String>? providerId,
    Expression<String>? modelId,
    Expression<bool>? userEdited,
    Expression<String>? validationJson,
    Expression<String>? warningsJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (namespaceId != null) 'namespace_id': namespaceId,
      if (key != null) 'key': key,
      if (keyCategory != null) 'key_category': keyCategory,
      if (keyOrder != null) 'key_order': keyOrder,
      if (sourceText != null) 'source_text': sourceText,
      if (existingTranslation != null)
        'existing_translation': existingTranslation,
      if (newTranslation != null) 'new_translation': newTranslation,
      if (userTranslation != null) 'user_translation': userTranslation,
      if (status != null) 'status': status,
      if (providerId != null) 'provider_id': providerId,
      if (modelId != null) 'model_id': modelId,
      if (userEdited != null) 'user_edited': userEdited,
      if (validationJson != null) 'validation_json': validationJson,
      if (warningsJson != null) 'warnings_json': warningsJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? namespaceId,
    Value<String>? key,
    Value<String?>? keyCategory,
    Value<int>? keyOrder,
    Value<String>? sourceText,
    Value<String?>? existingTranslation,
    Value<String?>? newTranslation,
    Value<String?>? userTranslation,
    Value<String>? status,
    Value<String?>? providerId,
    Value<String?>? modelId,
    Value<bool>? userEdited,
    Value<String?>? validationJson,
    Value<String?>? warningsJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return EntriesCompanion(
      id: id ?? this.id,
      namespaceId: namespaceId ?? this.namespaceId,
      key: key ?? this.key,
      keyCategory: keyCategory ?? this.keyCategory,
      keyOrder: keyOrder ?? this.keyOrder,
      sourceText: sourceText ?? this.sourceText,
      existingTranslation: existingTranslation ?? this.existingTranslation,
      newTranslation: newTranslation ?? this.newTranslation,
      userTranslation: userTranslation ?? this.userTranslation,
      status: status ?? this.status,
      providerId: providerId ?? this.providerId,
      modelId: modelId ?? this.modelId,
      userEdited: userEdited ?? this.userEdited,
      validationJson: validationJson ?? this.validationJson,
      warningsJson: warningsJson ?? this.warningsJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (namespaceId.present) {
      map['namespace_id'] = Variable<String>(namespaceId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (keyCategory.present) {
      map['key_category'] = Variable<String>(keyCategory.value);
    }
    if (keyOrder.present) {
      map['key_order'] = Variable<int>(keyOrder.value);
    }
    if (sourceText.present) {
      map['source_text'] = Variable<String>(sourceText.value);
    }
    if (existingTranslation.present) {
      map['existing_translation'] = Variable<String>(existingTranslation.value);
    }
    if (newTranslation.present) {
      map['new_translation'] = Variable<String>(newTranslation.value);
    }
    if (userTranslation.present) {
      map['user_translation'] = Variable<String>(userTranslation.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (userEdited.present) {
      map['user_edited'] = Variable<bool>(userEdited.value);
    }
    if (validationJson.present) {
      map['validation_json'] = Variable<String>(validationJson.value);
    }
    if (warningsJson.present) {
      map['warnings_json'] = Variable<String>(warningsJson.value);
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
    return (StringBuffer('EntriesCompanion(')
          ..write('id: $id, ')
          ..write('namespaceId: $namespaceId, ')
          ..write('key: $key, ')
          ..write('keyCategory: $keyCategory, ')
          ..write('keyOrder: $keyOrder, ')
          ..write('sourceText: $sourceText, ')
          ..write('existingTranslation: $existingTranslation, ')
          ..write('newTranslation: $newTranslation, ')
          ..write('userTranslation: $userTranslation, ')
          ..write('status: $status, ')
          ..write('providerId: $providerId, ')
          ..write('modelId: $modelId, ')
          ..write('userEdited: $userEdited, ')
          ..write('validationJson: $validationJson, ')
          ..write('warningsJson: $warningsJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConflictsTable extends Conflicts
    with TableInfo<$ConflictsTable, Conflict> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _namespaceNameMeta = const VerificationMeta(
    'namespaceName',
  );
  @override
  late final GeneratedColumn<String> namespaceName = GeneratedColumn<String>(
    'namespace_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _participantsJsonMeta = const VerificationMeta(
    'participantsJson',
  );
  @override
  late final GeneratedColumn<String> participantsJson = GeneratedColumn<String>(
    'participants_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedEntryIdMeta = const VerificationMeta(
    'resolvedEntryId',
  );
  @override
  late final GeneratedColumn<String> resolvedEntryId = GeneratedColumn<String>(
    'resolved_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resolvedMeta = const VerificationMeta(
    'resolved',
  );
  @override
  late final GeneratedColumn<bool> resolved = GeneratedColumn<bool>(
    'resolved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("resolved" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    namespaceName,
    key,
    participantsJson,
    resolvedEntryId,
    resolved,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Conflict> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('namespace_name')) {
      context.handle(
        _namespaceNameMeta,
        namespaceName.isAcceptableOrUnknown(
          data['namespace_name']!,
          _namespaceNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_namespaceNameMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('participants_json')) {
      context.handle(
        _participantsJsonMeta,
        participantsJson.isAcceptableOrUnknown(
          data['participants_json']!,
          _participantsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_participantsJsonMeta);
    }
    if (data.containsKey('resolved_entry_id')) {
      context.handle(
        _resolvedEntryIdMeta,
        resolvedEntryId.isAcceptableOrUnknown(
          data['resolved_entry_id']!,
          _resolvedEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('resolved')) {
      context.handle(
        _resolvedMeta,
        resolved.isAcceptableOrUnknown(data['resolved']!, _resolvedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Conflict map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conflict(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      namespaceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}namespace_name'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      participantsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}participants_json'],
      )!,
      resolvedEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolved_entry_id'],
      ),
      resolved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}resolved'],
      )!,
    );
  }

  @override
  $ConflictsTable createAlias(String alias) {
    return $ConflictsTable(attachedDatabase, alias);
  }
}

class Conflict extends DataClass implements Insertable<Conflict> {
  final String id;
  final String namespaceName;
  final String key;
  final String participantsJson;
  final String? resolvedEntryId;
  final bool resolved;
  const Conflict({
    required this.id,
    required this.namespaceName,
    required this.key,
    required this.participantsJson,
    this.resolvedEntryId,
    required this.resolved,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['namespace_name'] = Variable<String>(namespaceName);
    map['key'] = Variable<String>(key);
    map['participants_json'] = Variable<String>(participantsJson);
    if (!nullToAbsent || resolvedEntryId != null) {
      map['resolved_entry_id'] = Variable<String>(resolvedEntryId);
    }
    map['resolved'] = Variable<bool>(resolved);
    return map;
  }

  ConflictsCompanion toCompanion(bool nullToAbsent) {
    return ConflictsCompanion(
      id: Value(id),
      namespaceName: Value(namespaceName),
      key: Value(key),
      participantsJson: Value(participantsJson),
      resolvedEntryId: resolvedEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedEntryId),
      resolved: Value(resolved),
    );
  }

  factory Conflict.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conflict(
      id: serializer.fromJson<String>(json['id']),
      namespaceName: serializer.fromJson<String>(json['namespaceName']),
      key: serializer.fromJson<String>(json['key']),
      participantsJson: serializer.fromJson<String>(json['participantsJson']),
      resolvedEntryId: serializer.fromJson<String?>(json['resolvedEntryId']),
      resolved: serializer.fromJson<bool>(json['resolved']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'namespaceName': serializer.toJson<String>(namespaceName),
      'key': serializer.toJson<String>(key),
      'participantsJson': serializer.toJson<String>(participantsJson),
      'resolvedEntryId': serializer.toJson<String?>(resolvedEntryId),
      'resolved': serializer.toJson<bool>(resolved),
    };
  }

  Conflict copyWith({
    String? id,
    String? namespaceName,
    String? key,
    String? participantsJson,
    Value<String?> resolvedEntryId = const Value.absent(),
    bool? resolved,
  }) => Conflict(
    id: id ?? this.id,
    namespaceName: namespaceName ?? this.namespaceName,
    key: key ?? this.key,
    participantsJson: participantsJson ?? this.participantsJson,
    resolvedEntryId: resolvedEntryId.present
        ? resolvedEntryId.value
        : this.resolvedEntryId,
    resolved: resolved ?? this.resolved,
  );
  Conflict copyWithCompanion(ConflictsCompanion data) {
    return Conflict(
      id: data.id.present ? data.id.value : this.id,
      namespaceName: data.namespaceName.present
          ? data.namespaceName.value
          : this.namespaceName,
      key: data.key.present ? data.key.value : this.key,
      participantsJson: data.participantsJson.present
          ? data.participantsJson.value
          : this.participantsJson,
      resolvedEntryId: data.resolvedEntryId.present
          ? data.resolvedEntryId.value
          : this.resolvedEntryId,
      resolved: data.resolved.present ? data.resolved.value : this.resolved,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conflict(')
          ..write('id: $id, ')
          ..write('namespaceName: $namespaceName, ')
          ..write('key: $key, ')
          ..write('participantsJson: $participantsJson, ')
          ..write('resolvedEntryId: $resolvedEntryId, ')
          ..write('resolved: $resolved')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    namespaceName,
    key,
    participantsJson,
    resolvedEntryId,
    resolved,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conflict &&
          other.id == this.id &&
          other.namespaceName == this.namespaceName &&
          other.key == this.key &&
          other.participantsJson == this.participantsJson &&
          other.resolvedEntryId == this.resolvedEntryId &&
          other.resolved == this.resolved);
}

class ConflictsCompanion extends UpdateCompanion<Conflict> {
  final Value<String> id;
  final Value<String> namespaceName;
  final Value<String> key;
  final Value<String> participantsJson;
  final Value<String?> resolvedEntryId;
  final Value<bool> resolved;
  final Value<int> rowid;
  const ConflictsCompanion({
    this.id = const Value.absent(),
    this.namespaceName = const Value.absent(),
    this.key = const Value.absent(),
    this.participantsJson = const Value.absent(),
    this.resolvedEntryId = const Value.absent(),
    this.resolved = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConflictsCompanion.insert({
    required String id,
    required String namespaceName,
    required String key,
    required String participantsJson,
    this.resolvedEntryId = const Value.absent(),
    this.resolved = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       namespaceName = Value(namespaceName),
       key = Value(key),
       participantsJson = Value(participantsJson);
  static Insertable<Conflict> custom({
    Expression<String>? id,
    Expression<String>? namespaceName,
    Expression<String>? key,
    Expression<String>? participantsJson,
    Expression<String>? resolvedEntryId,
    Expression<bool>? resolved,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (namespaceName != null) 'namespace_name': namespaceName,
      if (key != null) 'key': key,
      if (participantsJson != null) 'participants_json': participantsJson,
      if (resolvedEntryId != null) 'resolved_entry_id': resolvedEntryId,
      if (resolved != null) 'resolved': resolved,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConflictsCompanion copyWith({
    Value<String>? id,
    Value<String>? namespaceName,
    Value<String>? key,
    Value<String>? participantsJson,
    Value<String?>? resolvedEntryId,
    Value<bool>? resolved,
    Value<int>? rowid,
  }) {
    return ConflictsCompanion(
      id: id ?? this.id,
      namespaceName: namespaceName ?? this.namespaceName,
      key: key ?? this.key,
      participantsJson: participantsJson ?? this.participantsJson,
      resolvedEntryId: resolvedEntryId ?? this.resolvedEntryId,
      resolved: resolved ?? this.resolved,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (namespaceName.present) {
      map['namespace_name'] = Variable<String>(namespaceName.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (participantsJson.present) {
      map['participants_json'] = Variable<String>(participantsJson.value);
    }
    if (resolvedEntryId.present) {
      map['resolved_entry_id'] = Variable<String>(resolvedEntryId.value);
    }
    if (resolved.present) {
      map['resolved'] = Variable<bool>(resolved.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConflictsCompanion(')
          ..write('id: $id, ')
          ..write('namespaceName: $namespaceName, ')
          ..write('key: $key, ')
          ..write('participantsJson: $participantsJson, ')
          ..write('resolvedEntryId: $resolvedEntryId, ')
          ..write('resolved: $resolved, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExportRecordsTable extends ExportRecords
    with TableInfo<$ExportRecordsTable, ExportRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExportRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outputPathMeta = const VerificationMeta(
    'outputPath',
  );
  @override
  late final GeneratedColumn<String> outputPath = GeneratedColumn<String>(
    'output_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _namespaceCountMeta = const VerificationMeta(
    'namespaceCount',
  );
  @override
  late final GeneratedColumn<int> namespaceCount = GeneratedColumn<int>(
    'namespace_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryCountMeta = const VerificationMeta(
    'entryCount',
  );
  @override
  late final GeneratedColumn<int> entryCount = GeneratedColumn<int>(
    'entry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reportPathMeta = const VerificationMeta(
    'reportPath',
  );
  @override
  late final GeneratedColumn<String> reportPath = GeneratedColumn<String>(
    'report_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    format,
    outputPath,
    namespaceCount,
    entryCount,
    reportPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'export_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExportRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('output_path')) {
      context.handle(
        _outputPathMeta,
        outputPath.isAcceptableOrUnknown(data['output_path']!, _outputPathMeta),
      );
    } else if (isInserting) {
      context.missing(_outputPathMeta);
    }
    if (data.containsKey('namespace_count')) {
      context.handle(
        _namespaceCountMeta,
        namespaceCount.isAcceptableOrUnknown(
          data['namespace_count']!,
          _namespaceCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_namespaceCountMeta);
    }
    if (data.containsKey('entry_count')) {
      context.handle(
        _entryCountMeta,
        entryCount.isAcceptableOrUnknown(data['entry_count']!, _entryCountMeta),
      );
    } else if (isInserting) {
      context.missing(_entryCountMeta);
    }
    if (data.containsKey('report_path')) {
      context.handle(
        _reportPathMeta,
        reportPath.isAcceptableOrUnknown(data['report_path']!, _reportPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExportRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExportRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      outputPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}output_path'],
      )!,
      namespaceCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}namespace_count'],
      )!,
      entryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entry_count'],
      )!,
      reportPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}report_path'],
      ),
    );
  }

  @override
  $ExportRecordsTable createAlias(String alias) {
    return $ExportRecordsTable(attachedDatabase, alias);
  }
}

class ExportRecord extends DataClass implements Insertable<ExportRecord> {
  final String id;
  final DateTime createdAt;
  final String format;
  final String outputPath;
  final int namespaceCount;
  final int entryCount;
  final String? reportPath;
  const ExportRecord({
    required this.id,
    required this.createdAt,
    required this.format,
    required this.outputPath,
    required this.namespaceCount,
    required this.entryCount,
    this.reportPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['format'] = Variable<String>(format);
    map['output_path'] = Variable<String>(outputPath);
    map['namespace_count'] = Variable<int>(namespaceCount);
    map['entry_count'] = Variable<int>(entryCount);
    if (!nullToAbsent || reportPath != null) {
      map['report_path'] = Variable<String>(reportPath);
    }
    return map;
  }

  ExportRecordsCompanion toCompanion(bool nullToAbsent) {
    return ExportRecordsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      format: Value(format),
      outputPath: Value(outputPath),
      namespaceCount: Value(namespaceCount),
      entryCount: Value(entryCount),
      reportPath: reportPath == null && nullToAbsent
          ? const Value.absent()
          : Value(reportPath),
    );
  }

  factory ExportRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExportRecord(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      format: serializer.fromJson<String>(json['format']),
      outputPath: serializer.fromJson<String>(json['outputPath']),
      namespaceCount: serializer.fromJson<int>(json['namespaceCount']),
      entryCount: serializer.fromJson<int>(json['entryCount']),
      reportPath: serializer.fromJson<String?>(json['reportPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'format': serializer.toJson<String>(format),
      'outputPath': serializer.toJson<String>(outputPath),
      'namespaceCount': serializer.toJson<int>(namespaceCount),
      'entryCount': serializer.toJson<int>(entryCount),
      'reportPath': serializer.toJson<String?>(reportPath),
    };
  }

  ExportRecord copyWith({
    String? id,
    DateTime? createdAt,
    String? format,
    String? outputPath,
    int? namespaceCount,
    int? entryCount,
    Value<String?> reportPath = const Value.absent(),
  }) => ExportRecord(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    format: format ?? this.format,
    outputPath: outputPath ?? this.outputPath,
    namespaceCount: namespaceCount ?? this.namespaceCount,
    entryCount: entryCount ?? this.entryCount,
    reportPath: reportPath.present ? reportPath.value : this.reportPath,
  );
  ExportRecord copyWithCompanion(ExportRecordsCompanion data) {
    return ExportRecord(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      format: data.format.present ? data.format.value : this.format,
      outputPath: data.outputPath.present
          ? data.outputPath.value
          : this.outputPath,
      namespaceCount: data.namespaceCount.present
          ? data.namespaceCount.value
          : this.namespaceCount,
      entryCount: data.entryCount.present
          ? data.entryCount.value
          : this.entryCount,
      reportPath: data.reportPath.present
          ? data.reportPath.value
          : this.reportPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExportRecord(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('format: $format, ')
          ..write('outputPath: $outputPath, ')
          ..write('namespaceCount: $namespaceCount, ')
          ..write('entryCount: $entryCount, ')
          ..write('reportPath: $reportPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    format,
    outputPath,
    namespaceCount,
    entryCount,
    reportPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExportRecord &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.format == this.format &&
          other.outputPath == this.outputPath &&
          other.namespaceCount == this.namespaceCount &&
          other.entryCount == this.entryCount &&
          other.reportPath == this.reportPath);
}

class ExportRecordsCompanion extends UpdateCompanion<ExportRecord> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<String> format;
  final Value<String> outputPath;
  final Value<int> namespaceCount;
  final Value<int> entryCount;
  final Value<String?> reportPath;
  final Value<int> rowid;
  const ExportRecordsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.format = const Value.absent(),
    this.outputPath = const Value.absent(),
    this.namespaceCount = const Value.absent(),
    this.entryCount = const Value.absent(),
    this.reportPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExportRecordsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required String format,
    required String outputPath,
    required int namespaceCount,
    required int entryCount,
    this.reportPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       format = Value(format),
       outputPath = Value(outputPath),
       namespaceCount = Value(namespaceCount),
       entryCount = Value(entryCount);
  static Insertable<ExportRecord> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? format,
    Expression<String>? outputPath,
    Expression<int>? namespaceCount,
    Expression<int>? entryCount,
    Expression<String>? reportPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (format != null) 'format': format,
      if (outputPath != null) 'output_path': outputPath,
      if (namespaceCount != null) 'namespace_count': namespaceCount,
      if (entryCount != null) 'entry_count': entryCount,
      if (reportPath != null) 'report_path': reportPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExportRecordsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<String>? format,
    Value<String>? outputPath,
    Value<int>? namespaceCount,
    Value<int>? entryCount,
    Value<String?>? reportPath,
    Value<int>? rowid,
  }) {
    return ExportRecordsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      format: format ?? this.format,
      outputPath: outputPath ?? this.outputPath,
      namespaceCount: namespaceCount ?? this.namespaceCount,
      entryCount: entryCount ?? this.entryCount,
      reportPath: reportPath ?? this.reportPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (outputPath.present) {
      map['output_path'] = Variable<String>(outputPath.value);
    }
    if (namespaceCount.present) {
      map['namespace_count'] = Variable<int>(namespaceCount.value);
    }
    if (entryCount.present) {
      map['entry_count'] = Variable<int>(entryCount.value);
    }
    if (reportPath.present) {
      map['report_path'] = Variable<String>(reportPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExportRecordsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('format: $format, ')
          ..write('outputPath: $outputPath, ')
          ..write('namespaceCount: $namespaceCount, ')
          ..write('entryCount: $entryCount, ')
          ..write('reportPath: $reportPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProjectMetaTable projectMeta = $ProjectMetaTable(this);
  late final $InputFilesTable inputFiles = $InputFilesTable(this);
  late final $NamespacesTable namespaces = $NamespacesTable(this);
  late final $LanguageFilesTable languageFiles = $LanguageFilesTable(this);
  late final $EntriesTable entries = $EntriesTable(this);
  late final $ConflictsTable conflicts = $ConflictsTable(this);
  late final $ExportRecordsTable exportRecords = $ExportRecordsTable(this);
  late final EntryDao entryDao = EntryDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    projectMeta,
    inputFiles,
    namespaces,
    languageFiles,
    entries,
    conflicts,
    exportRecords,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'input_files',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('namespaces', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'namespaces',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('language_files', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'namespaces',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('entries', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ProjectMetaTableCreateCompanionBuilder =
    ProjectMetaCompanion Function({
      Value<int> id,
      required String name,
      required String schemaVersion,
      required String appVersion,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String> sourceLangCode,
      Value<String> targetLangCode,
      Value<String?> providerId,
      Value<String?> modelId,
      Value<String> outputFormat,
      Value<String> mcVersion,
      Value<String> packIconMode,
      Value<String?> packIconPath,
      Value<String> togglesJson,
    });
typedef $$ProjectMetaTableUpdateCompanionBuilder =
    ProjectMetaCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> schemaVersion,
      Value<String> appVersion,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> sourceLangCode,
      Value<String> targetLangCode,
      Value<String?> providerId,
      Value<String?> modelId,
      Value<String> outputFormat,
      Value<String> mcVersion,
      Value<String> packIconMode,
      Value<String?> packIconPath,
      Value<String> togglesJson,
    });

class $$ProjectMetaTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectMetaTable> {
  $$ProjectMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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

  ColumnFilters<String> get outputFormat => $composableBuilder(
    column: $table.outputFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mcVersion => $composableBuilder(
    column: $table.mcVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packIconMode => $composableBuilder(
    column: $table.packIconMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packIconPath => $composableBuilder(
    column: $table.packIconPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get togglesJson => $composableBuilder(
    column: $table.togglesJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProjectMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectMetaTable> {
  $$ProjectMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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

  ColumnOrderings<String> get outputFormat => $composableBuilder(
    column: $table.outputFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mcVersion => $composableBuilder(
    column: $table.mcVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packIconMode => $composableBuilder(
    column: $table.packIconMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packIconPath => $composableBuilder(
    column: $table.packIconPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get togglesJson => $composableBuilder(
    column: $table.togglesJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectMetaTable> {
  $$ProjectMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

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

  GeneratedColumn<String> get outputFormat => $composableBuilder(
    column: $table.outputFormat,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mcVersion =>
      $composableBuilder(column: $table.mcVersion, builder: (column) => column);

  GeneratedColumn<String> get packIconMode => $composableBuilder(
    column: $table.packIconMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get packIconPath => $composableBuilder(
    column: $table.packIconPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get togglesJson => $composableBuilder(
    column: $table.togglesJson,
    builder: (column) => column,
  );
}

class $$ProjectMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectMetaTable,
          ProjectMetaData,
          $$ProjectMetaTableFilterComposer,
          $$ProjectMetaTableOrderingComposer,
          $$ProjectMetaTableAnnotationComposer,
          $$ProjectMetaTableCreateCompanionBuilder,
          $$ProjectMetaTableUpdateCompanionBuilder,
          (
            ProjectMetaData,
            BaseReferences<_$AppDatabase, $ProjectMetaTable, ProjectMetaData>,
          ),
          ProjectMetaData,
          PrefetchHooks Function()
        > {
  $$ProjectMetaTableTableManager(_$AppDatabase db, $ProjectMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> schemaVersion = const Value.absent(),
                Value<String> appVersion = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> sourceLangCode = const Value.absent(),
                Value<String> targetLangCode = const Value.absent(),
                Value<String?> providerId = const Value.absent(),
                Value<String?> modelId = const Value.absent(),
                Value<String> outputFormat = const Value.absent(),
                Value<String> mcVersion = const Value.absent(),
                Value<String> packIconMode = const Value.absent(),
                Value<String?> packIconPath = const Value.absent(),
                Value<String> togglesJson = const Value.absent(),
              }) => ProjectMetaCompanion(
                id: id,
                name: name,
                schemaVersion: schemaVersion,
                appVersion: appVersion,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sourceLangCode: sourceLangCode,
                targetLangCode: targetLangCode,
                providerId: providerId,
                modelId: modelId,
                outputFormat: outputFormat,
                mcVersion: mcVersion,
                packIconMode: packIconMode,
                packIconPath: packIconPath,
                togglesJson: togglesJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String schemaVersion,
                required String appVersion,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String> sourceLangCode = const Value.absent(),
                Value<String> targetLangCode = const Value.absent(),
                Value<String?> providerId = const Value.absent(),
                Value<String?> modelId = const Value.absent(),
                Value<String> outputFormat = const Value.absent(),
                Value<String> mcVersion = const Value.absent(),
                Value<String> packIconMode = const Value.absent(),
                Value<String?> packIconPath = const Value.absent(),
                Value<String> togglesJson = const Value.absent(),
              }) => ProjectMetaCompanion.insert(
                id: id,
                name: name,
                schemaVersion: schemaVersion,
                appVersion: appVersion,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sourceLangCode: sourceLangCode,
                targetLangCode: targetLangCode,
                providerId: providerId,
                modelId: modelId,
                outputFormat: outputFormat,
                mcVersion: mcVersion,
                packIconMode: packIconMode,
                packIconPath: packIconPath,
                togglesJson: togglesJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProjectMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectMetaTable,
      ProjectMetaData,
      $$ProjectMetaTableFilterComposer,
      $$ProjectMetaTableOrderingComposer,
      $$ProjectMetaTableAnnotationComposer,
      $$ProjectMetaTableCreateCompanionBuilder,
      $$ProjectMetaTableUpdateCompanionBuilder,
      (
        ProjectMetaData,
        BaseReferences<_$AppDatabase, $ProjectMetaTable, ProjectMetaData>,
      ),
      ProjectMetaData,
      PrefetchHooks Function()
    >;
typedef $$InputFilesTableCreateCompanionBuilder =
    InputFilesCompanion Function({
      required String id,
      required String originalName,
      required String absolutePath,
      required String kind,
      required int sizeBytes,
      required String sha256,
      required DateTime addedAt,
      Value<bool> enabled,
      required String scanState,
      Value<String?> rejectReason,
      Value<int> rowid,
    });
typedef $$InputFilesTableUpdateCompanionBuilder =
    InputFilesCompanion Function({
      Value<String> id,
      Value<String> originalName,
      Value<String> absolutePath,
      Value<String> kind,
      Value<int> sizeBytes,
      Value<String> sha256,
      Value<DateTime> addedAt,
      Value<bool> enabled,
      Value<String> scanState,
      Value<String?> rejectReason,
      Value<int> rowid,
    });

final class $$InputFilesTableReferences
    extends BaseReferences<_$AppDatabase, $InputFilesTable, InputFile> {
  $$InputFilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$NamespacesTable, List<Namespace>>
  _namespacesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.namespaces,
    aliasName: 'input_files__id__namespaces__input_file_id',
  );

  $$NamespacesTableProcessedTableManager get namespacesRefs {
    final manager = $$NamespacesTableTableManager(
      $_db,
      $_db.namespaces,
    ).filter((f) => f.inputFileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_namespacesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InputFilesTableFilterComposer
    extends Composer<_$AppDatabase, $InputFilesTable> {
  $$InputFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get absolutePath => $composableBuilder(
    column: $table.absolutePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scanState => $composableBuilder(
    column: $table.scanState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rejectReason => $composableBuilder(
    column: $table.rejectReason,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> namespacesRefs(
    Expression<bool> Function($$NamespacesTableFilterComposer f) f,
  ) {
    final $$NamespacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.namespaces,
      getReferencedColumn: (t) => t.inputFileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NamespacesTableFilterComposer(
            $db: $db,
            $table: $db.namespaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InputFilesTableOrderingComposer
    extends Composer<_$AppDatabase, $InputFilesTable> {
  $$InputFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get absolutePath => $composableBuilder(
    column: $table.absolutePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scanState => $composableBuilder(
    column: $table.scanState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rejectReason => $composableBuilder(
    column: $table.rejectReason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InputFilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InputFilesTable> {
  $$InputFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get absolutePath => $composableBuilder(
    column: $table.absolutePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<String> get scanState =>
      $composableBuilder(column: $table.scanState, builder: (column) => column);

  GeneratedColumn<String> get rejectReason => $composableBuilder(
    column: $table.rejectReason,
    builder: (column) => column,
  );

  Expression<T> namespacesRefs<T extends Object>(
    Expression<T> Function($$NamespacesTableAnnotationComposer a) f,
  ) {
    final $$NamespacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.namespaces,
      getReferencedColumn: (t) => t.inputFileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NamespacesTableAnnotationComposer(
            $db: $db,
            $table: $db.namespaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InputFilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InputFilesTable,
          InputFile,
          $$InputFilesTableFilterComposer,
          $$InputFilesTableOrderingComposer,
          $$InputFilesTableAnnotationComposer,
          $$InputFilesTableCreateCompanionBuilder,
          $$InputFilesTableUpdateCompanionBuilder,
          (InputFile, $$InputFilesTableReferences),
          InputFile,
          PrefetchHooks Function({bool namespacesRefs})
        > {
  $$InputFilesTableTableManager(_$AppDatabase db, $InputFilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InputFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InputFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InputFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> originalName = const Value.absent(),
                Value<String> absolutePath = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<String> scanState = const Value.absent(),
                Value<String?> rejectReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InputFilesCompanion(
                id: id,
                originalName: originalName,
                absolutePath: absolutePath,
                kind: kind,
                sizeBytes: sizeBytes,
                sha256: sha256,
                addedAt: addedAt,
                enabled: enabled,
                scanState: scanState,
                rejectReason: rejectReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String originalName,
                required String absolutePath,
                required String kind,
                required int sizeBytes,
                required String sha256,
                required DateTime addedAt,
                Value<bool> enabled = const Value.absent(),
                required String scanState,
                Value<String?> rejectReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InputFilesCompanion.insert(
                id: id,
                originalName: originalName,
                absolutePath: absolutePath,
                kind: kind,
                sizeBytes: sizeBytes,
                sha256: sha256,
                addedAt: addedAt,
                enabled: enabled,
                scanState: scanState,
                rejectReason: rejectReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InputFilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({namespacesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (namespacesRefs) db.namespaces],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (namespacesRefs)
                    await $_getPrefetchedData<
                      InputFile,
                      $InputFilesTable,
                      Namespace
                    >(
                      currentTable: table,
                      referencedTable: $$InputFilesTableReferences
                          ._namespacesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$InputFilesTableReferences(
                            db,
                            table,
                            p0,
                          ).namespacesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.inputFileId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$InputFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InputFilesTable,
      InputFile,
      $$InputFilesTableFilterComposer,
      $$InputFilesTableOrderingComposer,
      $$InputFilesTableAnnotationComposer,
      $$InputFilesTableCreateCompanionBuilder,
      $$InputFilesTableUpdateCompanionBuilder,
      (InputFile, $$InputFilesTableReferences),
      InputFile,
      PrefetchHooks Function({bool namespacesRefs})
    >;
typedef $$NamespacesTableCreateCompanionBuilder =
    NamespacesCompanion Function({
      required String id,
      required String inputFileId,
      required String name,
      required String state,
      Value<String?> sourceOverride,
      Value<bool> excluded,
      Value<bool> selected,
      Value<int> keyCount,
      Value<String?> errorMessage,
      Value<int?> errorLine,
      Value<int> rowid,
    });
typedef $$NamespacesTableUpdateCompanionBuilder =
    NamespacesCompanion Function({
      Value<String> id,
      Value<String> inputFileId,
      Value<String> name,
      Value<String> state,
      Value<String?> sourceOverride,
      Value<bool> excluded,
      Value<bool> selected,
      Value<int> keyCount,
      Value<String?> errorMessage,
      Value<int?> errorLine,
      Value<int> rowid,
    });

final class $$NamespacesTableReferences
    extends BaseReferences<_$AppDatabase, $NamespacesTable, Namespace> {
  $$NamespacesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $InputFilesTable _inputFileIdTable(_$AppDatabase db) =>
      db.inputFiles.createAlias('namespaces__input_file_id__input_files__id');

  $$InputFilesTableProcessedTableManager get inputFileId {
    final $_column = $_itemColumn<String>('input_file_id')!;

    final manager = $$InputFilesTableTableManager(
      $_db,
      $_db.inputFiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_inputFileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$LanguageFilesTable, List<LanguageFile>>
  _languageFilesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.languageFiles,
    aliasName: 'namespaces__id__language_files__namespace_id',
  );

  $$LanguageFilesTableProcessedTableManager get languageFilesRefs {
    final manager = $$LanguageFilesTableTableManager(
      $_db,
      $_db.languageFiles,
    ).filter((f) => f.namespaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_languageFilesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EntriesTable, List<Entry>> _entriesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.entries,
    aliasName: 'namespaces__id__entries__namespace_id',
  );

  $$EntriesTableProcessedTableManager get entriesRefs {
    final manager = $$EntriesTableTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.namespaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_entriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NamespacesTableFilterComposer
    extends Composer<_$AppDatabase, $NamespacesTable> {
  $$NamespacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceOverride => $composableBuilder(
    column: $table.sourceOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get excluded => $composableBuilder(
    column: $table.excluded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get selected => $composableBuilder(
    column: $table.selected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get keyCount => $composableBuilder(
    column: $table.keyCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get errorLine => $composableBuilder(
    column: $table.errorLine,
    builder: (column) => ColumnFilters(column),
  );

  $$InputFilesTableFilterComposer get inputFileId {
    final $$InputFilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inputFileId,
      referencedTable: $db.inputFiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InputFilesTableFilterComposer(
            $db: $db,
            $table: $db.inputFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> languageFilesRefs(
    Expression<bool> Function($$LanguageFilesTableFilterComposer f) f,
  ) {
    final $$LanguageFilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.languageFiles,
      getReferencedColumn: (t) => t.namespaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LanguageFilesTableFilterComposer(
            $db: $db,
            $table: $db.languageFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> entriesRefs(
    Expression<bool> Function($$EntriesTableFilterComposer f) f,
  ) {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.namespaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NamespacesTableOrderingComposer
    extends Composer<_$AppDatabase, $NamespacesTable> {
  $$NamespacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceOverride => $composableBuilder(
    column: $table.sourceOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get excluded => $composableBuilder(
    column: $table.excluded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get selected => $composableBuilder(
    column: $table.selected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get keyCount => $composableBuilder(
    column: $table.keyCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get errorLine => $composableBuilder(
    column: $table.errorLine,
    builder: (column) => ColumnOrderings(column),
  );

  $$InputFilesTableOrderingComposer get inputFileId {
    final $$InputFilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inputFileId,
      referencedTable: $db.inputFiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InputFilesTableOrderingComposer(
            $db: $db,
            $table: $db.inputFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NamespacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NamespacesTable> {
  $$NamespacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get sourceOverride => $composableBuilder(
    column: $table.sourceOverride,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get excluded =>
      $composableBuilder(column: $table.excluded, builder: (column) => column);

  GeneratedColumn<bool> get selected =>
      $composableBuilder(column: $table.selected, builder: (column) => column);

  GeneratedColumn<int> get keyCount =>
      $composableBuilder(column: $table.keyCount, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get errorLine =>
      $composableBuilder(column: $table.errorLine, builder: (column) => column);

  $$InputFilesTableAnnotationComposer get inputFileId {
    final $$InputFilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inputFileId,
      referencedTable: $db.inputFiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InputFilesTableAnnotationComposer(
            $db: $db,
            $table: $db.inputFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> languageFilesRefs<T extends Object>(
    Expression<T> Function($$LanguageFilesTableAnnotationComposer a) f,
  ) {
    final $$LanguageFilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.languageFiles,
      getReferencedColumn: (t) => t.namespaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LanguageFilesTableAnnotationComposer(
            $db: $db,
            $table: $db.languageFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> entriesRefs<T extends Object>(
    Expression<T> Function($$EntriesTableAnnotationComposer a) f,
  ) {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.namespaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NamespacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NamespacesTable,
          Namespace,
          $$NamespacesTableFilterComposer,
          $$NamespacesTableOrderingComposer,
          $$NamespacesTableAnnotationComposer,
          $$NamespacesTableCreateCompanionBuilder,
          $$NamespacesTableUpdateCompanionBuilder,
          (Namespace, $$NamespacesTableReferences),
          Namespace,
          PrefetchHooks Function({
            bool inputFileId,
            bool languageFilesRefs,
            bool entriesRefs,
          })
        > {
  $$NamespacesTableTableManager(_$AppDatabase db, $NamespacesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NamespacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NamespacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NamespacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> inputFileId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String?> sourceOverride = const Value.absent(),
                Value<bool> excluded = const Value.absent(),
                Value<bool> selected = const Value.absent(),
                Value<int> keyCount = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int?> errorLine = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NamespacesCompanion(
                id: id,
                inputFileId: inputFileId,
                name: name,
                state: state,
                sourceOverride: sourceOverride,
                excluded: excluded,
                selected: selected,
                keyCount: keyCount,
                errorMessage: errorMessage,
                errorLine: errorLine,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String inputFileId,
                required String name,
                required String state,
                Value<String?> sourceOverride = const Value.absent(),
                Value<bool> excluded = const Value.absent(),
                Value<bool> selected = const Value.absent(),
                Value<int> keyCount = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int?> errorLine = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NamespacesCompanion.insert(
                id: id,
                inputFileId: inputFileId,
                name: name,
                state: state,
                sourceOverride: sourceOverride,
                excluded: excluded,
                selected: selected,
                keyCount: keyCount,
                errorMessage: errorMessage,
                errorLine: errorLine,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NamespacesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                inputFileId = false,
                languageFilesRefs = false,
                entriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (languageFilesRefs) db.languageFiles,
                    if (entriesRefs) db.entries,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (inputFileId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.inputFileId,
                                    referencedTable: $$NamespacesTableReferences
                                        ._inputFileIdTable(db),
                                    referencedColumn:
                                        $$NamespacesTableReferences
                                            ._inputFileIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (languageFilesRefs)
                        await $_getPrefetchedData<
                          Namespace,
                          $NamespacesTable,
                          LanguageFile
                        >(
                          currentTable: table,
                          referencedTable: $$NamespacesTableReferences
                              ._languageFilesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NamespacesTableReferences(
                                db,
                                table,
                                p0,
                              ).languageFilesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.namespaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (entriesRefs)
                        await $_getPrefetchedData<
                          Namespace,
                          $NamespacesTable,
                          Entry
                        >(
                          currentTable: table,
                          referencedTable: $$NamespacesTableReferences
                              ._entriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NamespacesTableReferences(
                                db,
                                table,
                                p0,
                              ).entriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.namespaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$NamespacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NamespacesTable,
      Namespace,
      $$NamespacesTableFilterComposer,
      $$NamespacesTableOrderingComposer,
      $$NamespacesTableAnnotationComposer,
      $$NamespacesTableCreateCompanionBuilder,
      $$NamespacesTableUpdateCompanionBuilder,
      (Namespace, $$NamespacesTableReferences),
      Namespace,
      PrefetchHooks Function({
        bool inputFileId,
        bool languageFilesRefs,
        bool entriesRefs,
      })
    >;
typedef $$LanguageFilesTableCreateCompanionBuilder =
    LanguageFilesCompanion Function({
      required String id,
      required String namespaceId,
      required String rawCode,
      required String code,
      required String entryPath,
      required int keyCount,
      required String role,
      Value<int> rowid,
    });
typedef $$LanguageFilesTableUpdateCompanionBuilder =
    LanguageFilesCompanion Function({
      Value<String> id,
      Value<String> namespaceId,
      Value<String> rawCode,
      Value<String> code,
      Value<String> entryPath,
      Value<int> keyCount,
      Value<String> role,
      Value<int> rowid,
    });

final class $$LanguageFilesTableReferences
    extends BaseReferences<_$AppDatabase, $LanguageFilesTable, LanguageFile> {
  $$LanguageFilesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NamespacesTable _namespaceIdTable(_$AppDatabase db) =>
      db.namespaces.createAlias('language_files__namespace_id__namespaces__id');

  $$NamespacesTableProcessedTableManager get namespaceId {
    final $_column = $_itemColumn<String>('namespace_id')!;

    final manager = $$NamespacesTableTableManager(
      $_db,
      $_db.namespaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_namespaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LanguageFilesTableFilterComposer
    extends Composer<_$AppDatabase, $LanguageFilesTable> {
  $$LanguageFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawCode => $composableBuilder(
    column: $table.rawCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryPath => $composableBuilder(
    column: $table.entryPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get keyCount => $composableBuilder(
    column: $table.keyCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  $$NamespacesTableFilterComposer get namespaceId {
    final $$NamespacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.namespaceId,
      referencedTable: $db.namespaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NamespacesTableFilterComposer(
            $db: $db,
            $table: $db.namespaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LanguageFilesTableOrderingComposer
    extends Composer<_$AppDatabase, $LanguageFilesTable> {
  $$LanguageFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawCode => $composableBuilder(
    column: $table.rawCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryPath => $composableBuilder(
    column: $table.entryPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get keyCount => $composableBuilder(
    column: $table.keyCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  $$NamespacesTableOrderingComposer get namespaceId {
    final $$NamespacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.namespaceId,
      referencedTable: $db.namespaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NamespacesTableOrderingComposer(
            $db: $db,
            $table: $db.namespaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LanguageFilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LanguageFilesTable> {
  $$LanguageFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rawCode =>
      $composableBuilder(column: $table.rawCode, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get entryPath =>
      $composableBuilder(column: $table.entryPath, builder: (column) => column);

  GeneratedColumn<int> get keyCount =>
      $composableBuilder(column: $table.keyCount, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  $$NamespacesTableAnnotationComposer get namespaceId {
    final $$NamespacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.namespaceId,
      referencedTable: $db.namespaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NamespacesTableAnnotationComposer(
            $db: $db,
            $table: $db.namespaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LanguageFilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LanguageFilesTable,
          LanguageFile,
          $$LanguageFilesTableFilterComposer,
          $$LanguageFilesTableOrderingComposer,
          $$LanguageFilesTableAnnotationComposer,
          $$LanguageFilesTableCreateCompanionBuilder,
          $$LanguageFilesTableUpdateCompanionBuilder,
          (LanguageFile, $$LanguageFilesTableReferences),
          LanguageFile,
          PrefetchHooks Function({bool namespaceId})
        > {
  $$LanguageFilesTableTableManager(_$AppDatabase db, $LanguageFilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LanguageFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LanguageFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LanguageFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> namespaceId = const Value.absent(),
                Value<String> rawCode = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> entryPath = const Value.absent(),
                Value<int> keyCount = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LanguageFilesCompanion(
                id: id,
                namespaceId: namespaceId,
                rawCode: rawCode,
                code: code,
                entryPath: entryPath,
                keyCount: keyCount,
                role: role,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String namespaceId,
                required String rawCode,
                required String code,
                required String entryPath,
                required int keyCount,
                required String role,
                Value<int> rowid = const Value.absent(),
              }) => LanguageFilesCompanion.insert(
                id: id,
                namespaceId: namespaceId,
                rawCode: rawCode,
                code: code,
                entryPath: entryPath,
                keyCount: keyCount,
                role: role,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LanguageFilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({namespaceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (namespaceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.namespaceId,
                                referencedTable: $$LanguageFilesTableReferences
                                    ._namespaceIdTable(db),
                                referencedColumn: $$LanguageFilesTableReferences
                                    ._namespaceIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LanguageFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LanguageFilesTable,
      LanguageFile,
      $$LanguageFilesTableFilterComposer,
      $$LanguageFilesTableOrderingComposer,
      $$LanguageFilesTableAnnotationComposer,
      $$LanguageFilesTableCreateCompanionBuilder,
      $$LanguageFilesTableUpdateCompanionBuilder,
      (LanguageFile, $$LanguageFilesTableReferences),
      LanguageFile,
      PrefetchHooks Function({bool namespaceId})
    >;
typedef $$EntriesTableCreateCompanionBuilder =
    EntriesCompanion Function({
      required String id,
      required String namespaceId,
      required String key,
      Value<String?> keyCategory,
      required int keyOrder,
      required String sourceText,
      Value<String?> existingTranslation,
      Value<String?> newTranslation,
      Value<String?> userTranslation,
      required String status,
      Value<String?> providerId,
      Value<String?> modelId,
      Value<bool> userEdited,
      Value<String?> validationJson,
      Value<String?> warningsJson,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$EntriesTableUpdateCompanionBuilder =
    EntriesCompanion Function({
      Value<String> id,
      Value<String> namespaceId,
      Value<String> key,
      Value<String?> keyCategory,
      Value<int> keyOrder,
      Value<String> sourceText,
      Value<String?> existingTranslation,
      Value<String?> newTranslation,
      Value<String?> userTranslation,
      Value<String> status,
      Value<String?> providerId,
      Value<String?> modelId,
      Value<bool> userEdited,
      Value<String?> validationJson,
      Value<String?> warningsJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$EntriesTableReferences
    extends BaseReferences<_$AppDatabase, $EntriesTable, Entry> {
  $$EntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $NamespacesTable _namespaceIdTable(_$AppDatabase db) =>
      db.namespaces.createAlias('entries__namespace_id__namespaces__id');

  $$NamespacesTableProcessedTableManager get namespaceId {
    final $_column = $_itemColumn<String>('namespace_id')!;

    final manager = $$NamespacesTableTableManager(
      $_db,
      $_db.namespaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_namespaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EntriesTableFilterComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keyCategory => $composableBuilder(
    column: $table.keyCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get keyOrder => $composableBuilder(
    column: $table.keyOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceText => $composableBuilder(
    column: $table.sourceText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get existingTranslation => $composableBuilder(
    column: $table.existingTranslation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newTranslation => $composableBuilder(
    column: $table.newTranslation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userTranslation => $composableBuilder(
    column: $table.userTranslation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnFilters<bool> get userEdited => $composableBuilder(
    column: $table.userEdited,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get validationJson => $composableBuilder(
    column: $table.validationJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get warningsJson => $composableBuilder(
    column: $table.warningsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$NamespacesTableFilterComposer get namespaceId {
    final $$NamespacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.namespaceId,
      referencedTable: $db.namespaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NamespacesTableFilterComposer(
            $db: $db,
            $table: $db.namespaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keyCategory => $composableBuilder(
    column: $table.keyCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get keyOrder => $composableBuilder(
    column: $table.keyOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceText => $composableBuilder(
    column: $table.sourceText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get existingTranslation => $composableBuilder(
    column: $table.existingTranslation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newTranslation => $composableBuilder(
    column: $table.newTranslation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userTranslation => $composableBuilder(
    column: $table.userTranslation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnOrderings<bool> get userEdited => $composableBuilder(
    column: $table.userEdited,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get validationJson => $composableBuilder(
    column: $table.validationJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get warningsJson => $composableBuilder(
    column: $table.warningsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$NamespacesTableOrderingComposer get namespaceId {
    final $$NamespacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.namespaceId,
      referencedTable: $db.namespaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NamespacesTableOrderingComposer(
            $db: $db,
            $table: $db.namespaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get keyCategory => $composableBuilder(
    column: $table.keyCategory,
    builder: (column) => column,
  );

  GeneratedColumn<int> get keyOrder =>
      $composableBuilder(column: $table.keyOrder, builder: (column) => column);

  GeneratedColumn<String> get sourceText => $composableBuilder(
    column: $table.sourceText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get existingTranslation => $composableBuilder(
    column: $table.existingTranslation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get newTranslation => $composableBuilder(
    column: $table.newTranslation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userTranslation => $composableBuilder(
    column: $table.userTranslation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<bool> get userEdited => $composableBuilder(
    column: $table.userEdited,
    builder: (column) => column,
  );

  GeneratedColumn<String> get validationJson => $composableBuilder(
    column: $table.validationJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get warningsJson => $composableBuilder(
    column: $table.warningsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$NamespacesTableAnnotationComposer get namespaceId {
    final $$NamespacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.namespaceId,
      referencedTable: $db.namespaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NamespacesTableAnnotationComposer(
            $db: $db,
            $table: $db.namespaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntriesTable,
          Entry,
          $$EntriesTableFilterComposer,
          $$EntriesTableOrderingComposer,
          $$EntriesTableAnnotationComposer,
          $$EntriesTableCreateCompanionBuilder,
          $$EntriesTableUpdateCompanionBuilder,
          (Entry, $$EntriesTableReferences),
          Entry,
          PrefetchHooks Function({bool namespaceId})
        > {
  $$EntriesTableTableManager(_$AppDatabase db, $EntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> namespaceId = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String?> keyCategory = const Value.absent(),
                Value<int> keyOrder = const Value.absent(),
                Value<String> sourceText = const Value.absent(),
                Value<String?> existingTranslation = const Value.absent(),
                Value<String?> newTranslation = const Value.absent(),
                Value<String?> userTranslation = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> providerId = const Value.absent(),
                Value<String?> modelId = const Value.absent(),
                Value<bool> userEdited = const Value.absent(),
                Value<String?> validationJson = const Value.absent(),
                Value<String?> warningsJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntriesCompanion(
                id: id,
                namespaceId: namespaceId,
                key: key,
                keyCategory: keyCategory,
                keyOrder: keyOrder,
                sourceText: sourceText,
                existingTranslation: existingTranslation,
                newTranslation: newTranslation,
                userTranslation: userTranslation,
                status: status,
                providerId: providerId,
                modelId: modelId,
                userEdited: userEdited,
                validationJson: validationJson,
                warningsJson: warningsJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String namespaceId,
                required String key,
                Value<String?> keyCategory = const Value.absent(),
                required int keyOrder,
                required String sourceText,
                Value<String?> existingTranslation = const Value.absent(),
                Value<String?> newTranslation = const Value.absent(),
                Value<String?> userTranslation = const Value.absent(),
                required String status,
                Value<String?> providerId = const Value.absent(),
                Value<String?> modelId = const Value.absent(),
                Value<bool> userEdited = const Value.absent(),
                Value<String?> validationJson = const Value.absent(),
                Value<String?> warningsJson = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => EntriesCompanion.insert(
                id: id,
                namespaceId: namespaceId,
                key: key,
                keyCategory: keyCategory,
                keyOrder: keyOrder,
                sourceText: sourceText,
                existingTranslation: existingTranslation,
                newTranslation: newTranslation,
                userTranslation: userTranslation,
                status: status,
                providerId: providerId,
                modelId: modelId,
                userEdited: userEdited,
                validationJson: validationJson,
                warningsJson: warningsJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({namespaceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (namespaceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.namespaceId,
                                referencedTable: $$EntriesTableReferences
                                    ._namespaceIdTable(db),
                                referencedColumn: $$EntriesTableReferences
                                    ._namespaceIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntriesTable,
      Entry,
      $$EntriesTableFilterComposer,
      $$EntriesTableOrderingComposer,
      $$EntriesTableAnnotationComposer,
      $$EntriesTableCreateCompanionBuilder,
      $$EntriesTableUpdateCompanionBuilder,
      (Entry, $$EntriesTableReferences),
      Entry,
      PrefetchHooks Function({bool namespaceId})
    >;
typedef $$ConflictsTableCreateCompanionBuilder =
    ConflictsCompanion Function({
      required String id,
      required String namespaceName,
      required String key,
      required String participantsJson,
      Value<String?> resolvedEntryId,
      Value<bool> resolved,
      Value<int> rowid,
    });
typedef $$ConflictsTableUpdateCompanionBuilder =
    ConflictsCompanion Function({
      Value<String> id,
      Value<String> namespaceName,
      Value<String> key,
      Value<String> participantsJson,
      Value<String?> resolvedEntryId,
      Value<bool> resolved,
      Value<int> rowid,
    });

class $$ConflictsTableFilterComposer
    extends Composer<_$AppDatabase, $ConflictsTable> {
  $$ConflictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get namespaceName => $composableBuilder(
    column: $table.namespaceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get participantsJson => $composableBuilder(
    column: $table.participantsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolvedEntryId => $composableBuilder(
    column: $table.resolvedEntryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get resolved => $composableBuilder(
    column: $table.resolved,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConflictsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConflictsTable> {
  $$ConflictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get namespaceName => $composableBuilder(
    column: $table.namespaceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get participantsJson => $composableBuilder(
    column: $table.participantsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolvedEntryId => $composableBuilder(
    column: $table.resolvedEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get resolved => $composableBuilder(
    column: $table.resolved,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConflictsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConflictsTable> {
  $$ConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get namespaceName => $composableBuilder(
    column: $table.namespaceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get participantsJson => $composableBuilder(
    column: $table.participantsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resolvedEntryId => $composableBuilder(
    column: $table.resolvedEntryId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get resolved =>
      $composableBuilder(column: $table.resolved, builder: (column) => column);
}

class $$ConflictsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConflictsTable,
          Conflict,
          $$ConflictsTableFilterComposer,
          $$ConflictsTableOrderingComposer,
          $$ConflictsTableAnnotationComposer,
          $$ConflictsTableCreateCompanionBuilder,
          $$ConflictsTableUpdateCompanionBuilder,
          (Conflict, BaseReferences<_$AppDatabase, $ConflictsTable, Conflict>),
          Conflict,
          PrefetchHooks Function()
        > {
  $$ConflictsTableTableManager(_$AppDatabase db, $ConflictsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> namespaceName = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> participantsJson = const Value.absent(),
                Value<String?> resolvedEntryId = const Value.absent(),
                Value<bool> resolved = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConflictsCompanion(
                id: id,
                namespaceName: namespaceName,
                key: key,
                participantsJson: participantsJson,
                resolvedEntryId: resolvedEntryId,
                resolved: resolved,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String namespaceName,
                required String key,
                required String participantsJson,
                Value<String?> resolvedEntryId = const Value.absent(),
                Value<bool> resolved = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConflictsCompanion.insert(
                id: id,
                namespaceName: namespaceName,
                key: key,
                participantsJson: participantsJson,
                resolvedEntryId: resolvedEntryId,
                resolved: resolved,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConflictsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConflictsTable,
      Conflict,
      $$ConflictsTableFilterComposer,
      $$ConflictsTableOrderingComposer,
      $$ConflictsTableAnnotationComposer,
      $$ConflictsTableCreateCompanionBuilder,
      $$ConflictsTableUpdateCompanionBuilder,
      (Conflict, BaseReferences<_$AppDatabase, $ConflictsTable, Conflict>),
      Conflict,
      PrefetchHooks Function()
    >;
typedef $$ExportRecordsTableCreateCompanionBuilder =
    ExportRecordsCompanion Function({
      required String id,
      required DateTime createdAt,
      required String format,
      required String outputPath,
      required int namespaceCount,
      required int entryCount,
      Value<String?> reportPath,
      Value<int> rowid,
    });
typedef $$ExportRecordsTableUpdateCompanionBuilder =
    ExportRecordsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<String> format,
      Value<String> outputPath,
      Value<int> namespaceCount,
      Value<int> entryCount,
      Value<String?> reportPath,
      Value<int> rowid,
    });

class $$ExportRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ExportRecordsTable> {
  $$ExportRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outputPath => $composableBuilder(
    column: $table.outputPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get namespaceCount => $composableBuilder(
    column: $table.namespaceCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entryCount => $composableBuilder(
    column: $table.entryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reportPath => $composableBuilder(
    column: $table.reportPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExportRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExportRecordsTable> {
  $$ExportRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outputPath => $composableBuilder(
    column: $table.outputPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get namespaceCount => $composableBuilder(
    column: $table.namespaceCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entryCount => $composableBuilder(
    column: $table.entryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportPath => $composableBuilder(
    column: $table.reportPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExportRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExportRecordsTable> {
  $$ExportRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get outputPath => $composableBuilder(
    column: $table.outputPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get namespaceCount => $composableBuilder(
    column: $table.namespaceCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get entryCount => $composableBuilder(
    column: $table.entryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reportPath => $composableBuilder(
    column: $table.reportPath,
    builder: (column) => column,
  );
}

class $$ExportRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExportRecordsTable,
          ExportRecord,
          $$ExportRecordsTableFilterComposer,
          $$ExportRecordsTableOrderingComposer,
          $$ExportRecordsTableAnnotationComposer,
          $$ExportRecordsTableCreateCompanionBuilder,
          $$ExportRecordsTableUpdateCompanionBuilder,
          (
            ExportRecord,
            BaseReferences<_$AppDatabase, $ExportRecordsTable, ExportRecord>,
          ),
          ExportRecord,
          PrefetchHooks Function()
        > {
  $$ExportRecordsTableTableManager(_$AppDatabase db, $ExportRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExportRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExportRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExportRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<String> outputPath = const Value.absent(),
                Value<int> namespaceCount = const Value.absent(),
                Value<int> entryCount = const Value.absent(),
                Value<String?> reportPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExportRecordsCompanion(
                id: id,
                createdAt: createdAt,
                format: format,
                outputPath: outputPath,
                namespaceCount: namespaceCount,
                entryCount: entryCount,
                reportPath: reportPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required String format,
                required String outputPath,
                required int namespaceCount,
                required int entryCount,
                Value<String?> reportPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExportRecordsCompanion.insert(
                id: id,
                createdAt: createdAt,
                format: format,
                outputPath: outputPath,
                namespaceCount: namespaceCount,
                entryCount: entryCount,
                reportPath: reportPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExportRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExportRecordsTable,
      ExportRecord,
      $$ExportRecordsTableFilterComposer,
      $$ExportRecordsTableOrderingComposer,
      $$ExportRecordsTableAnnotationComposer,
      $$ExportRecordsTableCreateCompanionBuilder,
      $$ExportRecordsTableUpdateCompanionBuilder,
      (
        ExportRecord,
        BaseReferences<_$AppDatabase, $ExportRecordsTable, ExportRecord>,
      ),
      ExportRecord,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProjectMetaTableTableManager get projectMeta =>
      $$ProjectMetaTableTableManager(_db, _db.projectMeta);
  $$InputFilesTableTableManager get inputFiles =>
      $$InputFilesTableTableManager(_db, _db.inputFiles);
  $$NamespacesTableTableManager get namespaces =>
      $$NamespacesTableTableManager(_db, _db.namespaces);
  $$LanguageFilesTableTableManager get languageFiles =>
      $$LanguageFilesTableTableManager(_db, _db.languageFiles);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db, _db.entries);
  $$ConflictsTableTableManager get conflicts =>
      $$ConflictsTableTableManager(_db, _db.conflicts);
  $$ExportRecordsTableTableManager get exportRecords =>
      $$ExportRecordsTableTableManager(_db, _db.exportRecords);
}
