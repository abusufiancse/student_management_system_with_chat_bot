import 'package:flutter/material.dart';
import 'package:student_management_system/db/database_helper.dart';
import 'package:student_management_system/screens/teacher/student_details_screen.dart';
import '../../models/user.dart';
import '../../models/student.dart';
import '../auth/login_screen.dart';

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

  // ================= STUDENT TILE =================
  Widget studentTile(User u) {
    return FutureBuilder<Student?>(
      future: getStudentProfile(u.id!),
      builder: (context, snapshot) {
        final s = snapshot.data;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              // SWITCH
              Switch(
                value: u.approved == 1,
                onChanged: (_) => toggleApproval(u),
                activeColor: Colors.black,
              ),

              const SizedBox(width: 12),

              // INFO
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (s != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StudentDetailsScreen(
                            student: s,
                            user: u,
                          ),
                        ),
                      );
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s?.name ?? u.email,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (s != null)
                        Text(
                          'Class ${s.studentClass} • Roll ${s.roll}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      const SizedBox(height: 6),

                      // STATUS CHIP
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: u.approved == 1
                              ? Colors.green.withOpacity(0.12)
                              : Colors.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          u.approved == 1
                              ? 'Approved'
                              : 'Pending Approval',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: u.approved == 1
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'Teacher Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600),
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

      // ================= BODY =================
      body: Column(
        children: [
          // ================= TAB BAR =================
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.transparent,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(14),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              tabs: const [
                Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                  child: Text('Approved'),
                ),
                Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                  child: Text('Pending'),
                ),
              ],
            ),
          ),

          // ================= TAB VIEW =================
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                approvedUsers.isEmpty
                    ? const Center(
                  child: Text(
                    'No approved students',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
                    : ListView(
                  children:
                  approvedUsers.map(studentTile).toList(),
                ),
                pendingUsers.isEmpty
                    ? const Center(
                  child: Text(
                    'No pending students',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
                    : ListView(
                  children:
                  pendingUsers.map(studentTile).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
