import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _keyRole = 'role';
  static const _keyUserId = 'user_id';
  static const _keyStudentRoll = 'student_roll';

  // ================= SAVE SESSION =================
  static Future<void> saveStudentSession(int userId) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyRole, 'student');
    await sp.setInt(_keyUserId, userId);
  }

  static Future<void> saveTeacherSession() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyRole, 'teacher');
  }

  static Future<void> saveParentSession(String roll) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyRole, 'parent');
    await sp.setString(_keyStudentRoll, roll);
  }

  // ================= READ SESSION =================
  static Future<String?> getRole() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_keyRole);
  }

  static Future<int?> getUserId() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getInt(_keyUserId);
  }

  static Future<String?> getParentRoll() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_keyStudentRoll);
  }

  // ================= LOGOUT =================
  static Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.clear();
  }
}
