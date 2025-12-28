import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class DueNotificationCard extends StatelessWidget {
  final int studentId;

  const DueNotificationCard({
    super.key,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: DatabaseHelper.instance.getFeeSummary(studentId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final data = snapshot.data!;
        final due = data['due'] as double;

        if (due <= 0) {
          return const SizedBox(); // 🔕 No notification
        }

        return Card(
          color: Colors.red.shade50,
          elevation: 2,
          child: ListTile(
            leading: const Icon(Icons.notifications_active,
                color: Colors.red),
            title: const Text(
              'Payment Due',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '৳$due pending. Last date: ${data['lastDueDate']}',
            ),
          ),
        );
      },
    );
  }
}
