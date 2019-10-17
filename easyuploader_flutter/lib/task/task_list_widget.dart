import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'task_vo.dart';
import 'task_list_header_widget.dart';
import 'task_list_item_widget.dart';
import 'task_manager.dart';
import 'dart:convert';
//import 'package:image_picker/image_picker.dart';

// 创建一个给native的channel (类似iOS的通知）
const methodChannel = const MethodChannel('channel.method.ios');

class TaskTabListWidget extends StatefulWidget {
  final String title;
  final bool pushFromIOS;

  TaskTabListWidget({
    Key key,
    @required this.title,
    @required this.pushFromIOS,
  });

  @override
  State<StatefulWidget> createState() => _TaskTabListWidgetState();
}

class _TaskTabListWidgetState extends State<TaskTabListWidget> {
  final List<Tab> tabs = <Tab>[
    Tab(text:'未上传',),
    Tab(text:'已上传',),
  ];

  _iOSPopVC() async {
    await methodChannel.invokeMethod('popVC');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: tabs.length,
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
                  child: IconButton(icon:Icon(Icons.mode_edit), onPressed: () {
                  },),
                ), //
                onTap: () {
//                  Navigator.pushNamed(context, 'search');
                },
              ),
            ],
            bottom: TabBar(tabs: tabs),
          ),
          body: TabBarView(
            children: tabs.map((Tab tab) {
              return TaskListWidget(title: '', pushFromIOS: true,);
           }).toList(),
          ),
        ),
      ),
    );
  }
}

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
  // 任务管理器
  final TaskManager taskManager = TaskManager.instance;
  List<TaskModel> tasks = List(); // 任务列表


  // 注册一个通知
  static const EventChannel eventChannel = const EventChannel('channel.event.native');


  @override
  void initState() {
    super.initState();

    // 监听事件，同时发送参数12345
    eventChannel.receiveBroadcastStream(12345).listen(_onEvent,onError: _onError);

    _iOSGetTobeUploadedTasks();
    _refreshList();
  }

  // 回调事件
  void _onEvent(Object event) {
    print('_onEvent ${event.toString()}');
    if (event is Map) {
      Map params = event;
      int id = params['id'];
      String name = params['name'];
      double percent = params['percent'];
      bool finished = params['finished'];
      print('id = $id, name = $name, percent = $percent, finished = $finished');

      TaskModel updatedTask;
      int index = 0;
      for (TaskModel item in tasks) {
        if (item.id == id) {
          updatedTask = item;
          break;
        }
        index++;
      }
      if (updatedTask == null) {
        print('not find task with id $id');
        return;
      }

      int size = (updatedTask.totalSize.toDouble() * percent).toInt();
      updatedTask.transferredSize = size;
      if (finished) {
        updatedTask.state = TaskState.Done;
      }

      setState(() {
        tasks[index] = updatedTask;
      });

      taskManager.updateTask({'id':id}, {'transferredSize': size, 'state': updatedTask.state.index});

    }
  }
  // 错误返回
  void _onError(Object error) {

  }


  _refreshList() async {
    List<TaskModel> items = await taskManager.queryTask();
    setState(() {
      tasks = items;
    });
    await methodChannel.invokeMethod('clearTobeUploadedTasks');
  }

  _onAddTask() async {
//    TaskModel task = testTasks[0];
//    await taskManager.addTask(task);
//    await _refreshList();
  }

  // 获取native端的任务列表
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

    await taskManager.addTasks(tasks);
    await _refreshList();
  }

  Future<bool> _deleteTaskAtIndex(int index) async {
    TaskModel task = tasks[index];
    bool success = await taskManager.deleteTaskById(task.id);
    print('delete task at index: $index ${success ? "success" : "fail"}');
    return success;
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
    return Scaffold(
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
              Dismissible(
                confirmDismiss: (DismissDirection direction) async {
                  bool result = await showAlertDialog(context, index);
                  print('show dialog returns $result');
                  if (!result) {
                     return false;
                  }
                  bool deleted = await _deleteTaskAtIndex(index);
                  if (!deleted) {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('删除 ${tasks[index].name} 失败'),)
                    );
                    return false;
                  }
                  return true;
                },
                background: Container( // 右滑展示
                  child: ListTile(
                      leading: IconButton(
                          icon: Icon(Icons.favorite, color: Colors.yellow,),
                          onPressed: null
                      )
                  ),
                ),
                secondaryBackground: Container( // 左滑展示
                  child: ListTile(
                      trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red,),
                          onPressed: null
                      )
                  ),
                ),
                key: Key('key_task_item_${tasks[index].id}'),
                child: TaskListItemWidget(
                  task: task,
                  uploadTaskCallback: taskManager.uploadTaskCallback,
                ),
                // 删除后回调
                onDismissed: (DismissDirection direction) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('删除了${tasks[index].name}'),)
                  );
                  setState(() {
                    tasks.removeAt(index);
                  });
                },
              ),
            ],
          );
        },
      )
    );
  }

  Future<bool> showAlertDialog(BuildContext context, int index) {
    return showDialog(
      context: context,
      builder: (context) {
        return new AlertDialog(
          title: new Text("提醒"),
          content: new Text("确定删除 ${tasks[index].name} 吗？"),
          actions: <Widget>[
            new FlatButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: new Text("确认"),
            ),
            new FlatButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: new Text("取消"),
            ),
          ],
        );
      }
    );
  }
}
