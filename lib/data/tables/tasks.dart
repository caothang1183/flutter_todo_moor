import 'package:moor_flutter/moor_flutter.dart';

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tagName => text().nullable().customConstraint('NULL REFERENCES tags(name)')();
  TextColumn get title => text().withLength(min: 1, max: 50)();
  DateTimeColumn get dueDate => dateTime().nullable()();
  BoolColumn get completed => boolean().withDefault(Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}