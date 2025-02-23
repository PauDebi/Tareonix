class User {
  final String id;
  final DateTime createdAt;
  final String name;
  final String email;
  final String? profile_image;
  final bool isVerified;

  User({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.email,
    this.profile_image,
    required this.isVerified
  });

  // Convertir JSON a un objeto User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      name: json['name'],
      email: json['email'],
      profile_image: json['profile_image'],
      isVerified: json['isVerified'] != null
    );
  }

  // Convertir User a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'name': name,
      'email': email,
      'profile_image': profile_image,
      'isVerified': isVerified
    };
  }

  User copyWith({
    String? id,
    DateTime? createdAt,
    String? name,
    String? email,
    String? profile_image,
    bool? isVerified
  }) {
    return User(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      email: email ?? this.email,
      profile_image: profile_image ?? this.profile_image,
      isVerified: isVerified ?? this.isVerified
    );
  }

  User nullUser() {
    return User(
      id: '',
      createdAt: DateTime.now(),
      name: '',
      email: '',
      profile_image: '',
      isVerified: false
    );
  }
}