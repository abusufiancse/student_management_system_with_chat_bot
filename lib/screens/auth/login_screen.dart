import 'package:flutter/material.dart';
import 'package:student_management_system/screens/auth/student_register_screen.dart';
import '../../db/database_helper.dart';
import '../deshboard/teacher_dashboard.dart';
import '../student_dashboard.dart';
import '../parent_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String role = 'student';

  void login() async {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();

    // 🔐 Teacher (Hardcoded)
    if (email == 'teacher@gmail.com' && pass == 'teacher123') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TeacherDashboard()),
      );
      return;
    }

    final user =
    await DatabaseHelper.instance.loginUser(email, pass);

    if (user == null) {
      _snack('Invalid credentials');
      return;
    }

    // 🛑 Student approval check
    if (user.role == 'student' && user.approved == 0) {
      _snack('Wait for teacher approval');
      return;
    }

    // ✅ Role-based navigation
    if (user.role == 'student') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => StudentDashboard(userId: user.id!)),
      );
    } else if (user.role == 'parent') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ParentDashboard(userId: user.id!)),
      );
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
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
            const SizedBox(height: 12),

            DropdownButton<String>(
              value: role,
              items: const [
                DropdownMenuItem(value: 'student', child: Text('Student')),
                DropdownMenuItem(value: 'parent', child: Text('Parent')),
              ],
              onChanged: (v) => setState(() => role = v!),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) =>  StudentRegisterScreen()),
                );
              },
              child: const Text('Student Registration'),
            ),

          ],
        ),
      ),
    );
  }
}
