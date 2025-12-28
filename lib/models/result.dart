class Result {
  final int? id;
  final int studentId;
  final String subject;
  final double marks;
  final String grade;

  Result({
    this.id,
    required this.studentId,
    required this.subject,
    required this.marks,
    required this.grade,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'subject': subject,
      'marks': marks,
      'grade': grade,
    };
  }

  factory Result.fromMap(Map<String, dynamic> map) {
    return Result(
      id: map['id'],
      studentId: map['student_id'],
      subject: map['subject'],
      marks: map['marks'],
      grade: map['grade'],
    );
  }
}
