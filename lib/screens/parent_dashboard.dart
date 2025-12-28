import 'package:flutter/material.dart';

class ParentDashboard extends StatelessWidget {
  final int userId;
  const ParentDashboard({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Parent Dashboard')),
    );
  }
}
