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
  final ageCtrl = TextEditingController(); // optional

  Future<void> register() async {
    try {
      final db = DatabaseHelper.instance;

      // 1️⃣ Create user (NOT approved)
      final user = User(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
        role: 'student',
        approved: 0,
      );

      final userId = await db.registerUser(user);

      // 2️⃣ Auto roll
      final autoRoll = await db.getNextStudentRoll();

      // 3️⃣ Create student profile
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
      // 🔴 TERMINAL LOG
      debugPrint('❌ STUDENT REGISTER ERROR: $e');
      debugPrint('📌 STACK TRACE:\n$stack');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration failed. Check logs.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Registration')),
      body: SingleChildScrollView(
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
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Student Name'),
            ),
            TextField(
              controller: classCtrl,
              decoration: const InputDecoration(labelText: 'Class'),
            ),
            TextField(
              controller: parentCtrl,
              decoration: const InputDecoration(labelText: 'Parent Name'),
            ),
            TextField(
              controller: ageCtrl,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: register,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
