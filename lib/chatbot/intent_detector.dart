class IntentDetector {
  static String detect(String question) {
    final q = question.toLowerCase();

    if (q.contains('fee') || q.contains('payment') || q.contains('due')) {
      return 'FEE';
    }

    if (q.contains('result') || q.contains('marks') || q.contains('grade')) {
      return 'RESULT';
    }

    if (q.contains('name') || q.contains('profile') || q.contains('class')) {
      return 'PROFILE';
    }

    return 'UNKNOWN';
  }
}
