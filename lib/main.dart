import 'package:flutter/material.dart';
import 'package:student_management_system/screens/auth/login_screen.dart';
import 'package:student_management_system/screens/auth/parent_access_screen.dart';
import 'package:student_management_system/screens/students/student_dashboard.dart';
import 'package:student_management_system/screens/teacher/teacher_dashboard.dart';
import 'package:student_management_system/utils/session_manager.dart';
import 'db/database_helper.dart';
import 'screens/student_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;

  final role = await SessionManager.getRole();

  Widget startScreen;

  if (role == 'student') {
    final userId = await SessionManager.getUserId();
    startScreen = StudentDashboard(userId: userId!);
  } else if (role == 'teacher') {
    startScreen = const TeacherDashboard();
  } else if (role == 'parent') {
    final roll = await SessionManager.getParentRoll();

    // ✅ Use ParentAccessScreen (not ParentDashboardByRoll)
    startScreen = ParentAccessScreen(initialRoll: roll!);
  } else {
    startScreen = const LoginScreen();
  }

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: startScreen,
    ),
  );
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
