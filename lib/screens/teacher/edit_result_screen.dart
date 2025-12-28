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

  // ================= INPUT STYLE =================
  InputDecoration _input(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF1F1F1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

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
          'Edit Result',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= SUBJECT HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.result.subject,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= MARKS =================
            TextField(
              controller: marksCtrl,
              keyboardType: TextInputType.number,
              decoration: _input('Marks', Icons.score),
            ),

            const SizedBox(height: 14),

            // ================= COMMENT =================
            TextField(
              controller: commentCtrl,
              maxLines: 2,
              decoration:
              _input('Teacher Comment', Icons.comment),
            ),

            const SizedBox(height: 28),

            // ================= UPDATE BUTTON =================
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.update),
                label: const Text(
                  'Update Result',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: update,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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
