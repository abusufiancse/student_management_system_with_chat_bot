import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import '../../utils/session_manager.dart';
import '../parents/parent_dashboard.dart';
import '../teacher/teacher_dashboard.dart';
import '../students/student_dashboard.dart';
import 'student_register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final rollCtrl = TextEditingController();

  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    rollCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ================= STUDENT LOGIN =================
  Future<void> studentLogin() async {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();

    final user = await DatabaseHelper.instance.loginUser(email, pass);

    if (user == null) {
      _snack('Invalid credentials');
      return;
    }
    if (user.role != 'student') {
      _snack('Not a student account');
      return;
    }
    if (user.approved == 0) {
      _snack('Wait for teacher approval');
      return;
    }

    await SessionManager.saveStudentSession(user.id!);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => StudentDashboard(userId: user.id!),
      ),
    );
  }

  // ================= TEACHER LOGIN =================
  Future<void> teacherLogin() async {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();

    if (email == 'teacher@gmail.com' && pass == 'teacher123') {
      await SessionManager.saveTeacherSession();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TeacherDashboard()),
      );
    } else {
      _snack('Invalid teacher credentials');
    }
  }

  // ================= PARENT ACCESS =================
  Future<void> parentAccess() async {
    final roll = rollCtrl.text.trim();

    if (roll.isEmpty) {
      _snack('Enter student roll number');
      return;
    }

    final student =
    await DatabaseHelper.instance.getApprovedStudentByRoll(roll);

    if (student == null) {
      _snack('No approved student found with this roll');
      return;
    }

    await SessionManager.saveParentSession(roll);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ParentDashboard(
          student: student,
          role: 'parent',
        ),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // ===== TITLE =====
            const Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Login to continue',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 28),

            // ===== MODERN TAB BAR =====
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4), // outer padding
              decoration: BoxDecoration(
                color: const Color(0xFFF1F1F1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,

                // ❌ remove default underline
                indicatorColor: Colors.transparent,
                dividerColor: Colors.transparent,

                // ✅ pill indicator
                indicator: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(14),
                ),

                // spacing
                indicatorSize: TabBarIndicatorSize.tab,
                labelPadding: const EdgeInsets.symmetric(horizontal: 12),

                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,

                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),

                tabs: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Text('Student'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Text('Teacher'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Text('Parent'),
                  ),
                ],
              ),
            ),


            const SizedBox(height: 24),

            // ===== CONTENT =====
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _contentCard(studentTab()),
                  _contentCard(teacherTab()),
                  _contentCard(parentTab()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CARD =================
  Widget _contentCard(Widget child) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  // ================= INPUT =================
  Widget _input({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ================= STUDENT TAB =================
  Widget studentTab() {
    return Column(
      children: [
        _input(
          controller: emailCtrl,
          hint: 'Email address',
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 14),
        _input(
          controller: passCtrl,
          hint: 'Password',
          icon: Icons.lock_outline,
          obscure: _hidePassword,
          suffix: IconButton(
            icon: Icon(
              _hidePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: () {
              setState(() => _hidePassword = !_hidePassword);
            },
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: studentLogin,
            style: _primaryBtn(),
            child: const Text('Login'),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const StudentRegisterScreen(),
              ),
            );
          },
          child: const Text(
            'Create student account',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  // ================= TEACHER TAB =================
  Widget teacherTab() {
    return Column(
      children: [
        _input(
          controller: emailCtrl,
          hint: 'Teacher email',
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 14),
        _input(
          controller: passCtrl,
          hint: 'Password',
          icon: Icons.lock_outline,
          obscure: _hidePassword,
          suffix: IconButton(
            icon: Icon(
              _hidePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: () {
              setState(() => _hidePassword = !_hidePassword);
            },
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: teacherLogin,
            style: _primaryBtn(),
            child: const Text('Login as Teacher'),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Demo\nteacher@gmail.com\nteacher123',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // ================= PARENT TAB =================
  Widget parentTab() {
    return Column(
      children: [
        _input(
          controller: rollCtrl,
          hint: 'Student Roll / Index Number',
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: parentAccess,
            style: _primaryBtn(),
            child: const Text('View Child Dashboard'),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Access using approved roll number',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // ================= BUTTON STYLE =================
  ButtonStyle _primaryBtn() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}
