import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/student.dart';

class StudentEditScreen extends StatefulWidget {
  final int userId;
  const StudentEditScreen({super.key, required this.userId});

  @override
  State<StudentEditScreen> createState() => _StudentEditScreenState();
}

class _StudentEditScreenState extends State<StudentEditScreen> {
  Student? student;

  final nameCtrl = TextEditingController();
  final classCtrl = TextEditingController();
  final rollCtrl = TextEditingController();
  final parentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final s =
    await DatabaseHelper.instance.getStudentByUserId(widget.userId);
    if (s != null) {
      student = s;
      nameCtrl.text = s.name;
      classCtrl.text = s.studentClass;
      rollCtrl.text = s.roll;
      parentCtrl.text = s.guardian;
      setState(() {});
    }
  }

  Future<void> save() async {
    if (student == null) return;

    final updated = Student(
      id: student!.id,
      name: nameCtrl.text,
      studentClass: classCtrl.text,
      roll: rollCtrl.text,
      guardian: parentCtrl.text,
    );

    await DatabaseHelper.instance.updateStudent(updated);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (student == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Student')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: classCtrl, decoration: const InputDecoration(labelText: 'Class')),
            TextField(controller: rollCtrl, decoration: const InputDecoration(labelText: 'Roll')),
            TextField(controller: parentCtrl, decoration: const InputDecoration(labelText: 'Parent Name')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: save, child: const Text('Save Changes')),
          ],
        ),
      ),
    );
  }
}
