class Student {
  final int? id;
  final String name;
  final String studentClass;
  final String roll;
  final String guardian;

  Student({
    this.id,
    required this.name,
    required this.studentClass,
    required this.roll,
    required this.guardian,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'class': studentClass,
      'roll': roll,
      'guardian': guardian,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'],
      studentClass: map['class'],
      roll: map['roll'],
      guardian: map['guardian'],
    );
  }
}
