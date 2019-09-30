import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'task/task_list_widget.dart';

void main() => runApp(_widgetForRoute(ui.window.defaultRouteName));
//void main() => runApp(MyApp());

// 根据iOS端传来的route跳转不同界面
Widget _widgetForRoute(String route) {
  print('route == $route');
  switch (route) {
    case 'task-list':
      return new TaskListWidget(title: '传输列表', pushFromIOS: true,);
    default:
      return MyApp();
  }
}

class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Default Main Page'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 100),),
              Text('Flutter View Controller', style: TextStyle(color: Colors.blue, fontSize: 20),),
              Padding(padding: EdgeInsets.only(top: 20),),
              IconButton(icon: Icon(Icons.forward), iconSize: 36, onPressed: () {
                Navigator.pushNamed(context, 'task-list');
//            Navigator.of(context).pushReplacementNamed('task-list');
              },)
            ],
          ),
        ),
      ),
    );
  }
}

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
        'task-list': (BuildContext context) => new TaskListWidget(title: '传输列表', pushFromIOS:false),
      },
      home: MyHome(),
    );
  }
}
