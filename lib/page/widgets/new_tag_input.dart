import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:fluttertodomoor/data/app_database.dart';
import 'package:moor/moor.dart';
import 'package:provider/provider.dart';

class NewTagInput extends StatefulWidget {

  const NewTagInput({Key key}) : super(key: key);

  @override
  _NewTagInputState createState() => _NewTagInputState();
}

class _NewTagInputState extends State<NewTagInput> {
  static const DEFAULT_COLOR = Colors.blue;
  Color pickedColor = DEFAULT_COLOR;
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
          _buildPickerColor(context)
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context) {
    final dao = Provider.of<TagDao>(context);
    return Flexible(
      flex: 6,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: "Tag Name"
        ),
        onSubmitted: (inputName) {
          final tag = TagsCompanion(
            name: Value(inputName),
            color: Value(pickedColor.value)
          );
          dao.insertTag(tag);
          resetValues();
        },
      ),
    );
  }

  Widget _buildPickerColor(BuildContext context) {
    return Flexible(
      flex: 1,
      child: GestureDetector(
        child: Center(
          child: Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: pickedColor,
            ),
          ),
        ),
        onTap: () => _showColorPickerDialog(context),
      ),
    );
  }

  Future _showColorPickerDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          child: AlertDialog(
            actions: [
              MaterialButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    pickedColor = DEFAULT_COLOR;
                  });
                },
              )
            ],
            content: MaterialColorPicker(
              allowShades: false,
              selectedColor: DEFAULT_COLOR,
              onMainColorChange: (color) {
                setState(() {
                  pickedColor = color;
                });
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      }
    );
  }

  void resetValues() {
    setState(() {
      pickedColor = DEFAULT_COLOR;
      controller.clear();
    });
  }
}
