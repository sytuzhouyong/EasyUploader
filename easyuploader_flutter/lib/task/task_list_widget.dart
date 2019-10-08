import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'task_vo.dart';
import 'task_list_header_widget.dart';
import 'task_list_item_widget.dart';
import 'task_manager.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class TaskListWidget extends StatefulWidget {

  final String title;
  final bool pushFromIOS;

  TaskListWidget({
    Key key,
    @required this.title,
    @required this.pushFromIOS,
  }): super(key: key);

  @override
  _TaskListWidgetState createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  // 列表滚动控制器
  final ScrollController _scrollController = new ScrollController();
  final TaskManager taskManager = TaskManager.instance;
  List<TaskModel> tasks = List(); // 任务列表

  // 创建一个给native的channel (类似iOS的通知）
  static const methodChannel = const MethodChannel('channel.method.ios');

//  void _incrementCounter() {
//    setState(() {
//    });
//  }
  @override
  void initState() {
    super.initState();
    _iOSGetTobeUploadedTasks();
    _refreshList();
  }

  _refreshList() async {
    List<TaskModel> items = await taskManager.queryTask();
    setState(() {
      tasks = items;
    });
    await methodChannel.invokeMethod('clearTobeUploadedTasks');
  }

  // 提供给原生调用
  addUploadTasks(List<TaskModel> tasks) async {
    print('add upload tasks: $tasks');

    await taskManager.addTasks(tasks);
    await _refreshList();
  }

  _onAddTask() async {
    TaskModel task = testTasks[0];
    await taskManager.addTask(task);
    await _refreshList();
  }

  _iOSPopVC() async {
    await methodChannel.invokeMethod('popVC');
  }
  _iOSGetTobeUploadedTasks() async {
    String text = await methodChannel.invokeMethod('getTobeUploadedTasks');
    print('_iOSGetTobeUploadedTasks result: $text');
    if (text.length <= 0) {
      print('empty upload tasks');
      return;
    }
    List maps = jsonDecode(text);
    List<TaskModel> tasks = List();
    for (Map map in maps) {
      TaskModel task = TaskModel.fromMap(map);
      tasks.add(task);
    }
    addUploadTasks(tasks);
  }

  // Native调用原生监听
  Future<dynamic> handelNativeCall(MethodCall methodCall) {
    print('handelNativeCall $methodCall');

    String backResult = "gobackSuccess";
    if (methodCall.method == "addUploadTasks") {
      print('param: ${methodCall.arguments}');
//      addUploadTasks(methodCall.arguments);
    }
    return Future.value(backResult);
  }

  @override
  Widget build(BuildContext context) {
//      methodChannel.setMethodCallHandler(handelNativeCall);

    return MaterialApp(
      home: Material(
        child: Scaffold(
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(widget.title),
            // 左侧按钮
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              tooltip: '返回',
              onPressed: () {
                if (widget.pushFromIOS) {
                  print('11111');
                  _iOSPopVC();
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            // 右侧按钮
            actions: <Widget>[
              GestureDetector(
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Icon(Icons.add),
                ), //
                onTap: () {
//                  Navigator.pushNamed(context, 'search');
                  _onAddTask();
                },
              ),
            ],
          ),
          body: ListView.builder(
            controller: _scrollController,
            // 列表内容不足一屏时，列表也可以滑动
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: tasks.length,
            itemBuilder: (BuildContext context, int index) {
              TaskModel task = tasks[index];
              return Column(
                children: <Widget>[
                  Offstage(
                    offstage: index != 0,
                    child: TaskListHeaderWidget(
                        numberOfTask: tasks.length,
                        title: '上传列表'
                    ),
                  ),
                  TaskListItemWidget(
                    task: task,
                  ),
                ],
              );
            },
          )
        ),
      ),
    );
  }
}
