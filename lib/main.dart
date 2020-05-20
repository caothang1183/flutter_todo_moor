import 'package:flutter/material.dart';
import 'package:fluttertodomoor/data/app_database.dart';
import 'package:fluttertodomoor/page/home_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    Provider<AppDatabase>(
      create: (context) => AppDatabase(),
      child: App(),
      dispose: (context, db) => db.close(),
    ),
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final db = AppDatabase();
    return MultiProvider(
      providers: [
        Provider<TaskDao>(create: (_) => db.taskDao),
        Provider<TagDao>(create: (_) => db.tagDao),
      ],
      child: MaterialApp(
        title: 'Todo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomePage(title: 'Todo List'),
      )
    );
  }
}
