import 'package:flutter/material.dart';
import 'package:student_management_system/db/database_helper.dart';
import '../../models/user.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  List<User> students = [];

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    final db = DatabaseHelper.instance;
    final all = await db.getAllUsersByRole('student');
    setState(() => students = all);
  }

  Future<void> toggleApproval(User user) async {
    final db = DatabaseHelper.instance;
    await db.updateUserApproval(user.id!, user.approved == 1 ? 0 : 1);
    loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teacher Dashboard')),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          final u = students[index];
          return Card(
            child: ListTile(
              title: Text(u.email),
              subtitle: Text(u.approved == 1 ? 'Approved' : 'Pending'),
              trailing: Switch(
                value: u.approved == 1,
                onChanged: (_) => toggleApproval(u),
              ),
            ),
          );
        },
      ),
    );
  }
}
