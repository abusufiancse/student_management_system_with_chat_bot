import 'package:flutter/material.dart';

import '../../db/database_helper.dart';
import '../../models/student.dart';
import '../../models/user.dart';

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final classCtrl = TextEditingController();
  final parentCtrl = TextEditingController();
  final ageCtrl = TextEditingController();

  bool _showPassword = false;

  Future<void> register() async {
    try {
      final db = DatabaseHelper.instance;

      final user = User(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
        role: 'student',
        approved: 0,
      );

      final userId = await db.registerUser(user);
      final autoRoll = await db.getNextStudentRoll();

      final student = Student(
        userId: userId,
        name: nameCtrl.text.trim(),
        studentClass: classCtrl.text.trim(),
        roll: autoRoll,
        guardian: parentCtrl.text.trim(),
      );

      await db.insertStudent(student);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Registered successfully!\nAssigned Roll: $autoRoll\nWait for teacher approval',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e, stack) {
      debugPrint('❌ STUDENT REGISTER ERROR: $e');
      debugPrint('📌 STACK TRACE:\n$stack');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed. Check logs.')),
      );
    }
  }

  // ================= INPUT STYLE =================
  InputDecoration _input(String label, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF1F1F1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Student Registration',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Student Account',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Fill in the details below',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: emailCtrl,
              decoration: _input('Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),

            TextField(
              controller: passCtrl,
              obscureText: !_showPassword,
              decoration: _input(
                'Password',
                suffix: IconButton(
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() => _showPassword = !_showPassword);
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: nameCtrl,
              decoration: _input('Student Name'),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: classCtrl,
              decoration: _input('Class'),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: parentCtrl,
              decoration: _input('Parent Name'),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: ageCtrl,
              decoration: _input('Age'),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
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
