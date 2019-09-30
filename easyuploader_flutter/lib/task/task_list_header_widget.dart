import 'package:flutter/material.dart';
//

class TaskListHeaderWidget extends StatefulWidget {
  final String title;
  final int numberOfTask;

  TaskListHeaderWidget({
    Key key,
    @required this.numberOfTask,
    @required this.title,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new TaskListHeaderWidgetState();
  }
}

class TaskListHeaderWidgetState extends State<TaskListHeaderWidget> {

  @override
  Widget build(BuildContext context) {
    String text = widget.title + ' (' + widget.numberOfTask.toString() + ')';
    // TODO: implement build
    return Container(
      height: 32,
      margin: EdgeInsets.only(left: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(text, style: TextStyle(color: Color(0xFF666666), fontSize: 14),),
        ],
      )
    );
  }
}