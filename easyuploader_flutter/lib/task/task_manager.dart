import '../DBUtil/DBUtil.dart';
import 'task_vo.dart';


class TaskManager {
  DBUtil dbUtil;

  // 单例
  // 工厂模式
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
  }

  addTask(TaskModel task) async {
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
    if (task.thumbnailUrl != null) {
      insertKeys += 'thumbnail_url, ';
      insertValues += '"${task.thumbnailUrl}", ';
    }
    insertKeys = insertKeys.substring(0, insertKeys.length - 2);
    insertValues = insertValues.substring(0, insertValues.length - 2);
    String sql = 'INSERT INTO task ($insertKeys) values ($insertValues)';
    print('sql = $sql');

    int id = await dbUtil.insert(sql);
    print('add task, return id : $id');
    task.id = id;
  }

  Future<List<TaskModel>> queryTask() async {
    String sql = 'SELECT * FROM task';
    List<Map> list = await dbUtil.query(sql);

    List<TaskModel> tasks = List();
    for(Map map in list) {
      TaskModel item = TaskModel.fromMap(map);
      tasks.add(item);
    }
    print('query result : $tasks');
    return tasks;
  }
}