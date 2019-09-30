import 'package:flutter/material.dart';
import 'task_vo.dart';

class TaskListItemWidget extends StatefulWidget {
  final TaskModel task;

  TaskListItemWidget({
    Key key,
    @required this.task
  }): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TaskListItemWidgetState();
  }
}


class TaskListItemWidgetState extends State<TaskListItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(width: 0.5, color: Color(0xFFD9D9D9))
        ),
      ),
      child: Row(
        children: <Widget>[
          // 1. 任务资源缩略图
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(10),
            child: IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: null
            ),
          ),
          // 2. 任务名称和进度信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 12),
                ),
                Text(
                  widget.task.name,
                  style: TextStyle(fontSize: 14, color: Color(0xFF222222), fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 6),
                ),
                Text(
                  widget.task.processDesc(),
                  style: TextStyle(fontSize: 12, color: Color(0xFF666666), fontWeight: FontWeight.normal),
                )
              ],
            ),
          ),
          // 3. 操作按钮

          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(icon: Icon(Icons.file_upload), onPressed: null),
          ),
        ],
      ),
    );
  }
}