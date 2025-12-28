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
          ? "Hello 😊 I can help you with your child's fees, results, and profile."
          : "Hi 👋 I can help you with your fees, results, and profile.";
    }

    // 🔎 Load student
    final Student? student =
    await db.getStudentByUserId(studentId);

    if (student == null) {
      return "Student data not found.";
    }

    // ================= FEES & PAYMENT =================
    if (intent == 'FEE' || intent == 'PARENT_FEE') {
      final summary = await db.getFeeSummary(studentId);

      if (summary['total'] == 0) {
        return role == 'parent'
            ? "No fee records found for your child."
            : "No fee records found.";
      }

      final who = role == 'parent' ? "Your child" : "You";

      final due = summary['due'] as double;

      if (due > 0) {
        return "$who have total fees ৳${summary['total']}. "
            "Paid: ৳${summary['paid']}, Due: ৳$due. "
            "Please pay before ${summary['lastDueDate']}.";
      } else {
        return "✅ $who have no pending dues. All fees are paid.";
      }
    }

    // ⏰ DUE / OVERDUE REMINDER
    if (intent == 'DUE_REMINDER') {
      final summary = await db.getFeeSummary(studentId);

      if (summary['due'] <= 0) {
        return "✅ There are no pending fees at the moment.";
      }

      return "⚠️ Pending fee: ৳${summary['due']}. "
          "Last due date is ${summary['lastDueDate']}. "
          "Please clear it to avoid late penalties.";
    }

    // ================= RESULTS =================
    if (intent == 'RESULT' || intent == 'PARENT_RESULT') {
      final results = await db.getResultsByStudent(studentId);

      if (results.isEmpty) {
        return role == 'parent'
            ? "No results published yet for your child."
            : "No results published yet.";
      }

      final who = role == 'parent' ? "Your child's" : "Your";

      final summary = results
          .map((r) => "${r.subject}: ${r.grade}")
          .join(', ');

      return "$who academic results are: $summary.";
    }

    // ================= PROFILE =================
    if (intent == 'PROFILE') {
      return role == 'parent'
          ? "Child Name: ${student.name}, "
          "Class: ${student.studentClass}, Roll: ${student.roll}."
          : "Name: ${student.name}, "
          "Class: ${student.studentClass}, Roll: ${student.roll}.";
    }

    // ❓ FALLBACK
    return role == 'parent'
        ? "Sorry, I didn't understand. You can ask about your child's fees, results, or profile."
        : "Sorry, I didn't understand. You can ask about fees, dues, results, or profile.";
  }
}
