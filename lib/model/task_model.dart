class TaskModel {
  final int? id;
  final String? taskName;
  final String? description;
  final int? isCompleted;
  final String? priority;
  final int? createdAt;

  TaskModel({
    this.id,
    this.taskName,
    this.isCompleted,
    this.description,
    this.priority,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) "id": id,
      "taskName": taskName,
      "description": description,
      "isCompleted": isCompleted ?? 0,
      "priority": priority,
      "createdAt": createdAt ?? DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      taskName: map["taskName"],
      isCompleted: map["isCompleted"],
      description: map["description"],
      priority: map["priority"],
      createdAt: map["createdAt"],
    );
  }
}
