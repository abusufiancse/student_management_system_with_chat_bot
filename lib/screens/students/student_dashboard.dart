import 'package:flutter/material.dart';

import '../../chatbot/chat_screen.dart';
import '../../db/database_helper.dart';
import '../../models/result.dart';
import '../../models/student.dart';
import '../../utils/grade_helper.dart';
import '../../utils/session_manager.dart';
import '../auth/login_screen.dart';
import '../fee_overview_card.dart';

class StudentDashboard extends StatefulWidget {
  final int userId;
  const StudentDashboard({super.key, required this.userId});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  Student? student;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final s =
    await DatabaseHelper.instance.getStudentByUserId(widget.userId);
    if (!mounted) return;
    setState(() => student = s);
  }

  Future<void> _logout() async {
    // ✅ clear saved session
    await SessionManager.logout();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (student == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= STUDENT INFO =================
            Card(
              child: ListTile(
                title: Text(
                  student!.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Class: ${student!.studentClass}'),
                    Text('Roll: ${student!.roll}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            FeeOverviewCard(studentId: student!.id!),

            const SizedBox(height: 12),

            // ================= ROLL HIGHLIGHT =================
            Card(
              color: Colors.blue.shade50,
              child: ListTile(
                title: const Text('Your Roll / Index Number'),
                subtitle: Text(
                  student!.roll,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'My Academic Results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // ================= RESULTS =================
            FutureBuilder<List<Result>>(
              future: DatabaseHelper.instance
                  .getResultsByStudent(student!.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'No results published yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final results = snapshot.data!;

                return Column(
                  children: results.map((r) {
                    final color =
                    GradeHelper.gradeColor(r.grade);

                    return Card(
                      margin:
                      const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(
                          r.subject,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text('Marks: ${r.marks}'),
                            Text(
                              'Grade: ${r.grade} (${GradeHelper.remark(r.grade)})',
                              style: TextStyle(color: color),
                            ),
                            if (r.comment != null &&
                                r.comment!.isNotEmpty)
                              Padding(
                                padding:
                                const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Teacher Comment: ${r.comment}',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.smart_toy),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(studentId: student!.id!, role: 'student',),
            ),
          );
        },
      ),

    );
  }
}
