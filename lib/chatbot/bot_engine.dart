import '../db/database_helper.dart';
import '../models/student.dart';
import 'intent_detector.dart';

class BotEngine {
  static Future<String> reply({
    required String question,
    required int studentId,
    required String role, // 'student' or 'parent'
  }) async {
    final intent = IntentDetector.detect(question);
    final db = DatabaseHelper.instance;

    // 👋 GREETING
    if (intent == 'GREETING') {
      return role == 'parent'
          ? "Hello! 😊 I can help you with your child's results, fees, and profile."
          : "Hi! 👋 I can help you with your results, fees, and profile.";
    }

    // 🔎 Fetch student once
    final Student? student =
    await db.getStudentByUserId(studentId);

    if (student == null) {
      return "Student data not found.";
    }

    // 💰 FEES
    if (intent == 'FEE' || intent == 'PARENT_FEE') {
      final fees = await db.getFeesByStudent(studentId);
      if (fees.isEmpty) {
        return role == 'parent'
            ? "No fee records found for your child."
            : "No fee records found.";
      }

      final latest = fees.last;
      return role == 'parent'
          ? "Your child's fee amount is ৳${latest.amount}. "
          "Due date: ${latest.dueDate}. Status: ${latest.status}."
          : "Your fee amount is ৳${latest.amount}. "
          "Due date: ${latest.dueDate}. Status: ${latest.status}.";
    }

    // 📊 RESULTS
    if (intent == 'RESULT' || intent == 'PARENT_RESULT') {
      final results = await db.getResultsByStudent(studentId);
      if (results.isEmpty) {
        return role == 'parent'
            ? "No results published yet for your child."
            : "No results published yet.";
      }

      final summary = results
          .map((r) => "${r.subject}: ${r.grade}")
          .join(', ');

      return role == 'parent'
          ? "Your child's academic results are: $summary."
          : "Your academic results are: $summary.";
    }

    // 👤 PROFILE
    if (intent == 'PROFILE') {
      return role == 'parent'
          ? "Child Name: ${student.name}, "
          "Class: ${student.studentClass}, Roll: ${student.roll}."
          : "Name: ${student.name}, "
          "Class: ${student.studentClass}, Roll: ${student.roll}.";
    }

    // ❓ UNKNOWN
    return role == 'parent'
        ? "Sorry, I didn't understand. You can ask about your child's results, fees, or profile."
        : "Sorry, I didn't understand. You can ask about results, fees, or profile.";
  }
}
