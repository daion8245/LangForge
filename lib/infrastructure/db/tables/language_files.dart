import 'package:drift/drift.dart';
import 'namespaces.dart';

class LanguageFiles extends Table {
  TextColumn get id => text()();
  TextColumn get namespaceId =>
      text().references(Namespaces, #id, onDelete: KeyAction.cascade)();
  TextColumn get rawCode => text()(); // 파일명 그대로 (en_US)
  TextColumn get code => text()(); // 정규화 결과 (en_us)
  TextColumn get entryPath => text()(); // assets/quark/lang/en_us.json
  IntColumn get keyCount => integer()();
  TextColumn get role => text()(); // source | existing_target | other

  @override
  Set<Column> get primaryKey => {id};
}
