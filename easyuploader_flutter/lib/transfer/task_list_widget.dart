import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'task_vo.dart';
import 'task_list_header_widget.dart';
import 'task_list_item_widget.dart';


class TaskListWidget extends StatefulWidget {

  final String title;
  final List<TransferTaskModel> tasks = testTasks; // 任务列表

  TaskListWidget({
    Key key,
    @required this.title,
  }): super(key: key);

  @override
  _TaskListWidgetState createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  // 列表滚动控制器
  final ScrollController _scrollController = new ScrollController();

  // 创建一个给native的channel (类似iOS的通知）
  static const methodChannel = const MethodChannel('easy-upload-ios');

//  void _incrementCounter() {
//    setState(() {
//    });
//  }

  _iOSPopVC() async {
    await methodChannel.invokeMethod('popVC');
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: () { _iOSPopVC(); },
            ),
            // 右侧按钮
            actions: <Widget>[
              GestureDetector(
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Icon(Icons.search),
                ), //
                onTap: () {
                  Navigator.pushNamed(context, 'search');
                },
              ),
            ],
          ),
          body: ListView.builder(
            controller: _scrollController,
            // 列表内容不足一屏时，列表也可以滑动
            physics: const AlwaysScrollableScrollPhysics(),
            // 元素的行高
//        itemExtent: 60,
            itemCount: widget.tasks.length,
            itemBuilder: (BuildContext context, int index) {
              TransferTaskModel task = widget.tasks[index];
              return Column(
                children: <Widget>[
                  Offstage(
                    offstage: index != 0,
                    child: TaskListHeaderWidget(
                        numberOfTask: widget.tasks.length,
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
