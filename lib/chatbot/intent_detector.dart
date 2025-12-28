class IntentDetector {
  static String detect(String question) {
    final q = question.toLowerCase();

    // 👋 Greetings
    if (q.contains('hi') ||
        q.contains('hello') ||
        q.contains('hey') ||
        q.contains('assalam')) {
      return 'GREETING';
    }

    // ⏰ Due / overdue
    if (q.contains('due') ||
        q.contains('overdue') ||
        q.contains('late')) {
      return 'DUE_REMINDER';
    }

    // 👨‍👩‍👧 Parent-style questions
    if (q.contains('child') ||
        q.contains('kid') ||
        q.contains('son') ||
        q.contains('daughter')) {
      if (q.contains('fee') || q.contains('payment')) {
        return 'PARENT_FEE';
      }
      if (q.contains('result') ||
          q.contains('marks') ||
          q.contains('grade')) {
        return 'PARENT_RESULT';
      }
    }

    // 🎓 Student questions
    if (q.contains('fee') || q.contains('payment')) {
      return 'FEE';
    }

    if (q.contains('result') ||
        q.contains('marks') ||
        q.contains('grade')) {
      return 'RESULT';
    }

    if (q.contains('profile') ||
        q.contains('name') ||
        q.contains('class')) {
      return 'PROFILE';
    }

    return 'UNKNOWN';
  }
}
