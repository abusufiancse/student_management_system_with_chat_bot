class Result {
  final int? id;
  final int studentId;
  final String subject;
  final double marks;
  final String grade;
  final String? comment;

  Result({
    this.id,
    required this.studentId,
    required this.subject,
    required this.marks,
    required this.grade,
    this.comment,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'student_id': studentId,
    'subject': subject,
    'marks': marks,
    'grade': grade,
    'comment': comment,
  };

  factory Result.fromMap(Map<String, dynamic> map) {
    return Result(
      id: map['id'],
      studentId: map['student_id'],
      subject: map['subject'],
      marks: map['marks'],
      grade: map['grade'],
      comment: map['comment'],
    );
  }
}
