// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'glossary_database.dart';

// ignore_for_file: type=lint
class $GlobalGlossaryTermsTable extends GlobalGlossaryTerms
    with TableInfo<$GlobalGlossaryTermsTable, GlobalGlossaryTermRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GlobalGlossaryTermsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTermMeta = const VerificationMeta(
    'sourceTerm',
  );
  @override
  late final GeneratedColumn<String> sourceTerm = GeneratedColumn<String>(
    'source_term',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTermMeta = const VerificationMeta(
    'targetTerm',
  );
  @override
  late final GeneratedColumn<String> targetTerm = GeneratedColumn<String>(
    'target_term',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceLangMeta = const VerificationMeta(
    'sourceLang',
  );
  @override
  late final GeneratedColumn<String> sourceLang = GeneratedColumn<String>(
    'source_lang',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetLangMeta = const VerificationMeta(
    'targetLang',
  );
  @override
  late final GeneratedColumn<String> targetLang = GeneratedColumn<String>(
    'target_lang',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _namespaceMeta = const VerificationMeta(
    'namespace',
  );
  @override
  late final GeneratedColumn<String> namespace = GeneratedColumn<String>(
    'namespace',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caseSensitiveMeta = const VerificationMeta(
    'caseSensitive',
  );
  @override
  late final GeneratedColumn<bool> caseSensitive = GeneratedColumn<bool>(
    'case_sensitive',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("case_sensitive" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
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
    sourceTerm,
    targetTerm,
    sourceLang,
    targetLang,
    namespace,
    caseSensitive,
    note,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'glossary_terms';
  @override
  VerificationContext validateIntegrity(
    Insertable<GlobalGlossaryTermRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_term')) {
      context.handle(
        _sourceTermMeta,
        sourceTerm.isAcceptableOrUnknown(data['source_term']!, _sourceTermMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTermMeta);
    }
    if (data.containsKey('target_term')) {
      context.handle(
        _targetTermMeta,
        targetTerm.isAcceptableOrUnknown(data['target_term']!, _targetTermMeta),
      );
    } else if (isInserting) {
      context.missing(_targetTermMeta);
    }
    if (data.containsKey('source_lang')) {
      context.handle(
        _sourceLangMeta,
        sourceLang.isAcceptableOrUnknown(data['source_lang']!, _sourceLangMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceLangMeta);
    }
    if (data.containsKey('target_lang')) {
      context.handle(
        _targetLangMeta,
        targetLang.isAcceptableOrUnknown(data['target_lang']!, _targetLangMeta),
      );
    } else if (isInserting) {
      context.missing(_targetLangMeta);
    }
    if (data.containsKey('namespace')) {
      context.handle(
        _namespaceMeta,
        namespace.isAcceptableOrUnknown(data['namespace']!, _namespaceMeta),
      );
    }
    if (data.containsKey('case_sensitive')) {
      context.handle(
        _caseSensitiveMeta,
        caseSensitive.isAcceptableOrUnknown(
          data['case_sensitive']!,
          _caseSensitiveMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
  GlobalGlossaryTermRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GlobalGlossaryTermRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceTerm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_term'],
      )!,
      targetTerm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_term'],
      )!,
      sourceLang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_lang'],
      )!,
      targetLang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_lang'],
      )!,
      namespace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}namespace'],
      ),
      caseSensitive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}case_sensitive'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $GlobalGlossaryTermsTable createAlias(String alias) {
    return $GlobalGlossaryTermsTable(attachedDatabase, alias);
  }
}

class GlobalGlossaryTermRow extends DataClass
    implements Insertable<GlobalGlossaryTermRow> {
  final String id;
  final String sourceTerm;
  final String targetTerm;
  final String sourceLang;
  final String targetLang;
  final String? namespace;
  final bool caseSensitive;
  final String? note;
  final DateTime updatedAt;
  const GlobalGlossaryTermRow({
    required this.id,
    required this.sourceTerm,
    required this.targetTerm,
    required this.sourceLang,
    required this.targetLang,
    this.namespace,
    required this.caseSensitive,
    this.note,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_term'] = Variable<String>(sourceTerm);
    map['target_term'] = Variable<String>(targetTerm);
    map['source_lang'] = Variable<String>(sourceLang);
    map['target_lang'] = Variable<String>(targetLang);
    if (!nullToAbsent || namespace != null) {
      map['namespace'] = Variable<String>(namespace);
    }
    map['case_sensitive'] = Variable<bool>(caseSensitive);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GlobalGlossaryTermsCompanion toCompanion(bool nullToAbsent) {
    return GlobalGlossaryTermsCompanion(
      id: Value(id),
      sourceTerm: Value(sourceTerm),
      targetTerm: Value(targetTerm),
      sourceLang: Value(sourceLang),
      targetLang: Value(targetLang),
      namespace: namespace == null && nullToAbsent
          ? const Value.absent()
          : Value(namespace),
      caseSensitive: Value(caseSensitive),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      updatedAt: Value(updatedAt),
    );
  }

  factory GlobalGlossaryTermRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GlobalGlossaryTermRow(
      id: serializer.fromJson<String>(json['id']),
      sourceTerm: serializer.fromJson<String>(json['sourceTerm']),
      targetTerm: serializer.fromJson<String>(json['targetTerm']),
      sourceLang: serializer.fromJson<String>(json['sourceLang']),
      targetLang: serializer.fromJson<String>(json['targetLang']),
      namespace: serializer.fromJson<String?>(json['namespace']),
      caseSensitive: serializer.fromJson<bool>(json['caseSensitive']),
      note: serializer.fromJson<String?>(json['note']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceTerm': serializer.toJson<String>(sourceTerm),
      'targetTerm': serializer.toJson<String>(targetTerm),
      'sourceLang': serializer.toJson<String>(sourceLang),
      'targetLang': serializer.toJson<String>(targetLang),
      'namespace': serializer.toJson<String?>(namespace),
      'caseSensitive': serializer.toJson<bool>(caseSensitive),
      'note': serializer.toJson<String?>(note),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GlobalGlossaryTermRow copyWith({
    String? id,
    String? sourceTerm,
    String? targetTerm,
    String? sourceLang,
    String? targetLang,
    Value<String?> namespace = const Value.absent(),
    bool? caseSensitive,
    Value<String?> note = const Value.absent(),
    DateTime? updatedAt,
  }) => GlobalGlossaryTermRow(
    id: id ?? this.id,
    sourceTerm: sourceTerm ?? this.sourceTerm,
    targetTerm: targetTerm ?? this.targetTerm,
    sourceLang: sourceLang ?? this.sourceLang,
    targetLang: targetLang ?? this.targetLang,
    namespace: namespace.present ? namespace.value : this.namespace,
    caseSensitive: caseSensitive ?? this.caseSensitive,
    note: note.present ? note.value : this.note,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  GlobalGlossaryTermRow copyWithCompanion(GlobalGlossaryTermsCompanion data) {
    return GlobalGlossaryTermRow(
      id: data.id.present ? data.id.value : this.id,
      sourceTerm: data.sourceTerm.present
          ? data.sourceTerm.value
          : this.sourceTerm,
      targetTerm: data.targetTerm.present
          ? data.targetTerm.value
          : this.targetTerm,
      sourceLang: data.sourceLang.present
          ? data.sourceLang.value
          : this.sourceLang,
      targetLang: data.targetLang.present
          ? data.targetLang.value
          : this.targetLang,
      namespace: data.namespace.present ? data.namespace.value : this.namespace,
      caseSensitive: data.caseSensitive.present
          ? data.caseSensitive.value
          : this.caseSensitive,
      note: data.note.present ? data.note.value : this.note,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GlobalGlossaryTermRow(')
          ..write('id: $id, ')
          ..write('sourceTerm: $sourceTerm, ')
          ..write('targetTerm: $targetTerm, ')
          ..write('sourceLang: $sourceLang, ')
          ..write('targetLang: $targetLang, ')
          ..write('namespace: $namespace, ')
          ..write('caseSensitive: $caseSensitive, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceTerm,
    targetTerm,
    sourceLang,
    targetLang,
    namespace,
    caseSensitive,
    note,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GlobalGlossaryTermRow &&
          other.id == this.id &&
          other.sourceTerm == this.sourceTerm &&
          other.targetTerm == this.targetTerm &&
          other.sourceLang == this.sourceLang &&
          other.targetLang == this.targetLang &&
          other.namespace == this.namespace &&
          other.caseSensitive == this.caseSensitive &&
          other.note == this.note &&
          other.updatedAt == this.updatedAt);
}

class GlobalGlossaryTermsCompanion
    extends UpdateCompanion<GlobalGlossaryTermRow> {
  final Value<String> id;
  final Value<String> sourceTerm;
  final Value<String> targetTerm;
  final Value<String> sourceLang;
  final Value<String> targetLang;
  final Value<String?> namespace;
  final Value<bool> caseSensitive;
  final Value<String?> note;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const GlobalGlossaryTermsCompanion({
    this.id = const Value.absent(),
    this.sourceTerm = const Value.absent(),
    this.targetTerm = const Value.absent(),
    this.sourceLang = const Value.absent(),
    this.targetLang = const Value.absent(),
    this.namespace = const Value.absent(),
    this.caseSensitive = const Value.absent(),
    this.note = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GlobalGlossaryTermsCompanion.insert({
    required String id,
    required String sourceTerm,
    required String targetTerm,
    required String sourceLang,
    required String targetLang,
    this.namespace = const Value.absent(),
    this.caseSensitive = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourceTerm = Value(sourceTerm),
       targetTerm = Value(targetTerm),
       sourceLang = Value(sourceLang),
       targetLang = Value(targetLang),
       updatedAt = Value(updatedAt);
  static Insertable<GlobalGlossaryTermRow> custom({
    Expression<String>? id,
    Expression<String>? sourceTerm,
    Expression<String>? targetTerm,
    Expression<String>? sourceLang,
    Expression<String>? targetLang,
    Expression<String>? namespace,
    Expression<bool>? caseSensitive,
    Expression<String>? note,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceTerm != null) 'source_term': sourceTerm,
      if (targetTerm != null) 'target_term': targetTerm,
      if (sourceLang != null) 'source_lang': sourceLang,
      if (targetLang != null) 'target_lang': targetLang,
      if (namespace != null) 'namespace': namespace,
      if (caseSensitive != null) 'case_sensitive': caseSensitive,
      if (note != null) 'note': note,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GlobalGlossaryTermsCompanion copyWith({
    Value<String>? id,
    Value<String>? sourceTerm,
    Value<String>? targetTerm,
    Value<String>? sourceLang,
    Value<String>? targetLang,
    Value<String?>? namespace,
    Value<bool>? caseSensitive,
    Value<String?>? note,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return GlobalGlossaryTermsCompanion(
      id: id ?? this.id,
      sourceTerm: sourceTerm ?? this.sourceTerm,
      targetTerm: targetTerm ?? this.targetTerm,
      sourceLang: sourceLang ?? this.sourceLang,
      targetLang: targetLang ?? this.targetLang,
      namespace: namespace ?? this.namespace,
      caseSensitive: caseSensitive ?? this.caseSensitive,
      note: note ?? this.note,
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
    if (sourceTerm.present) {
      map['source_term'] = Variable<String>(sourceTerm.value);
    }
    if (targetTerm.present) {
      map['target_term'] = Variable<String>(targetTerm.value);
    }
    if (sourceLang.present) {
      map['source_lang'] = Variable<String>(sourceLang.value);
    }
    if (targetLang.present) {
      map['target_lang'] = Variable<String>(targetLang.value);
    }
    if (namespace.present) {
      map['namespace'] = Variable<String>(namespace.value);
    }
    if (caseSensitive.present) {
      map['case_sensitive'] = Variable<bool>(caseSensitive.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
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
    return (StringBuffer('GlobalGlossaryTermsCompanion(')
          ..write('id: $id, ')
          ..write('sourceTerm: $sourceTerm, ')
          ..write('targetTerm: $targetTerm, ')
          ..write('sourceLang: $sourceLang, ')
          ..write('targetLang: $targetLang, ')
          ..write('namespace: $namespace, ')
          ..write('caseSensitive: $caseSensitive, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$GlossaryDatabase extends GeneratedDatabase {
  _$GlossaryDatabase(QueryExecutor e) : super(e);
  $GlossaryDatabaseManager get managers => $GlossaryDatabaseManager(this);
  late final $GlobalGlossaryTermsTable globalGlossaryTerms =
      $GlobalGlossaryTermsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [globalGlossaryTerms];
}

typedef $$GlobalGlossaryTermsTableCreateCompanionBuilder =
    GlobalGlossaryTermsCompanion Function({
      required String id,
      required String sourceTerm,
      required String targetTerm,
      required String sourceLang,
      required String targetLang,
      Value<String?> namespace,
      Value<bool> caseSensitive,
      Value<String?> note,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$GlobalGlossaryTermsTableUpdateCompanionBuilder =
    GlobalGlossaryTermsCompanion Function({
      Value<String> id,
      Value<String> sourceTerm,
      Value<String> targetTerm,
      Value<String> sourceLang,
      Value<String> targetLang,
      Value<String?> namespace,
      Value<bool> caseSensitive,
      Value<String?> note,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$GlobalGlossaryTermsTableFilterComposer
    extends Composer<_$GlossaryDatabase, $GlobalGlossaryTermsTable> {
  $$GlobalGlossaryTermsTableFilterComposer({
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

  ColumnFilters<String> get sourceTerm => $composableBuilder(
    column: $table.sourceTerm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetTerm => $composableBuilder(
    column: $table.targetTerm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceLang => $composableBuilder(
    column: $table.sourceLang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetLang => $composableBuilder(
    column: $table.targetLang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get namespace => $composableBuilder(
    column: $table.namespace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get caseSensitive => $composableBuilder(
    column: $table.caseSensitive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GlobalGlossaryTermsTableOrderingComposer
    extends Composer<_$GlossaryDatabase, $GlobalGlossaryTermsTable> {
  $$GlobalGlossaryTermsTableOrderingComposer({
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

  ColumnOrderings<String> get sourceTerm => $composableBuilder(
    column: $table.sourceTerm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetTerm => $composableBuilder(
    column: $table.targetTerm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceLang => $composableBuilder(
    column: $table.sourceLang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetLang => $composableBuilder(
    column: $table.targetLang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get namespace => $composableBuilder(
    column: $table.namespace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get caseSensitive => $composableBuilder(
    column: $table.caseSensitive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GlobalGlossaryTermsTableAnnotationComposer
    extends Composer<_$GlossaryDatabase, $GlobalGlossaryTermsTable> {
  $$GlobalGlossaryTermsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceTerm => $composableBuilder(
    column: $table.sourceTerm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetTerm => $composableBuilder(
    column: $table.targetTerm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceLang => $composableBuilder(
    column: $table.sourceLang,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetLang => $composableBuilder(
    column: $table.targetLang,
    builder: (column) => column,
  );

  GeneratedColumn<String> get namespace =>
      $composableBuilder(column: $table.namespace, builder: (column) => column);

  GeneratedColumn<bool> get caseSensitive => $composableBuilder(
    column: $table.caseSensitive,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$GlobalGlossaryTermsTableTableManager
    extends
        RootTableManager<
          _$GlossaryDatabase,
          $GlobalGlossaryTermsTable,
          GlobalGlossaryTermRow,
          $$GlobalGlossaryTermsTableFilterComposer,
          $$GlobalGlossaryTermsTableOrderingComposer,
          $$GlobalGlossaryTermsTableAnnotationComposer,
          $$GlobalGlossaryTermsTableCreateCompanionBuilder,
          $$GlobalGlossaryTermsTableUpdateCompanionBuilder,
          (
            GlobalGlossaryTermRow,
            BaseReferences<
              _$GlossaryDatabase,
              $GlobalGlossaryTermsTable,
              GlobalGlossaryTermRow
            >,
          ),
          GlobalGlossaryTermRow,
          PrefetchHooks Function()
        > {
  $$GlobalGlossaryTermsTableTableManager(
    _$GlossaryDatabase db,
    $GlobalGlossaryTermsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GlobalGlossaryTermsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GlobalGlossaryTermsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$GlobalGlossaryTermsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sourceTerm = const Value.absent(),
                Value<String> targetTerm = const Value.absent(),
                Value<String> sourceLang = const Value.absent(),
                Value<String> targetLang = const Value.absent(),
                Value<String?> namespace = const Value.absent(),
                Value<bool> caseSensitive = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GlobalGlossaryTermsCompanion(
                id: id,
                sourceTerm: sourceTerm,
                targetTerm: targetTerm,
                sourceLang: sourceLang,
                targetLang: targetLang,
                namespace: namespace,
                caseSensitive: caseSensitive,
                note: note,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sourceTerm,
                required String targetTerm,
                required String sourceLang,
                required String targetLang,
                Value<String?> namespace = const Value.absent(),
                Value<bool> caseSensitive = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => GlobalGlossaryTermsCompanion.insert(
                id: id,
                sourceTerm: sourceTerm,
                targetTerm: targetTerm,
                sourceLang: sourceLang,
                targetLang: targetLang,
                namespace: namespace,
                caseSensitive: caseSensitive,
                note: note,
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

typedef $$GlobalGlossaryTermsTableProcessedTableManager =
    ProcessedTableManager<
      _$GlossaryDatabase,
      $GlobalGlossaryTermsTable,
      GlobalGlossaryTermRow,
      $$GlobalGlossaryTermsTableFilterComposer,
      $$GlobalGlossaryTermsTableOrderingComposer,
      $$GlobalGlossaryTermsTableAnnotationComposer,
      $$GlobalGlossaryTermsTableCreateCompanionBuilder,
      $$GlobalGlossaryTermsTableUpdateCompanionBuilder,
      (
        GlobalGlossaryTermRow,
        BaseReferences<
          _$GlossaryDatabase,
          $GlobalGlossaryTermsTable,
          GlobalGlossaryTermRow
        >,
      ),
      GlobalGlossaryTermRow,
      PrefetchHooks Function()
    >;

class $GlossaryDatabaseManager {
  final _$GlossaryDatabase _db;
  $GlossaryDatabaseManager(this._db);
  $$GlobalGlossaryTermsTableTableManager get globalGlossaryTerms =>
      $$GlobalGlossaryTermsTableTableManager(_db, _db.globalGlossaryTerms);
}
