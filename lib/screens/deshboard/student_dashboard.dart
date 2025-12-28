import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import '../../models/student.dart';

class StudentDashboard extends StatefulWidget {
  final int userId;
  const StudentDashboard({super.key, required this.userId});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  Student? student;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final s =
    await DatabaseHelper.instance.getStudentByUserId(widget.userId);
    setState(() => student = s);
  }

  @override
  Widget build(BuildContext context) {
    if (student == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Student Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${student!.name}'),
            Text('Class: ${student!.studentClass}'),
            const SizedBox(height: 12),

            // 🔥 IMPORTANT FOR PARENTS
            Card(
              color: Colors.blue.shade50,
              child: ListTile(
                title: const Text('Your Roll is : '),
                subtitle: Text(
                  student!.roll,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
