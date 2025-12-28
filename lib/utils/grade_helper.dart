class GradeHelper {
  static String getGrade(double marks) {
    if (marks >= 80) return 'A+';
    if (marks >= 70) return 'A';
    if (marks >= 60) return 'A-';
    if (marks >= 50) return 'B';
    if (marks >= 40) return 'C';
    return 'F';
  }

  static double gradePoint(String grade) {
    switch (grade) {
      case 'A+':
        return 5.0;
      case 'A':
        return 4.0;
      case 'A-':
        return 3.5;
      case 'B':
        return 3.0;
      case 'C':
        return 2.0;
      default:
        return 0.0;
    }
  }
}
