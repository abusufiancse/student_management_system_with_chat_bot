import 'package:flutter/material.dart';
import 'package:student_management_system/screens/auth/parent_access_screen.dart';
import 'package:student_management_system/screens/auth/student_register_screen.dart';
import '../../db/database_helper.dart';
import '../../utils/session_manager.dart';
import '../parents/parent_dashboard.dart';
import '../teacher/teacher_dashboard.dart';
import '../students/student_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final rollCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    rollCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ================= STUDENT LOGIN =================
  Future<void> studentLogin() async {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();

    final user =
    await DatabaseHelper.instance.loginUser(email, pass);

    if (user == null) {
      _snack('Invalid credentials');
      return;
    }

    if (user.role != 'student') {
      _snack('Not a student account');
      return;
    }

    if (user.approved == 0) {
      _snack('Wait for teacher approval');
      return;
    }

    // ✅ SAVE SESSION
    await SessionManager.saveStudentSession(user.id!);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => StudentDashboard(userId: user.id!),
      ),
    );
  }

  // ================= TEACHER LOGIN =================
  Future<void> teacherLogin() async {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();

    if (email == 'teacher@gmail.com' && pass == 'teacher123') {
      // ✅ SAVE SESSION
      await SessionManager.saveTeacherSession();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TeacherDashboard()),
      );
    } else {
      _snack('Invalid teacher credentials');
    }
  }

  // ================= PARENT ACCESS =================
  Future<void> parentAccess() async {
    final roll = rollCtrl.text.trim();

    if (roll.isEmpty) {
      _snack('Enter student roll number');
      return;
    }

    // 🔎 Check approved student
    final student =
    await DatabaseHelper.instance.getApprovedStudentByRoll(roll);

    if (student == null) {
      _snack('No approved student found with this roll');
      return;
    }

    // ✅ SAVE SESSION
    await SessionManager.saveParentSession(roll);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ParentDashboard(student: student, role: 'parent',),
      ),
    );
  }



  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Student'),
            Tab(text: 'Teacher'),
            Tab(text: 'Parent'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          studentTab(),
          teacherTab(),
          parentTab(),
        ],
      ),
    );
  }

  // ================= STUDENT TAB =================
  Widget studentTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: emailCtrl,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: passCtrl,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: studentLogin,
              child: const Text('Login'),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentRegisterScreen(),
                ),
              );
            },
            child: const Text('Student Registration'),
          ),
        ],
      ),
    );
  }

  // ================= TEACHER TAB =================
  Widget teacherTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: emailCtrl,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: passCtrl,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: teacherLogin,
              child: const Text('Login as Teacher'),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Demo Login\nteacher@gmail.com\nteacher123',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ================= PARENT TAB =================
  Widget parentTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: rollCtrl,
            decoration: const InputDecoration(
              labelText: 'Student Roll: ',
              prefixIcon: Icon(Icons.badge),
            ),
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.visibility),
              label: const Text('View Child Dashboard'),
              onPressed: parentAccess, // ✅ ONLY HERE
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Parents can access student information\nusing the approved roll number',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

}

