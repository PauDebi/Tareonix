class User {
  final String id;
  final DateTime createdAt;
  final String name;
  final String email;
  final String? imageUrl;

  User({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.email,
    this.imageUrl
  });

  // Convertir JSON a un objeto User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      name: json['name'],
      email: json['email'],
      imageUrl: json['imageUrl']
    );
  }

  // Convertir User a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'name': name,
      'email': email,
      'imageUrl': imageUrl
    };
  }
}