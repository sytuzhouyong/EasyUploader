import '../utils//DBUtil.dart';
import 'task_vo.dart';
import 'package:flutter/services.dart';


class TaskManager {
  DBUtil dbUtil;
  UploadTaskCallback uploadTaskCallback;
  MethodChannel channel = new MethodChannel('channel.method.task-manager');

  // 单例 工厂模式
  factory TaskManager() =>_getInstance();
  static TaskManager get instance => _getInstance();
  static TaskManager _instance;
  static TaskManager _getInstance() {
    if (_instance == null) {
      _instance = new TaskManager._internal();
    }
    return _instance;
  }
  TaskManager._internal() {
    dbUtil = new DBUtil();

    uploadTaskCallback = (TaskModel model)  async {
      print('call uploadTaskCallback, $model');
      bool result = await channel.invokeMethod('startUploadTask', {'id':model.id, 'asset_url':model.assetUrl});
      print('invoke method startUploadTask result: ${result ? "success" : "failed"}');
      if (result) {
        int count = await updateTask({'id': model.id}, {'state': TaskState.Processing.index});
        if (count > 0) {
          model.state = TaskState.Processing;
        }
      }
      return model;
    };
  }

  /// 增加
  addTask(TaskModel task) async {
    String sql = insertSqlWithTask(task);

    int id = await dbUtil.insert(sql);
    print('add task, return id : $id');
    task.id = id;
  }

  /// 增加
  addTasks(List<TaskModel> tasks) async {
    List<String> sqlList = List();
    for (TaskModel task in tasks) {
      String sql = insertSqlWithTask(task);
      sqlList.add(sql);
    }
    List<int> ids = await dbUtil.insertBatch(sqlList);
    print('insert result ids = $ids');
  }

  /// 删除
  Future<bool> deleteTaskById(int id) async {
    String sql = 'DELETE FROM task where id=$id';
    int count = await dbUtil.delete(sql);
    print('delete task by id, return delete count: $count');
    return count > 0;
  }

  /// 更新
  /// 根据指定查询的条件更新指定的属性
  /// #Parameter queries: 查询条件
  /// #Parameter updates: 更新内容
  Future<int> updateTask(Map<String, dynamic> queries, Map<String, dynamic> updates) async {
    String querySql = generateAssignmentStatementWithMap(queries);
    String updateSql = generateAssignmentStatementWithMap(updates);
    String sql = 'UPDATE task SET ($updateSql) WHERE $querySql';
    int count  = await dbUtil.update(sql);
    return count;
  }

  /// 查询
  Future<List<TaskModel>> queryTask() async {
    String sql = 'SELECT * FROM task ORDER BY id DESC';
    List<Map> list = await dbUtil.query(sql);

    List<TaskModel> tasks = List();
    for(Map map in list) {
      TaskModel item = TaskModel.fromMap(map);
      tasks.add(item);
    }
//    print('query result : $tasks');
    return tasks;
  }


  String insertSqlWithTask(TaskModel task) {
    print('insertSqlWithTask: $task');
    String insertKeys = '';
    String insertValues = '';
    if (task.name != null) {
      insertKeys += 'name, ';
      insertValues += '"${task.name}", ';
    }
    if (task.totalSize > 0) {
      insertKeys += 'total_size, ';
      insertValues += '${task.totalSize}, ';
    }
    if (task.transferredSize > 0) {
      insertKeys += 'transferred_size, ';
      insertValues += '${task.transferredSize}, ';
    }
    if (task.state.index >= 0) {
      insertKeys += 'state, ';
      insertValues += '${task.state.index}, ';
    }
    if (task.assetUrl != null) {
      insertKeys += 'asset_url, ';
      insertValues += '"${task.assetUrl}", ';
    }
    if (task.thumbnailUrl != null) {
      insertKeys += 'thumbnail_url, ';
      insertValues += '"${task.thumbnailUrl}", ';
    }
    insertKeys = insertKeys.substring(0, insertKeys.length - 2);
    insertValues = insertValues.substring(0, insertValues.length - 2);
    String sql = 'INSERT INTO task ($insertKeys) values ($insertValues)';
    print('sql = $sql');
    return sql;
  }

  String generateAssignmentStatementWithMap(Map<String, dynamic> map) {
    List<String> statementItems = List();
    map.forEach((key, value) {
      var valueText = '$value';
      if (value is String) {
        valueText = "'$value'";
      }
      statementItems.add('$key = $valueText');
    });
    String statement = statementItems.join(', ');
    return statement;
  }
}