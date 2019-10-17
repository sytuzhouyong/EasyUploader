
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'task_vo.dart';

class TaskListItemWidget extends StatefulWidget {
  TaskModel task;
  final UploadTaskCallback uploadTaskCallback;

  TaskListItemWidget({
    Key key,
    @required this.task,
    @required this.uploadTaskCallback
  }): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TaskListItemWidgetState();
  }
}

class TaskListItemWidgetState extends State<TaskListItemWidget> {
  static const methodChannel = const MethodChannel('channel.method.ios');

  Widget thumbnailImageWidget() {
    String url = widget.task.thumbnailUrl;
    File file = File(url);
    if (file.existsSync()) {
      return Image.file(file);
    } else {
      return Icon(Icons.image, color: Colors.grey, size: 40,);
    }
  }

  void uploadButtonHandler() async {
    TaskModel updatedTask = await widget.uploadTaskCallback(widget.task);
    setState(() {
      widget.task = updatedTask;
    });
  }

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
                child: thumbnailImageWidget(),
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
          Offstage(
            offstage: widget.task.state != TaskState.Processing,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              child: Icon(Icons.dashboard),
            ),
          ),
          Offstage(
            offstage: widget.task.state != TaskState.Done,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              child:  IconButton(icon: Icon(Icons.done), onPressed: () {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('已经完成了'),)
                );
              }),
            ),
          ),
          Offstage(
            offstage: widget.task.state != TaskState.Ready,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              child: IconButton(icon: Icon(Icons.cloud_upload), onPressed: () {
                uploadButtonHandler();
              }),
            ),
          ),
        ],
      ),
    );
  }
}