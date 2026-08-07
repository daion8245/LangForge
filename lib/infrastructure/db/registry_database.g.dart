// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registry_database.dart';

// ignore_for_file: type=lint
class $RecentProjectsTable extends RecentProjects
    with TableInfo<$RecentProjectsTable, RecentProject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastOpenedAtMeta = const VerificationMeta(
    'lastOpenedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastOpenedAt = GeneratedColumn<DateTime>(
    'last_opened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalKeysMeta = const VerificationMeta(
    'totalKeys',
  );
  @override
  late final GeneratedColumn<int> totalKeys = GeneratedColumn<int>(
    'total_keys',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _doneKeysMeta = const VerificationMeta(
    'doneKeys',
  );
  @override
  late final GeneratedColumn<int> doneKeys = GeneratedColumn<int>(
    'done_keys',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hasMissingFilesMeta = const VerificationMeta(
    'hasMissingFiles',
  );
  @override
  late final GeneratedColumn<bool> hasMissingFiles = GeneratedColumn<bool>(
    'has_missing_files',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_missing_files" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    path,
    lastOpenedAt,
    totalKeys,
    doneKeys,
    hasMissingFiles,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecentProject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('last_opened_at')) {
      context.handle(
        _lastOpenedAtMeta,
        lastOpenedAt.isAcceptableOrUnknown(
          data['last_opened_at']!,
          _lastOpenedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastOpenedAtMeta);
    }
    if (data.containsKey('total_keys')) {
      context.handle(
        _totalKeysMeta,
        totalKeys.isAcceptableOrUnknown(data['total_keys']!, _totalKeysMeta),
      );
    }
    if (data.containsKey('done_keys')) {
      context.handle(
        _doneKeysMeta,
        doneKeys.isAcceptableOrUnknown(data['done_keys']!, _doneKeysMeta),
      );
    }
    if (data.containsKey('has_missing_files')) {
      context.handle(
        _hasMissingFilesMeta,
        hasMissingFiles.isAcceptableOrUnknown(
          data['has_missing_files']!,
          _hasMissingFilesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecentProject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentProject(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      lastOpenedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_opened_at'],
      )!,
      totalKeys: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_keys'],
      )!,
      doneKeys: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}done_keys'],
      )!,
      hasMissingFiles: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_missing_files'],
      )!,
    );
  }

  @override
  $RecentProjectsTable createAlias(String alias) {
    return $RecentProjectsTable(attachedDatabase, alias);
  }
}

