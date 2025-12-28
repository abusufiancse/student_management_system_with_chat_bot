import 'package:flutter/material.dart';
import 'package:student_management_system/db/database_helper.dart';
import 'package:student_management_system/screens/teacher/teacher_result_entry_screen.dart';

import '../../models/user.dart';
import '../../models/student.dart';
import '../auth/login_screen.dart';
import '../student_edit_screen.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<User> approvedUsers = [];
  List<User> pendingUsers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadStudents();
  }

  Future<void> loadStudents() async {
    final all =
    await DatabaseHelper.instance.getAllUsersByRole('student');

    setState(() {
      approvedUsers = all.where((u) => u.approved == 1).toList();
      pendingUsers = all.where((u) => u.approved == 0).toList();
    });
  }

  Future<void> toggleApproval(User user) async {
    await DatabaseHelper.instance.updateUserApproval(
      user.id!,
      user.approved == 1 ? 0 : 1,
    );
    loadStudents();
  }

  Future<void> confirmDelete(User user) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Student'),
        content:
        const Text('This will permanently remove the student. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await DatabaseHelper.instance.deleteStudent(user.id!);
      loadStudents();
    }
  }

  Future<Student?> getStudentProfile(int userId) {
    return DatabaseHelper.instance.getStudentByUserId(userId);
  }

  Widget studentTile(User u) {
    return FutureBuilder<Student?>(
      future: getStudentProfile(u.id!),
      builder: (context, snapshot) {
        final s = snapshot.data;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: ListTile(
            title: Text(
              s?.name ?? u.email,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (s != null)
                  Text('Class: ${s.studentClass} | Roll: ${s.roll}'),
                Text(
                  u.approved == 1 ? 'Approved' : 'Pending Approval',
                  style: TextStyle(
                    color: u.approved == 1
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),
            leading: Switch(
              value: u.approved == 1,
              onChanged: (_) => toggleApproval(u),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudentEditScreen(userId: u.id!),
                    ),
                  ).then((_) => loadStudents());
                }

                if (v == 'result' && s != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TeacherResultEntryScreen(studentId: s.id!),
                    ),
                  );
                }

                if (v == 'delete') {
                  await confirmDelete(u);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit Profile'),
                ),
                PopupMenuItem(
                  value: 'result',
                  child: Text('Add Result'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Approved'),
            Tab(text: 'Pending'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          approvedUsers.isEmpty
              ? const Center(child: Text('No approved students'))
              : ListView(children: approvedUsers.map(studentTile).toList()),
          pendingUsers.isEmpty
              ? const Center(child: Text('No pending students'))
              : ListView(children: pendingUsers.map(studentTile).toList()),
        ],
      ),
    );
  }
}
