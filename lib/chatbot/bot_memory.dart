class BotMemory {
  static final Map<int, String> _lastIntentByStudent = {};

  static void setLastIntent(int studentId, String intent) {
    _lastIntentByStudent[studentId] = intent;
  }

  static String? getLastIntent(int studentId) {
    return _lastIntentByStudent[studentId];
  }

  static void clear(int studentId) {
    _lastIntentByStudent.remove(studentId);
  }
}