class RecentProject extends DataClass implements Insertable<RecentProject> {
  final String id;
  final String name;
  final String path;
  final DateTime lastOpenedAt;
  final int totalKeys;
  final int doneKeys;
  final bool hasMissingFiles;
  const RecentProject({
    required this.id,
    required this.name,
    required this.path,
    required this.lastOpenedAt,
    required this.totalKeys,
    required this.doneKeys,
    required this.hasMissingFiles,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['path'] = Variable<String>(path);
    map['last_opened_at'] = Variable<DateTime>(lastOpenedAt);
    map['total_keys'] = Variable<int>(totalKeys);
    map['done_keys'] = Variable<int>(doneKeys);
    map['has_missing_files'] = Variable<bool>(hasMissingFiles);
    return map;
  }

  RecentProjectsCompanion toCompanion(bool nullToAbsent) {
    return RecentProjectsCompanion(
      id: Value(id),
      name: Value(name),
      path: Value(path),
      lastOpenedAt: Value(lastOpenedAt),
      totalKeys: Value(totalKeys),
      doneKeys: Value(doneKeys),
      hasMissingFiles: Value(hasMissingFiles),
    );
  }

  factory RecentProject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentProject(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      path: serializer.fromJson<String>(json['path']),
      lastOpenedAt: serializer.fromJson<DateTime>(json['lastOpenedAt']),
      totalKeys: serializer.fromJson<int>(json['totalKeys']),
      doneKeys: serializer.fromJson<int>(json['doneKeys']),
      hasMissingFiles: serializer.fromJson<bool>(json['hasMissingFiles']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'path': serializer.toJson<String>(path),
      'lastOpenedAt': serializer.toJson<DateTime>(lastOpenedAt),
      'totalKeys': serializer.toJson<int>(totalKeys),
      'doneKeys': serializer.toJson<int>(doneKeys),
      'hasMissingFiles': serializer.toJson<bool>(hasMissingFiles),
    };
  }

  RecentProject copyWith({
    String? id,
    String? name,
    String? path,
    DateTime? lastOpenedAt,
    int? totalKeys,
    int? doneKeys,
    bool? hasMissingFiles,
  }) => RecentProject(
    id: id ?? this.id,
    name: name ?? this.name,
    path: path ?? this.path,
    lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
    totalKeys: totalKeys ?? this.totalKeys,
    doneKeys: doneKeys ?? this.doneKeys,
    hasMissingFiles: hasMissingFiles ?? this.hasMissingFiles,
  );
  RecentProject copyWithCompanion(RecentProjectsCompanion data) {
    return RecentProject(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      path: data.path.present ? data.path.value : this.path,
      lastOpenedAt: data.lastOpenedAt.present
          ? data.lastOpenedAt.value
          : this.lastOpenedAt,
      totalKeys: data.totalKeys.present ? data.totalKeys.value : this.totalKeys,
      doneKeys: data.doneKeys.present ? data.doneKeys.value : this.doneKeys,
      hasMissingFiles: data.hasMissingFiles.present
          ? data.hasMissingFiles.value
          : this.hasMissingFiles,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentProject(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('totalKeys: $totalKeys, ')
          ..write('doneKeys: $doneKeys, ')
          ..write('hasMissingFiles: $hasMissingFiles')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    path,
    lastOpenedAt,
    totalKeys,
    doneKeys,
    hasMissingFiles,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentProject &&
          other.id == this.id &&
          other.name == this.name &&
          other.path == this.path &&
          other.lastOpenedAt == this.lastOpenedAt &&
          other.totalKeys == this.totalKeys &&
          other.doneKeys == this.doneKeys &&
          other.hasMissingFiles == this.hasMissingFiles);
}

class RecentProjectsCompanion extends UpdateCompanion<RecentProject> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> path;
  final Value<DateTime> lastOpenedAt;
  final Value<int> totalKeys;
  final Value<int> doneKeys;
  final Value<bool> hasMissingFiles;
  final Value<int> rowid;
  const RecentProjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.path = const Value.absent(),
    this.lastOpenedAt = const Value.absent(),
    this.totalKeys = const Value.absent(),
    this.doneKeys = const Value.absent(),
    this.hasMissingFiles = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecentProjectsCompanion.insert({
    required String id,
    required String name,
    required String path,
    required DateTime lastOpenedAt,
    this.totalKeys = const Value.absent(),
    this.doneKeys = const Value.absent(),
    this.hasMissingFiles = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       path = Value(path),
       lastOpenedAt = Value(lastOpenedAt);
  static Insertable<RecentProject> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? path,
    Expression<DateTime>? lastOpenedAt,
    Expression<int>? totalKeys,
    Expression<int>? doneKeys,
    Expression<bool>? hasMissingFiles,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (path != null) 'path': path,
      if (lastOpenedAt != null) 'last_opened_at': lastOpenedAt,
      if (totalKeys != null) 'total_keys': totalKeys,
      if (doneKeys != null) 'done_keys': doneKeys,
      if (hasMissingFiles != null) 'has_missing_files': hasMissingFiles,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecentProjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? path,
    Value<DateTime>? lastOpenedAt,
    Value<int>? totalKeys,
    Value<int>? doneKeys,
    Value<bool>? hasMissingFiles,
    Value<int>? rowid,
  }) {
    return RecentProjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      totalKeys: totalKeys ?? this.totalKeys,
      doneKeys: doneKeys ?? this.doneKeys,
      hasMissingFiles: hasMissingFiles ?? this.hasMissingFiles,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (lastOpenedAt.present) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt.value);
    }
    if (totalKeys.present) {
      map['total_keys'] = Variable<int>(totalKeys.value);
    }
    if (doneKeys.present) {
      map['done_keys'] = Variable<int>(doneKeys.value);
    }
    if (hasMissingFiles.present) {
      map['has_missing_files'] = Variable<bool>(hasMissingFiles.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentProjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('totalKeys: $totalKeys, ')
          ..write('doneKeys: $doneKeys, ')
          ..write('hasMissingFiles: $hasMissingFiles, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$RegistryDatabase extends GeneratedDatabase {
  _$RegistryDatabase(QueryExecutor e) : super(e);
  $RegistryDatabaseManager get managers => $RegistryDatabaseManager(this);
  late final $RecentProjectsTable recentProjects = $RecentProjectsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [recentProjects];
}

typedef $$RecentProjectsTableCreateCompanionBuilder =
    RecentProjectsCompanion Function({
      required String id,
      required String name,
      required String path,
      required DateTime lastOpenedAt,
      Value<int> totalKeys,
      Value<int> doneKeys,
      Value<bool> hasMissingFiles,
      Value<int> rowid,
    });
typedef $$RecentProjectsTableUpdateCompanionBuilder =
    RecentProjectsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> path,
      Value<DateTime> lastOpenedAt,
      Value<int> totalKeys,
      Value<int> doneKeys,
      Value<bool> hasMissingFiles,
      Value<int> rowid,
    });

class $$RecentProjectsTableFilterComposer
    extends Composer<_$RegistryDatabase, $RecentProjectsTable> {
  $$RecentProjectsTableFilterComposer({
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

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalKeys => $composableBuilder(
    column: $table.totalKeys,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get doneKeys => $composableBuilder(
    column: $table.doneKeys,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasMissingFiles => $composableBuilder(
    column: $table.hasMissingFiles,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecentProjectsTableOrderingComposer
    extends Composer<_$RegistryDatabase, $RecentProjectsTable> {
  $$RecentProjectsTableOrderingComposer({
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

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalKeys => $composableBuilder(
    column: $table.totalKeys,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get doneKeys => $composableBuilder(
    column: $table.doneKeys,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasMissingFiles => $composableBuilder(
    column: $table.hasMissingFiles,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecentProjectsTableAnnotationComposer
    extends Composer<_$RegistryDatabase, $RecentProjectsTable> {
  $$RecentProjectsTableAnnotationComposer({
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

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalKeys =>
      $composableBuilder(column: $table.totalKeys, builder: (column) => column);

  GeneratedColumn<int> get doneKeys =>
      $composableBuilder(column: $table.doneKeys, builder: (column) => column);

  GeneratedColumn<bool> get hasMissingFiles => $composableBuilder(
    column: $table.hasMissingFiles,
    builder: (column) => column,
  );
}

class $$RecentProjectsTableTableManager
    extends
        RootTableManager<
          _$RegistryDatabase,
          $RecentProjectsTable,
          RecentProject,
          $$RecentProjectsTableFilterComposer,
          $$RecentProjectsTableOrderingComposer,
          $$RecentProjectsTableAnnotationComposer,
          $$RecentProjectsTableCreateCompanionBuilder,
          $$RecentProjectsTableUpdateCompanionBuilder,
          (
            RecentProject,
            BaseReferences<
              _$RegistryDatabase,
              $RecentProjectsTable,
              RecentProject
            >,
          ),
          RecentProject,
          PrefetchHooks Function()
        > {
  $$RecentProjectsTableTableManager(
    _$RegistryDatabase db,
    $RecentProjectsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecentProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<DateTime> lastOpenedAt = const Value.absent(),
                Value<int> totalKeys = const Value.absent(),
                Value<int> doneKeys = const Value.absent(),
                Value<bool> hasMissingFiles = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecentProjectsCompanion(
                id: id,
                name: name,
                path: path,
                lastOpenedAt: lastOpenedAt,
                totalKeys: totalKeys,
                doneKeys: doneKeys,
                hasMissingFiles: hasMissingFiles,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String path,
                required DateTime lastOpenedAt,
                Value<int> totalKeys = const Value.absent(),
                Value<int> doneKeys = const Value.absent(),
                Value<bool> hasMissingFiles = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecentProjectsCompanion.insert(
                id: id,
                name: name,
                path: path,
                lastOpenedAt: lastOpenedAt,
                totalKeys: totalKeys,
                doneKeys: doneKeys,
                hasMissingFiles: hasMissingFiles,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecentProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$RegistryDatabase,
      $RecentProjectsTable,
      RecentProject,
      $$RecentProjectsTableFilterComposer,
      $$RecentProjectsTableOrderingComposer,
      $$RecentProjectsTableAnnotationComposer,
      $$RecentProjectsTableCreateCompanionBuilder,
      $$RecentProjectsTableUpdateCompanionBuilder,
      (
        RecentProject,
        BaseReferences<_$RegistryDatabase, $RecentProjectsTable, RecentProject>,
      ),
      RecentProject,
      PrefetchHooks Function()
    >;

class $RegistryDatabaseManager {
  final _$RegistryDatabase _db;
  $RegistryDatabaseManager(this._db);
  $$RecentProjectsTableTableManager get recentProjects =>
      $$RecentProjectsTableTableManager(_db, _db.recentProjects);
}
