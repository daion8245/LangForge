import 'package:drift/drift.dart';

class ExportRecords extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get format => text()();
  TextColumn get outputPath => text()();
  IntColumn get namespaceCount => integer()();
  IntColumn get entryCount => integer()();
  TextColumn get reportPath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
