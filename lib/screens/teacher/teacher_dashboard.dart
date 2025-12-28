import 'package:flutter/material.dart';
import 'package:student_management_system/db/database_helper.dart';
import 'package:student_management_system/screens/teacher/teacher_result_entry_screen.dart';
import 'package:student_management_system/screens/teacher/edit_result_screen.dart';

import '../../models/user.dart';
import '../../models/student.dart';
import '../../models/result.dart';
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

    if (!mounted) return;
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

  // ================= STUDENT DETAILS SHEET =================
  void showStudentDetails(BuildContext context, Student s, User u) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                s.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('Class: ${s.studentClass}'),
              Text('Roll: ${s.roll}'),
              Text('Guardian: ${s.guardian}'),
              Text(
                'Status: ${u.approved == 1 ? "Approved" : "Pending"}',
                style: TextStyle(
                  color:
                  u.approved == 1 ? Colors.green : Colors.orange,
                ),
              ),

              const Divider(height: 24),

              // ================= RESULTS SECTION =================
              const Text(
                'Academic Results',
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              FutureBuilder<List<Result>>(
                future: DatabaseHelper.instance
                    .getResultsByStudent(s.id!),
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
                      return Card(
                        child: ListTile(
                          title: Text(r.subject),
                          subtitle: Text(
                              'Marks: ${r.marks} | Grade: ${r.grade}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              final updated =
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditResultScreen(result: r),
                                ),
                              );

                              if (updated == true) {
                                Navigator.pop(context);
                                loadStudents();
                              }
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const Divider(height: 24),

              // ================= ACTIONS =================
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Add Result'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TeacherResultEntryScreen(
                        studentId: s.id!,
                      ),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          StudentEditScreen(userId: u.id!),
                    ),
                  );
                },
              ),

              ListTile(
                leading:
                const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Student'),
                onTap: () async {
                  Navigator.pop(context);
                  await confirmDelete(u);
                },
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // ================= STUDENT TILE =================
  Widget studentTile(User u) {
    return FutureBuilder<Student?>(
      future: getStudentProfile(u.id!),
      builder: (context, snapshot) {
        final s = snapshot.data;

        return Card(
          margin:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: ListTile(
            onTap: () {
              if (s != null) {
                showStudentDetails(context, s, u);
              }
            },
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
                  u.approved == 1
                      ? 'Approved'
                      : 'Pending Approval',
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
          ),
        );
      },
    );
  }

  // ================= UI =================
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
                MaterialPageRoute(
                    builder: (_) => const LoginScreen()),
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
              ? const Center(
            child: Text('No approved students'),
          )
              : ListView(
            children:
            approvedUsers.map(studentTile).toList(),
          ),
          pendingUsers.isEmpty
              ? const Center(
            child: Text('No pending students'),
          )
              : ListView(
            children:
            pendingUsers.map(studentTile).toList(),
          ),
        ],
      ),
    );
  }
}
