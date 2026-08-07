import 'package:drift/drift.dart';
import 'input_files.dart';

class Namespaces extends Table {
  TextColumn get id => text()();
  TextColumn get inputFileId =>
      text().references(InputFiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()(); // quark, zeta, emi
  TextColumn get state =>
      text()(); // ok | no_source | json_error | conflicted | excluded | done
  TextColumn get sourceOverride => text().nullable()();
  BoolColumn get excluded => boolean().withDefault(const Constant(false))();
  BoolColumn get selected => boolean().withDefault(const Constant(true))();
  IntColumn get keyCount => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
  IntColumn get errorLine => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
