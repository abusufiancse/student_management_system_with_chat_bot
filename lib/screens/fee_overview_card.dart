import 'package:flutter/material.dart';
import '../../db/database_helper.dart';

class FeeOverviewCard extends StatelessWidget {
  final int studentId;
  const FeeOverviewCard({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: DatabaseHelper.instance.getFeeSummary(studentId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),

                _row('Total Fee', '৳${data['total']}'),
                _row(
                  'Paid',
                  '৳${data['paid']}',
                  color: Colors.green,
                ),
                _row(
                  'Due',
                  '৳${data['due']}',
                  color: Colors.red,
                ),
                if (data['lastDueDate'] != null)
                  _row(
                    'Last Due Date',
                    data['lastDueDate'],
                    color: Colors.orange,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _row(String title, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
