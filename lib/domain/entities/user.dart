class User {
  final int id;
  final String name;
  final String email;
  final String? phoneNumber;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
  });

  // Convert User to Map for database operations
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'email': email, 'phoneNumber': phoneNumber};
  }

  // Create User from Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      phoneNumber: map['phoneNumber'] as String?,
    );
  }

  // Copy with method for immutability
  User copyWith({int? id, String? name, String? email, String? phoneNumber}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
