import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'screens/auth/login_screen.dart';
import 'screens/students/student_dashboard.dart';
import 'screens/teacher/teacher_dashboard.dart';
import 'utils/session_manager.dart';
import 'db/database_helper.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;

  final role = await SessionManager.getRole();

  Widget startScreen = const LoginScreen();

  if (role == 'student') {
    final userId = await SessionManager.getUserId();
    if (userId != null) {
      startScreen = StudentDashboard(userId: userId);
    }
  } else if (role == 'teacher') {
    startScreen = const TeacherDashboard();
  } else if (role == 'parent') {
    // parent session handled later
    startScreen = const LoginScreen();
  }

  runApp(MyApp(startScreen: startScreen));
}

class MyApp extends StatelessWidget {
  final Widget startScreen;
  const MyApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X baseline
      minTextAdapt: true,
      builder: (_, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          home: startScreen,
        );
      },
    );
  }
}
