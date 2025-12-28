import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import '../../models/result.dart';
import '../../utils/grade_helper.dart';

class TeacherResultEntryScreen extends StatefulWidget {
  final int studentId;
  const TeacherResultEntryScreen({super.key, required this.studentId});

  @override
  State<TeacherResultEntryScreen> createState() =>
      _TeacherResultEntryScreenState();
}

class _TeacherResultEntryScreenState extends State<TeacherResultEntryScreen> {
  final subjectCtrl = TextEditingController();
  final marksCtrl = TextEditingController();
  final commentCtrl = TextEditingController();

  String? grade;
  String? remark;
  Color? gradeColor;

  // ================= SAVE RESULT =================
  void saveResult() async {
    final marks = double.tryParse(marksCtrl.text);

    if (subjectCtrl.text.trim().isEmpty || marks == null) {
      _snack('Please enter subject and valid marks');
      return;
    }

    final g = GradeHelper.getGrade(marks);

    final result = Result(
      studentId: widget.studentId,
      subject: subjectCtrl.text.trim(),
      marks: marks,
      grade: g,
      comment: commentCtrl.text.trim(),
    );

    await DatabaseHelper.instance.insertResult(result);

    if (!mounted) return;
    _snack('Result saved successfully');

    // Reset form
    subjectCtrl.clear();
    marksCtrl.clear();
    commentCtrl.clear();
    setState(() {
      grade = null;
      remark = null;
      gradeColor = null;
    });
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ================= LIVE GRADE CALC =================
  void onMarksChanged(String value) {
    final m = double.tryParse(value);

    if (m == null) {
      setState(() {
        grade = null;
        remark = null;
        gradeColor = null;
      });
      return;
    }

    final g = GradeHelper.getGrade(m);

    setState(() {
      grade = g;
      remark = GradeHelper.remark(g);
      gradeColor = GradeHelper.gradeColor(g);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Student Result'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= SUBJECT =================
            TextField(
              controller: subjectCtrl,
              decoration: const InputDecoration(
                labelText: 'Subject',
                prefixIcon: Icon(Icons.book),
              ),
            ),

            const SizedBox(height: 12),

            // ================= MARKS =================
            TextField(
              controller: marksCtrl,
              decoration: const InputDecoration(
                labelText: 'Marks',
                prefixIcon: Icon(Icons.score),
              ),
              keyboardType: TextInputType.number,
              onChanged: onMarksChanged,
            ),

            // ================= LIVE GRADE PREVIEW =================
            if (grade != null)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: gradeColor!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: gradeColor!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Grade: $grade',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: gradeColor,
                      ),
                    ),
                    Text(
                      remark!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: gradeColor,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // ================= TEACHER COMMENT =================
            TextField(
              controller: commentCtrl,
              decoration: const InputDecoration(
                labelText: 'Teacher Comment (optional)',
                prefixIcon: Icon(Icons.comment),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 24),

            // ================= SAVE BUTTON =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save Result'),
                onPressed: saveResult,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
