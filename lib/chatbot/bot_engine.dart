import '../db/database_helper.dart';
import '../models/student.dart';
import 'intent_detector.dart';
import 'bot_memory.dart';

class BotEngine {
  static Future<String> reply({
    required String question,
    required int studentId,
    required String role, // student | parent
  }) async {
    final db = DatabaseHelper.instance;
    String intent = IntentDetector.detect(question);

    // ================= MEMORY FALLBACK =================
    if (intent == 'UNKNOWN') {
      final last = BotMemory.getLastIntent(studentId);
      if (last != null) {
        intent = last; // follow-up
      }
    }

    // ================= GREETING =================
    if (intent == 'GREETING') {
      BotMemory.clear(studentId);
      return role == 'parent'
          ? "Hello 😊 How can I help you about your child today?"
          : "Hi 👋 What would you like to know?";
    }

    // ================= LOAD STUDENT =================
    final Student? student =
    await db.getStudentByUserId(studentId);

    if (student == null) {
      return "I couldn’t find the student record.";
    }

    // ================= FEES =================
    if (intent == 'FEE' || intent == 'PARENT_FEE') {
      BotMemory.setLastIntent(studentId, 'FEE');

      final summary = await db.getFeeSummary(studentId);

      if (summary['total'] == 0) {
        return "There are no fee records available.";
      }

      final due = summary['due'] as double;

      if (due > 0) {
        return "💰 Total fees: ৳${summary['total']}\n"
            "Paid: ৳${summary['paid']}\n"
            "Due: ৳$due\n"
            "📅 Last date: ${summary['lastDueDate']}\n\n"
            "👉 You can ask: *any due?* or *payment status*";
      }

      return "✅ All fees are paid.\n"
          "👉 You can ask about results or profile.";
    }

    // ================= DUE =================
    if (intent == 'DUE_REMINDER') {
      BotMemory.setLastIntent(studentId, 'DUE_REMINDER');

      final summary = await db.getFeeSummary(studentId);

      if (summary['due'] <= 0) {
        return "✅ There is no pending due.";
      }

      return "⚠️ Pending due: ৳${summary['due']}\n"
          "📅 Pay before: ${summary['lastDueDate']}\n\n"
          "👉 Ask *fees status* for details.";
    }

    // ================= RESULTS =================
    if (intent == 'RESULT' || intent == 'PARENT_RESULT') {
      BotMemory.setLastIntent(studentId, 'RESULT');

      final results = await db.getResultsByStudent(studentId);

      if (results.isEmpty) {
        return "📘 No academic results have been published yet.";
      }

      // short human summary
      final grades = results.map((r) => r.grade).toList();
      final hasLow = grades.any((g) => g == 'D' || g == 'F');

      final subjects = results
          .map((r) => "${r.subject}: ${r.grade}")
          .join(', ');

      return "📊 Academic Results:\n$subjects\n\n"
          "${hasLow ? "⚠️ Some subjects need attention." : "✅ Overall performance is good."}\n"
          "👉 Ask *how is my child doing* or *subject wise result*";
    }

    // ================= PROFILE =================
    if (intent == 'PROFILE') {
      BotMemory.setLastIntent(studentId, 'PROFILE');

      return "👤 Profile Info:\n"
          "Name: ${student.name}\n"
          "Class: ${student.studentClass}\n"
          "Roll: ${student.roll}\n"
          "Guardian: ${student.guardian}\n\n"
          "👉 Ask about fees or results.";
    }

    // ================= SUMMARY =================
    if (intent == 'SUMMARY') {
      BotMemory.setLastIntent(studentId, 'SUMMARY');

      final summary = await db.getFeeSummary(studentId);
      final results = await db.getResultsByStudent(studentId);

      final feeLine = summary['due'] > 0
          ? "⚠️ Pending fee ৳${summary['due']}"
          : "✅ Fees are clear";

      final resultLine = results.isEmpty
          ? "📘 Results not published"
          : "📊 ${results.length} subjects evaluated";

      return "📌 Overall Summary:\n"
          "$feeLine\n"
          "$resultLine\n\n"
          "👉 You can ask:\n"
          "• fees status\n"
          "• results\n"
          "• profile";
    }

    // ================= HELP =================
    if (intent == 'HELP') {
      BotMemory.clear(studentId);
      return "🤖 You can ask things like:\n"
          "• fees status\n"
          "• any due?\n"
          "• my child result\n"
          "• profile info\n"
          "• is everything ok?";
    }

    // ================= FALLBACK =================
    return "🤔 I didn’t fully understand.\n"
        "👉 Try asking about fees, results, or profile.";
  }
}
