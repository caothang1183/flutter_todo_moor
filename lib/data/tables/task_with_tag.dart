import 'package:flutter/foundation.dart';
import 'package:fluttertodomoor/data/app_database.dart';

class TaskWithTag {
  final Task task;
  final Tag tag;

  TaskWithTag({@required this.task, @required this.tag});
}