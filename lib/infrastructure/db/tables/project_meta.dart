import 'package:drift/drift.dart';

class ProjectMeta extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get name => text()();
  TextColumn get schemaVersion => text()();
  TextColumn get appVersion => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  TextColumn get sourceLangCode =>
      text().withDefault(const Constant('en_us'))();
  TextColumn get targetLangCode =>
      text().withDefault(const Constant('ko_kr'))();
  TextColumn get providerId => text().nullable()();
  TextColumn get modelId => text().nullable()();
  TextColumn get outputFormat =>
      text().withDefault(const Constant('pack_zip'))();
  TextColumn get mcVersion => text().withDefault(const Constant('1.20.1'))();
  TextColumn get packIconMode =>
      text().withDefault(const Constant('default'))();
  TextColumn get packIconPath => text().nullable()();

  /// [ConflictPriority] wire name. Only ever preselects — see TECHNICAL.md 3.4.
  TextColumn get conflictPriority =>
      text().withDefault(const Constant('manual'))();

  TextColumn get togglesJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}
