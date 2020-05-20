import 'package:flutter/material.dart';
import 'package:fluttertodomoor/data/app_database.dart';
import 'package:moor/moor.dart';
import 'package:provider/provider.dart';

class NewTaskInput extends StatefulWidget {

  const NewTaskInput({Key key}) : super(key: key);

  @override
  _NewTaskInputState createState() => _NewTaskInputState();
}

class _NewTaskInputState extends State<NewTaskInput> {
  DateTime pickedDate;
  Tag selectedTag;
  TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildTextField(context),
          _buildTagSelector(context),
          _buildDateTimePicker(context)
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context) {
    final dao = Provider.of<TaskDao>(context);
    return Expanded(
      flex: 4,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: "Task Title"
        ),
        onSubmitted: (inputTitle) {
          final task = TasksCompanion(
            title: Value(inputTitle),
            tagName: Value(selectedTag?.name),
            dueDate: Value(pickedDate)
          );
          dao.insertTask(task);
          resetValues();
        },
      ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context) {
    return Flexible(
      flex: 1,
      child: IconButton(
        icon: Icon(Icons.calendar_today),
        onPressed: () async {
          pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2021)
          );
        },
      ),
    );
  }

  StreamBuilder<List<Tag>> _buildTagSelector(BuildContext context) {
    return StreamBuilder<List<Tag>>(
      stream: Provider.of<TagDao>(context).watchAllTags(),
      builder: (context, snapshot) {
        final tags = snapshot.data ?? List();
        DropdownMenuItem<Tag> dropdownFromTag(Tag tag) {
          return DropdownMenuItem(
            value: tag,
            child: Row(
              children: [
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(tag.color)
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  tag.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }
        final dropdownMenuItem = tags.map((tag) => dropdownFromTag(tag)).toList()
          ..insert(0, DropdownMenuItem(value: null, child: Text("No Tag")));
        return Flexible(
          flex: 2,
          child: DropdownButton(
            onChanged: (Tag tag) {
              setState(() {
                selectedTag = tag;
              });
            },
            isExpanded: true,
            value: selectedTag,
            items: dropdownMenuItem,
          ),
        );
      },
    );
  }

  void resetValues() {
    setState(() {
      pickedDate = null;
      selectedTag = null;
      controller.clear();
    });
  }
}

