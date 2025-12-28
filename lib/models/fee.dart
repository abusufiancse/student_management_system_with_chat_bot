class Fee {
  final int? id;
  final int studentId;
  final double amount;
  final String dueDate;
  final String status;

  Fee({
    this.id,
    required this.studentId,
    required this.amount,
    required this.dueDate,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'amount': amount,
      'due_date': dueDate,
      'status': status,
    };
  }

  factory Fee.fromMap(Map<String, dynamic> map) {
    return Fee(
      id: map['id'],
      studentId: map['student_id'],
      amount: map['amount'],
      dueDate: map['due_date'],
      status: map['status'],
    );
  }
}
