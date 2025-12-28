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

  // ================= INPUT DECOR =================
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
          'Enter Student Result',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= SUBJECT =================
            TextField(
              controller: subjectCtrl,
              decoration: _input('Subject', Icons.book),
            ),

            const SizedBox(height: 14),

            // ================= MARKS =================
            TextField(
              controller: marksCtrl,
              decoration: _input('Marks', Icons.score),
              keyboardType: TextInputType.number,
              onChanged: onMarksChanged,
            ),

            // ================= LIVE GRADE =================
            if (grade != null)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: gradeColor!.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: gradeColor!, width: 1),
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

            const SizedBox(height: 18),

            // ================= COMMENT =================
            TextField(
              controller: commentCtrl,
              decoration:
              _input('Teacher Comment (optional)', Icons.comment),
              maxLines: 2,
            ),

            const SizedBox(height: 28),

            // ================= SAVE =================
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text(
                  'Save Result',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                onPressed: saveResult,
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
