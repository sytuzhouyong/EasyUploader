

enum TaskState {
  Read,
  Processing,
  Done,
  Failed,
}

class TaskModel {
  int id;
  String name;              // 任务的名字
  int totalSize;        // 任务的数据大小 以B为单位
  int transferredSize;  // 任务已经传输的数据大小 以B为单位
  TaskState state;      // 传输状态
  String thumbnailUrl;      // 缩略图url

  TaskModel({
    this.name,
    this.totalSize,
    this.transferredSize,
    this.state,
    this.thumbnailUrl
  });

  String processDesc() {
    if (state == TaskState.Processing) {
      String p1 = dataSizeDesc(transferredSize);
      String p2 = dataSizeDesc(totalSize);
      return '$p1/$p2';
    }
    return '';
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
  }
}

List<TaskModel> testTasks = [
  TaskModel(name: '2017-12-10 12321.jpg', totalSize: 102400, transferredSize: 0, state: TaskState.Processing, thumbnailUrl: ''),
  TaskModel(name: '2017-12-10 12322.jpg', totalSize: 102400, transferredSize: 0, state: TaskState.Processing, thumbnailUrl: ''),
  TaskModel(name: '2017-12-10 12323.jpg', totalSize: 102400, transferredSize: 0, state: TaskState.Processing, thumbnailUrl: ''),
];