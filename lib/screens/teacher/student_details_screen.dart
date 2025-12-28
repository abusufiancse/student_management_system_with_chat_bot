import 'package:flutter/material.dart';

import '../../db/database_helper.dart';
import '../../models/student.dart';
import '../../models/user.dart';
import '../../models/result.dart';
import '../../models/fee.dart';
import '../../utils/grade_helper.dart';
import 'teacher_result_entry_screen.dart';
import 'edit_result_screen.dart';

class StudentDetailsScreen extends StatelessWidget {
  final Student student;
  final User user;

  const StudentDetailsScreen({
    super.key,
    required this.student,
    required this.user,
  });
  Future<void> _addPayment(BuildContext context) async {
    final amountCtrl = TextEditingController();
    final dueDateCtrl = TextEditingController();
    DateTime? selectedDate;
    String status = 'DUE';

    final formKey = GlobalKey<FormState>();

    Future<void> pickDate() async {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(now.year - 1),
        lastDate: DateTime(now.year + 5),
      );

      if (picked != null) {
        selectedDate = picked;
        dueDateCtrl.text =
        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      }
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Payment'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ================= AMOUNT =================
              TextFormField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '৳ ',
                ),
                validator: (v) =>
                v == null || v.isEmpty ? 'Enter amount' : null,
              ),

              // ================= DATE PICKER =================
              TextFormField(
                controller: dueDateCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Due Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: pickDate,
                validator: (_) =>
                selectedDate == null ? 'Select due date' : null,
              ),

              const SizedBox(height: 12),

              // ================= STATUS =================
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'PAID', child: Text('PAID')),
                  DropdownMenuItem(value: 'DUE', child: Text('DUE')),
                ],
                onChanged: (v) => status = v!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await DatabaseHelper.instance.insertFee(
        Fee(
          studentId: student.id!,
          amount: double.parse(amountCtrl.text),
          dueDate: dueDateCtrl.text,
          status: status,
        ),
      );

      // 🔄 Refresh screen
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StudentDetailsScreen(
            student: student,
            user: user,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details'),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= PROFILE =================
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
                    Text(
                      'Status: ${user.approved == 1 ? "Approved" : "Pending"}',
                      style: TextStyle(
                        color: user.approved == 1
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ================= PAYMENT SUMMARY =================
            const Text(
              'Payment Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            FutureBuilder<Map<String, dynamic>>(
              future: DatabaseHelper.instance
                  .getFeeSummary(student.id!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(),
                  );
                }

                final f = snapshot.data!;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _row('Total', '৳${f['total']}'),
                        _row('Paid', '৳${f['paid']}', Colors.green),
                        _row('Due', '৳${f['due']}', Colors.red),
                        if (f['lastDueDate'] != null)
                          _row('Last Due Date',
                              f['lastDueDate'], Colors.orange),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // ================= ADD PAYMENT =================
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Payment'),
              onPressed: () => _addPayment(context),
            ),

            const Divider(height: 32),

            // ================= RESULTS =================
            const Text(
              'Academic Results',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            FutureBuilder<List<Result>>(
              future: DatabaseHelper.instance
                  .getResultsByStudent(student.id!),
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('No results added yet'),
                  );
                }

                final results = snapshot.data!;
                return Column(
                  children: results.map((r) {
                    final color = GradeHelper.gradeColor(r.grade);
                    return Card(
                      child: ListTile(
                        title: Text(r.subject),
                        subtitle: Text(
                          'Marks: ${r.marks} | Grade: ${r.grade}',
                          style: TextStyle(color: color),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditResultScreen(result: r),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              icon: const Icon(Icons.bar_chart),
              label: const Text('Add Result'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TeacherResultEntryScreen(
                      studentId: student.id!,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String title, String value, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
