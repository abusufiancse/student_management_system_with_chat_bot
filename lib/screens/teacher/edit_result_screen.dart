import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import '../../models/result.dart';
import '../../utils/grade_helper.dart';

class EditResultScreen extends StatefulWidget {
  final Result result;
  const EditResultScreen({super.key, required this.result});

  @override
  State<EditResultScreen> createState() => _EditResultScreenState();
}

class _EditResultScreenState extends State<EditResultScreen> {
  late TextEditingController marksCtrl;
  late TextEditingController commentCtrl;

  @override
  void initState() {
    super.initState();
    marksCtrl =
        TextEditingController(text: widget.result.marks.toString());
    commentCtrl =
        TextEditingController(text: widget.result.comment ?? '');
  }

  Future<void> update() async {
    final marks = double.tryParse(marksCtrl.text);
    if (marks == null) return;

    final grade = GradeHelper.getGrade(marks);

    final updated = Result(
      id: widget.result.id,
      studentId: widget.result.studentId,
      subject: widget.result.subject,
      marks: marks,
      grade: grade,
      comment: commentCtrl.text.trim(),
    );

    await DatabaseHelper.instance.updateResult(updated);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Result')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              widget.result.subject,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: marksCtrl,
              decoration: const InputDecoration(labelText: 'Marks'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: commentCtrl,
              decoration:
              const InputDecoration(labelText: 'Teacher Comment'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: update,
              child: const Text('Update Result'),
            )
          ],
        ),
      ),
    );
  }
}
