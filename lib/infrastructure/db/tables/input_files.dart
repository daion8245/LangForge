import 'package:drift/drift.dart';

class InputFiles extends Table {
  TextColumn get id => text()(); // uuid v4
  TextColumn get originalName => text()();
  TextColumn get absolutePath => text()();
  TextColumn get kind => text()(); // jar | zip | directory
  IntColumn get sizeBytes => integer()();
  TextColumn get sha256 => text()();
  DateTimeColumn get addedAt => dateTime()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  TextColumn get scanState =>
      text()(); // pending | ok | rejected | missing | changed
  TextColumn get rejectReason => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
