import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import '../../models/result.dart';

class StudentResultScreen extends StatelessWidget {
  final int studentId;
  const StudentResultScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Results')),
      body: FutureBuilder<List<Result>>(
        future: DatabaseHelper.instance.getResultsByStudent(studentId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final results = snapshot.data!;
          if (results.isEmpty) {
            return const Center(child: Text('No results found'));
          }

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, i) {
              final r = results[i];
              return ListTile(
                title: Text(r.subject),
                subtitle: Text('Marks: ${r.marks} | Grade: ${r.grade}'),
              );
            },
          );
        },
      ),
    );
  }
}
