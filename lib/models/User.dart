class User {
  final String id;
  final DateTime createdAt;
  final String name;
  final String email;
  final String? profile_image;

  User({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.email,
    this.profile_image
  });

  // Convertir JSON a un objeto User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      name: json['name'],
      email: json['email'],
      profile_image: json['profile_image']
    );
  }

  // Convertir User a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'name': name,
      'email': email,
      'profile_image': profile_image
    };
  }

  User copyWith({
    String? id,
    DateTime? createdAt,
    String? name,
    String? email,
    String? profile_image,
  }) {
    return User(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      email: email ?? this.email,
      profile_image: profile_image ?? this.profile_image,
    );
  }
}