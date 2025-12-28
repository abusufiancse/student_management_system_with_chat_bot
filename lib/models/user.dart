class User {
  final int? id;
  final String email;
  final String password;
  final String role;     // teacher | student | parent
  final int approved;    // 0 or 1

  User({
    this.id,
    required this.email,
    required this.password,
    required this.role,
    required this.approved,
  });

  // 🔹 ADD THIS (FIX)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'role': role,
      'approved': approved,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
      approved: map['approved'],
    );
  }
}
