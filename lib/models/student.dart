class Student {
  final int? id;
  final int? userId;
  final String name;
  final String studentClass;
  final String roll; // UNIQUE index number
  final String guardian;

  Student({
    this.id,
    this.userId,
    required this.name,
    required this.studentClass,
    required this.roll,
    required this.guardian,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'class': studentClass,
      'roll': roll,
      'guardian': guardian,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      studentClass: map['class'],
      roll: map['roll'],
      guardian: map['guardian'],
    );
  }
}
