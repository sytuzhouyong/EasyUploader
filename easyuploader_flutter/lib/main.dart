import 'package:flutter/material.dart';
import 'transfer/task_vo.dart';
import 'transfer/task_list_header_widget.dart';
import 'transfer/task_list_item_widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: <String, WidgetBuilder> {
        'app': (BuildContext context) => new MyApp(),
      },
      home: TaskListWidget(title: '传输列表'),
    );
  }
}

class TaskListWidget extends StatefulWidget {
  TaskListWidget({Key key, this.title}) : super(key: key);

  final String title;
  List<TransferTaskModel> tasks = testTasks; // 任务列表
//  IndexedWidgetBuilder taskItemBuild; // cell构造器

  @override
  _TaskListWidgetState createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  // 列表滚动控制器
  final ScrollController _scrollController = new ScrollController();


  void _incrementCounter() {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: <Widget>[
          GestureDetector(
            child: Icon(Icons.search),
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
    );
  }
}
