import 'package:flutter/material.dart';

import '../../db/database_helper.dart';
import '../../models/student.dart';
import '../../models/result.dart';
import '../../models/fee.dart';
import '../../utils/grade_helper.dart';

class StudentDetailsScreen extends StatelessWidget {
  final Student student;
  final String role; // 'teacher' or 'parent'

  const StudentDetailsScreen({
    super.key,
    required this.student,
    required this.role,
  });

  bool get isTeacher => role == 'teacher';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= BASIC INFO =================
            Card(
              child: ListTile(
                title: Text(
                  student.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Class: ${student.studentClass}'),
                    Text('Roll: ${student.roll}'),
                    Text('Guardian: ${student.guardian}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ================= EXAM RESULTS =================
            const Text(
              'Exam Results',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            FutureBuilder<List<Result>>(
              future: DatabaseHelper.instance
                  .getResultsByStudent(student.id!),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No exam results found');
                }

                return Column(
                  children: snapshot.data!.map((r) {
                    final color = GradeHelper.gradeColor(r.grade);
                    return Card(
                      child: ListTile(
                        title: Text(
                          '${r.subject} (${_examType(r)})',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Marks: ${r.marks}'),
                            Text(
                              'Grade: ${r.grade} (${GradeHelper.remark(r.grade)})',
                              style: TextStyle(color: color),
                            ),
                            if (r.comment != null &&
                                r.comment!.isNotEmpty)
                              Text(
                                'Comment: ${r.comment}',
                                style: const TextStyle(
                                    fontStyle: FontStyle.italic),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 24),

            // ================= FEES =================
            const Text(
              'Fees & Payments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            FutureBuilder<List<Fee>>(
              future: DatabaseHelper.instance
                  .getFeesByStudent(student.id!),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No fee records found');
                }

                double total = 0;
                double paid = 0;

                for (var f in snapshot.data!) {
                  total += f.amount;
                  if (f.status == 'paid') paid += f.amount;
                }

                final due = total - paid;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...snapshot.data!.map((f) {
                      return Card(
                        child: ListTile(
                          title: Text(
                            _feeTitle(f),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Amount: ৳${f.amount} | Due: ${f.dueDate}',
                          ),
                          trailing: Chip(
                            label: Text(
                              f.status.toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: f.status == 'paid'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      );
                    }),

                    const Divider(),

                    Text(
                      'Total: ৳$total',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Paid: ৳$paid',
                      style: const TextStyle(color: Colors.green),
                    ),
                    Text(
                      'Due: ৳$due',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= HELPERS =================

  String _examType(Result r) {
    // You can later store exam_type in DB
    return 'Exam';
  }

  String _feeTitle(Fee f) {
    // Later you can differentiate: Monthly / Exam fee
    return 'Fee';
  }
}
