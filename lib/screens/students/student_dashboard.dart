import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../chatbot/chat_screen.dart';
import '../../db/database_helper.dart';
import '../../models/homework.dart';
import '../../models/result.dart';
import '../../models/student.dart';
import '../../utils/ResultPerformanceChart.dart';
import '../../utils/grade_helper.dart';
import '../../utils/session_manager.dart';
import '../auth/login_screen.dart';

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
      backgroundColor: Colors.white,

      // ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
        automaticallyImplyLeading: true,
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= PROFILE CARD =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.black,
                    child: Text(
                      student!.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student!.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Class ${student!.studentClass} • Roll ${student!.roll}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= HOMEWORK =================
            const Text(
              'Today\'s Homework',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            FutureBuilder<List<Homework>>(
              future: DatabaseHelper.instance
                  .getHomeworkByDate(DateTime.now().toString().substring(0, 10)),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text('No homework today',style: TextStyle(color: Colors.grey.shade700),),
                  );
                }

                return Column(
                  children: snapshot.data!.map((h) {
                    return ListTile(
                      title: Text(h.title),
                      subtitle: Text(h.description),
                    );
                  }).toList(),
                );
              },
            ),


            const SizedBox(height: 24),

            // ================= RESULTS + GRAPH =================
            const Text(
              'Academic Results',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            FutureBuilder<List<Result>>(
              future: DatabaseHelper.instance
                  .getResultsByStudent(student!.id!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No results published yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final results = snapshot.data!;

                return Column(
                  children: [
                    // 📊 PERFORMANCE GRAPH
                    ResultPerformanceChart(results: results),

                    const SizedBox(height: 12),

                    // 🧩 GRID VIEW
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: results.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.98,
                      ),
                      itemBuilder: (context, index) {
                        final r = results[index];
                        final color =
                        GradeHelper.gradeColor(r.grade);

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F6F6),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.subject,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                r.marks.toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${r.grade} • ${GradeHelper.remark(r.grade)}',
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),

      // ================= AI BUTTON =================
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.smart_toy),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                studentId: student!.id!,
                role: 'student',
              ),
            ),
          );
        },
      ),
    );
  }
}
