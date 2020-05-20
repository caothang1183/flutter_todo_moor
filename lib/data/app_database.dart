import 'package:fluttertodomoor/data/tables/task_with_tag.dart';
import 'package:fluttertodomoor/data/tables/tasks.dart';
import 'package:fluttertodomoor/data/tables/tags.dart';
import 'package:moor_flutter/moor_flutter.dart';

part 'app_database.g.dart';

@UseMoor(tables: [Tasks, Tags], daos: [TaskDao, TagDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(FlutterQueryExecutor.inDatabaseFolder(path: 'db.sqlite', logStatements: true));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration =>
    MigrationStrategy(
      onCreate: (Migrator m) {
        return m.createAll();
      },
      onUpgrade: (migration, from, to) async {
        if (from == 1) {
          await migration.addColumn(tasks, tasks.tagName);
          await migration.createTable(tags);
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      }
    );
}

@UseDao(tables: [Tasks, Tags])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(AppDatabase db) : super(db);


  Stream<List<TaskWithTag>> watchAllTasks() =>
    (select(tasks)
      ..orderBy([
          (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.asc),
          (t) => OrderingTerm(expression: t.title),
      ])
    ).join([
      leftOuterJoin(tags, tags.name.equalsExp(tasks.tagName))
    ]).watch()
      .map((rows) =>
      rows.map((row) {
        return TaskWithTag(
          task: row.readTable(tasks),
          tag: row.readTable(tags)
        );
      }).toList());

  Stream<List<TaskWithTag>> watchAllCompletedTasks() =>
    (select(tasks)
      ..orderBy([
          (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.desc),
          (t) => OrderingTerm(expression: t.title),
      ])
      ..where((tbl) => tbl.completed.equals(true))
    ).join([
      leftOuterJoin(tags, tags.name.equalsExp(tasks.tagName))
    ]).watch()
      .map((rows) =>
      rows.map((row) {
        return TaskWithTag(
          task: row.readTable(tasks),
          tag: row.readTable(tags)
        );
      }).toList());

  Future insertTask(Insertable<Task> task) => into(tasks).insert(task);

  Future updateTask(Insertable<Task> task) => update(tasks).replace(task);

  Future deleteTask(Insertable<Task> task) => delete(tasks).delete(task);
}

@UseDao(tables: [Tags])
class TagDao extends DatabaseAccessor<AppDatabase> with _$TagDaoMixin {
  TagDao(AppDatabase db) : super(db);

  Future<List<Tag>> getAllTags() => select(tags).get();

  Stream<List<Tag>> watchAllTags() =>
    (select(tags)
      ..orderBy([
          (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
      ])
    ).watch();

  Future insertTag(Insertable<Tag> tag) => into(tags).insert(tag);

  Future deleteTag(Insertable<Tag> tag) => delete(tags).delete(tag);
}