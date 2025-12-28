import 'package:flutter/material.dart';

import '../../models/student.dart';

class ParentDashboard extends StatelessWidget {
  final Student student;

  const ParentDashboard({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parent Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Child Name: ${student.name}'),
            Text('Class: ${student.studentClass}'),
            Text('Roll: ${student.roll}'),
            Text('Guardian: ${student.guardian}'),
          ],
        ),
      ),
    );
  }
}
