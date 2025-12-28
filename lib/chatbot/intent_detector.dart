class IntentDetector {
  static String detect(String question) {
    final q = question.toLowerCase().trim();

    // ================= GREETING =================
    if (q.length <= 6 &&
        [
          'hi',
          'hello',
          'hey',
          'assalam',
          'assalamu alaikum',
          'thanks',
          'thank you'
        ].contains(q)) {
      return 'GREETING';
    }

    // ================= ACK / CONFIRM =================
    if (q == 'ok' ||
        q == 'okay' ||
        q == 'fine' ||
        q == 'alright' ||
        q == 'cool') {
      return 'ACK';
    }

    // ================= GENERAL / HEALTH =================
    if (q.contains('everything') ||
        q.contains('all good') ||
        q.contains('overall') ||
        q.contains('status') ||
        q.contains('summary') ||
        q.contains('overview') ||
        q.contains('doing') ||
        q.contains('condition')) {
      return 'SUMMARY';
    }

    // ================= DUE / OVERDUE =================
    if (q == 'due' ||
        q.contains('any due') ||
        q.contains('pending') ||
        q.contains('overdue') ||
        q.contains('late') ||
        q.contains('not paid')) {
      return 'DUE_REMINDER';
    }

    // ================= PARENT CONTEXT =================
    if (q.contains('child') ||
        q.contains('kid') ||
        q.contains('son') ||
        q.contains('daughter') ||
        q.contains('my boy') ||
        q.contains('my girl')) {
      if (q.contains('fee') ||
          q.contains('fees') ||
          q.contains('payment') ||
          q.contains('money')) {
        return 'PARENT_FEE';
      }

      if (q.contains('result') ||
          q.contains('marks') ||
          q.contains('grade') ||
          q.contains('performance') ||
          q.contains('study') ||
          q.contains('progress')) {
        return 'PARENT_RESULT';
      }

      // fallback: parent asking generally
      return 'SUMMARY';
    }

    // ================= FEES =================
    if (q.contains('fee') ||
        q.contains('fees') ||
        q.contains('payment') ||
        q.contains('paid') ||
        q.contains('pay') ||
        q.contains('balance') ||
        q.contains('amount') ||
        q.contains('money')) {
      return 'FEE';
    }

    // ================= RESULTS =================
    if (q == 'result' ||
        q == 'results' ||
        q.contains('marks') ||
        q.contains('grade') ||
        q.contains('score') ||
        q.contains('performance') ||
        q.contains('progress') ||
        q.contains('study') ||
        q.contains('academics') ||
        q.contains('exam')) {
      return 'RESULT';
    }

    // ================= PROFILE =================
    if (q.contains('profile') ||
        q.contains('info') ||
        q.contains('details') ||
        q.contains('name') ||
        q.contains('class') ||
        q.contains('roll') ||
        q.contains('guardian') ||
        q.contains('parent name')) {
      return 'PROFILE';
    }

    // ================= HELP =================
    if (q == 'help' ||
        q.contains('what can you do') ||
        q.contains('how can you help')) {
      return 'HELP';
    }

    return 'UNKNOWN';
  }
}
