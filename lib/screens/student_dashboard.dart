import 'package:flutter/material.dart';

class StudentDashboard extends StatelessWidget {
  final int userId;
  const StudentDashboard({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Student Dashboard')),
    );
  }
}
