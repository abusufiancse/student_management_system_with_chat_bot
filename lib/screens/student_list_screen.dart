import 'package:flutter/material.dart';
import 'package:student_management_system/screens/result_screen.dart';
import '../db/database_helper.dart';
import '../models/student.dart';
import 'chat_screen.dart';
import 'fee_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<Student> students = [];

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    final data = await DatabaseHelper.instance.getAllStudents();
    setState(() => students = data);
  }

  Future<void> addDummyStudent() async {
    final student = Student(
      name: 'Rahim',
      studentClass: '10',
      roll: '15',
      guardian: 'Mr Karim',
    );

    await DatabaseHelper.instance.insertStudent(student);
    loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: addDummyStudent,
          )
        ],
      ),
      body: students.isEmpty
          ? const Center(child: Text('No students found'))
          : ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          final s = students[index];
          return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: ListTile(
            title: Text(
              s.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Class ${s.studentClass} | Roll ${s.roll}'),
            trailing: const Icon(Icons.more_vert),
            onTap: () => _openStudentActions(context, s),
          ),
          );
        },
      ),
    );
  }

  void _openStudentActions(BuildContext context, Student s) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),

            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              s.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.green),
              title: const Text('View Fees'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FeeScreen(studentId: s.id!),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.blue),
              title: const Text('View Result'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResultScreen(studentId: s.id!),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.smart_toy, color: Colors.deepPurple),
              title: const Text('Ask AI Assistant'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(studentId: s.id!),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

}
