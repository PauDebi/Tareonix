import 'package:taskly/models/User.dart';

class Project {
  final String id;
  final String name;
  final String description;
  final String? leaderId; // Puede ser nulo si no hay líder
  final DateTime createdAt;
  final List<User?> members;

  Project({
    required this.id,
    required this.name,
    required this.description,
    this.leaderId,
    required this.createdAt,
    this.members = const [],
  });

  // Convertir JSON a un objeto Project
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      leaderId: json['lider_id'], // Puede ser null
      createdAt: DateTime.parse(json['createdAt']),
      members: (json['users'] as List<dynamic>).map((userJson) => User.fromJson(userJson)).toList(),
    );
  }

  // Convertir Project a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'lider_id': leaderId,
      'createdAt': createdAt.toIso8601String(),
      'users': members.map((user) => user?.toJson()).toList(),
    };
  }
}
