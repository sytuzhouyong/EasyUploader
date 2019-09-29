import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'transfer/task_list_widget.dart';

void main() => runApp(_widgetForRoute(ui.window.defaultRouteName));

// 根据iOS端传来的route跳转不同界面
Widget _widgetForRoute(String route) {
  print('route == $route');
  switch (route) {
    case 'myApp':
      return new MyApp();
    case 'task-list':
      return new TaskListWidget(title: '传输列表');
    default:
      return Center(
        child: Text('Unknown route: $route', textDirection: TextDirection.ltr),
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
        'task-list': (BuildContext context) => new TaskListWidget(title: '传输列表'),
      },
      home: Center(
        child: Text('Flutter View Controller', style: TextStyle(color: Colors.blue, fontSize: 20),),
      )
    );
  }
}
