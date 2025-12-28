import 'package:flutter/material.dart';
import 'package:student_management_system/screens/auth/parent_access_screen.dart';
import 'package:student_management_system/screens/auth/student_register_screen.dart';
import '../../db/database_helper.dart';
import '../deshboard/teacher_dashboard.dart';
import '../deshboard/student_dashboard.dart';

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

  // ================= STUDENT LOGIN =================
  void studentLogin() async {
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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => StudentDashboard(userId: user.id!),
      ),
    );
  }

  // ================= TEACHER LOGIN =================
  void teacherLogin() {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();

    if (email == 'teacher@gmail.com' && pass == 'teacher123') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TeacherDashboard()),
      );
    } else {
      _snack('Invalid teacher credentials');
    }
  }

  // ================= PARENT ACCESS =================
  void parentAccess() {
    if (rollCtrl.text.trim().isEmpty) {
      _snack('Enter student roll number');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ParentAccessScreen(initialRoll: rollCtrl.text.trim()),
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
          ElevatedButton(
            onPressed: studentLogin,
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const StudentRegisterScreen()),
              );
            },
            child: const Text('Student Registration'),
          )
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
          ElevatedButton(
            onPressed: teacherLogin,
            child: const Text('Login as Teacher'),
          ),
          const SizedBox(height: 10),
          const Text(
            'Demo Login:\nteacher@gmail.com\nteacher123',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          )
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
            decoration:
            const InputDecoration(labelText: 'Student Roll / Index Number'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: parentAccess,
            child: const Text('View Child Details'),
          ),
          const SizedBox(height: 10),
          const Text(
            'Parents can access student details\nusing roll/index number',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          )
        ],
      ),
    );
  }
}

