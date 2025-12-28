import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/result.dart';
import '../utils/grade_helper.dart';

class ResultScreen extends StatefulWidget {
  final int studentId;
  const ResultScreen({super.key, required this.studentId});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<Result> results = [];

  @override
  void initState() {
    super.initState();
    loadResults();
  }

  Future<void> loadResults() async {
    final data =
    await DatabaseHelper.instance.getResultsByStudent(widget.studentId);
    setState(() => results = data);
  }

  Future<void> addDummyResult() async {
    final marks = 78.0;
    final grade = GradeHelper.getGrade(marks);

    final result = Result(
      studentId: widget.studentId,
      subject: 'Mathematics',
      marks: marks,
      grade: grade,
    );

    await DatabaseHelper.instance.insertResult(result);
    loadResults();
  }

  double calculateGPA() {
    if (results.isEmpty) return 0;
    final total = results
        .map((r) => GradeHelper.gradePoint(r.grade))
        .reduce((a, b) => a + b);
    return total / results.length;
  }

  @override
  Widget build(BuildContext context) {
    final gpa = calculateGPA();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: addDummyResult,
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.green.shade100,
            child: Text(
              'GPA: ${gpa.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const Center(child: Text('No results found'))
                : ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final r = results[index];
                return ListTile(
                  title: Text(r.subject),
                  subtitle:
                  Text('Marks: ${r.marks} | Grade: ${r.grade}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
