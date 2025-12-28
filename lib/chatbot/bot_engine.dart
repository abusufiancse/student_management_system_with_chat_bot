import '../db/database_helper.dart';
import '../chatbot/intent_detector.dart';

class BotEngine {
  static Future<String> reply(String question, int studentId) async {
    final intent = IntentDetector.detect(question);
    final db = DatabaseHelper.instance;

    switch (intent) {
      case 'FEE':
        final fees = await db.getFeesByStudent(studentId);
        if (fees.isEmpty) return "No fee records found.";

        final latest = fees.last;
        return "Your fee amount is ৳${latest.amount}. "
            "Due date is ${latest.dueDate} and status is ${latest.status}.";

      case 'PROFILE':
        final students = await db.getAllStudents();
        final s = students.firstWhere((e) => e.id == studentId);

        return "Student Name: ${s.name}, "
            "Class: ${s.studentClass}, Roll: ${s.roll}.";

      case 'RESULT':
        final results = await db.getResultsByStudent(studentId);
        if (results.isEmpty) return "No results found.";

        final subjects =
        results.map((r) => "${r.subject} (${r.grade})").join(', ');
        return "Your results are: $subjects.";

      default:
        return "Sorry, I didn't understand. You can ask about fees, profile or results.";
    }
  }
}
