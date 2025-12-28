import 'package:flutter/material.dart';
import 'package:student_management_system/db/database_helper.dart';
import '../../models/user.dart';
import '../student_edit_screen.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<User> approved = [];
  List<User> pending = [];

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
      approved = all.where((u) => u.approved == 1).toList();
      pending = all.where((u) => u.approved == 0).toList();
    });
  }

  Future<void> toggleApproval(User user) async {
    await DatabaseHelper.instance
        .updateUserApproval(user.id!, user.approved == 1 ? 0 : 1);
    loadStudents();
  }

  Future<void> deleteStudent(User user) async {
    await DatabaseHelper.instance.deleteStudent(user.id!);
    loadStudents();
  }

  Widget studentTile(User u) {
    return Card(
      child: ListTile(
        title: Text(u.email),
        subtitle:
        Text(u.approved == 1 ? 'Approved' : 'Pending Approval'),
        trailing: PopupMenuButton<String>(
          onSelected: (v) async {
            if (v == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudentEditScreen(userId: u.id!),
                ),
              ).then((_) => loadStudents());
            } else if (v == 'delete') {
              await deleteStudent(u);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        leading: Switch(
          value: u.approved == 1,
          onChanged: (_) => toggleApproval(u),
        ),
      ),
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
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView(children: approved.map(studentTile).toList()),
          ListView(children: pending.map(studentTile).toList()),
        ],
      ),
    );
  }
}

