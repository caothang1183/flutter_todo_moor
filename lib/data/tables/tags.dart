import 'package:moor_flutter/moor_flutter.dart';

class Tags extends Table {
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get color => integer()();

  @override
  Set<Column> get primaryKey => {name};
}