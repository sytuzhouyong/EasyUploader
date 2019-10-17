
typedef UploadTaskCallback = Future<TaskModel> Function(TaskModel task);

enum TaskState {
  Ready,
  Processing,
  Done,
  Failed,
}

class TaskModel {
  int id;
  String name;          // 任务的名字
  int totalSize;        // 任务的数据大小 以B为单位
  int transferredSize;  // 任务已经传输的数据大小 以B为单位
  TaskState state;      // 传输状态
  String thumbnailUrl;  // 缩略图url
  String assetUrl;      // 原始资源url

  TaskModel({
    this.name,
    this.totalSize,
    this.transferredSize,
    this.state,
    this.thumbnailUrl,
    this.assetUrl,
  });

  static final Map<String, String> propertiesMap = {
    'totalSize': 'total_size',
    'transferredSize': 'transferred_size',
    'thumbnailUrl': 'thumbnail_url',
    'assetUrl': 'asset_url'
  };

  String processDesc() {
//    if (state == TaskState.Processing) {
      String p1 = dataSizeDesc(transferredSize);
      String p2 = dataSizeDesc(totalSize);
      return '$p1/$p2';
//    }
//    return '';
  }

  String dataSizeDesc(int size) {
    List suffix = ['B', 'K', 'M', 'G'];
    int index = 0;
    double result = size.toDouble();
    while(result >= 1024.0) {
      result = result / 1024;
      index++;
    }

    int fixLength = index < 2 ? 0 : 2;
    return result.toStringAsFixed(fixLength) + suffix[index];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      'id': id,
      'name': name,
      'total_size': totalSize,
      'transferred_size': transferredSize,
      'state': state.index,
      'thumbnail_url': thumbnailUrl,
      'asset_url': assetUrl,
    };
    return map;
  }

  TaskModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    totalSize = map['total_size'];
    transferredSize = map['transferred_size'];
    state = TaskState.values[map['state']];
    thumbnailUrl = map['thumbnail_url'];
    assetUrl = map['asset_url'];
  }

  /// TODO: 完成数据库字段和对象属性之间的映射关系
  static String columnName(String key) {
    if (propertiesMap.containsKey(key)) {
      print('xxx = ${propertiesMap[key]}');
      return propertiesMap[key];
    }
    return key;
  }

  @override
  String toString() {
    return '[$name, state: $state, totalSize: $totalSize, assetURL: $assetUrl, thumbURL: $thumbnailUrl]';
  }
}

//List<TaskModel> testTasks = [
//  TaskModel(name: '2017-12-10 12321.jpg', totalSize: 102400, transferredSize: 0, state: TaskState.Processing, thumbnailUrl: ''),
//  TaskModel(name: '2017-12-10 12322.jpg', totalSize: 102400, transferredSize: 0, state: TaskState.Processing, thumbnailUrl: ''),
//  TaskModel(name: '2017-12-10 12323.jpg', totalSize: 102400, transferredSize: 0, state: TaskState.Processing, thumbnailUrl: ''),
//];