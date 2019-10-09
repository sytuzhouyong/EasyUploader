
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  static const methodChannel = const MethodChannel('channel.method.ios');
  
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
            width: 40,
            height: 40,
            margin: const EdgeInsets.all(10),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(File(widget.task.thumbnailUrl))
            ),
//            decoration: BoxDecoration(
//              color: Colors.redAccent,
//            ),
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