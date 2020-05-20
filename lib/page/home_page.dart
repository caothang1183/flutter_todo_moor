import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertodomoor/data/app_database.dart';
import 'package:fluttertodomoor/data/tables/task_with_tag.dart';
import 'package:fluttertodomoor/page/widgets/new_tag_input.dart';
import 'package:fluttertodomoor/page/widgets/new_task_input.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool showCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          _buildCompletedOnlySwitch()
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(child: _buildTaskList(context)),
            NewTaskInput(),
            NewTagInput()
          ],
        ),
      ),
    );
  }


  StreamBuilder<List<TaskWithTag>> _buildTaskList(BuildContext context) {
    final dao = Provider.of<TaskDao>(context);
    return StreamBuilder(
      stream: showCompleted ? dao.watchAllCompletedTasks() : dao.watchAllTasks(),
      builder: (context, AsyncSnapshot<List<TaskWithTag>> snapshot) {
        final tasks = snapshot.data ?? List();
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (_, index) {
            return _buildItem(tasks[index], dao);
          });
      }
    );
  }

  Widget _buildItem(TaskWithTag item, TaskDao dao) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: [
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => dao.deleteTask(item.task),
        )
      ],
      child: CheckboxListTile(
        title: Text(item.task.title),
        subtitle: Text(item.task.dueDate?.toString() ?? 'Not picked up due date yet'),
        secondary: _buildTag(item.tag),
        value: item.task.completed,
        onChanged: (value) => dao.updateTask(item.task.copyWith(completed: value)),
      ),
    );
  }

  Widget _buildTag(Tag tag) {
    return Container(
      width: 50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (tag != null) ...[
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(tag.color),
              ),
            ),
            Text(
              tag.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildCompletedOnlySwitch() {
    return Row(
      children: [
        Text('Tasks Completed'),
        Switch(
          value: showCompleted,
          activeColor: Colors.white,
          onChanged: (value) {
            setState(() {
              showCompleted = value;
            });
          },
        )
      ],
    );
  }
}
