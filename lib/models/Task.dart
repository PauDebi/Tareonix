class Task {
  String id;
  String name;
  String description;
  String projectId;
  String? assignedUserId;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.projectId,
    this.assignedUserId,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      projectId: map['project_id'],
      assignedUserId: map['assigned_user_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'project_id': projectId,
      'assigned_user_id': assignedUserId,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'project_id': projectId,
      'assigned_user_id': assignedUserId,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      projectId: json['project_id'],
      assignedUserId: json['assigned_user_id'],
    );
  }
}