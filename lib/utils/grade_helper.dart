import 'package:flutter/material.dart';

class GradeHelper {
  // ================= GRADE =================
  static String getGrade(double marks) {
    if (marks >= 80) return 'A+';
    if (marks >= 70) return 'A';
    if (marks >= 60) return 'A-';
    if (marks >= 50) return 'B';
    if (marks >= 40) return 'C';
    return 'F';
  }

  // ================= GRADE POINT =================
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

  // ================= REMARK =================
  static String remark(String grade) {
    switch (grade) {
      case 'A+':
        return 'Excellent';
      case 'A':
        return 'Best';
      case 'A-':
        return 'Impressive';
      case 'B':
        return 'Good';
      case 'C':
        return 'Average';
      default:
        return 'Needs Improvement';
    }
  }

  // ================= COLOR =================
  static Color gradeColor(String grade) {
    switch (grade) {
      case 'A+':
        return Colors.green;
      case 'A':
        return Colors.teal;
      case 'A-':
        return Colors.blue;
      case 'B':
        return Colors.orange;
      case 'C':
        return Colors.deepOrange;
      default:
        return Colors.red;
    }
  }
}
