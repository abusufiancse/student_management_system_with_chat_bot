import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/fee.dart';
import '../models/result.dart';
import '../models/student.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('student_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 10, // ⬅️ increase version
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );

  }
  // ================= FEE SUMMARY =================
  Future<Map<String, dynamic>> getFeeSummary(int studentId) async {
    final db = await database;

    final all = await db.query(
      'fees',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );

    double paid = 0;
    double due = 0;
    String? lastDueDate;

    for (final f in all) {
      final amount = (f['amount'] as num).toDouble();
      if (f['status'] == 'PAID') {
        paid += amount;
      } else {
        due += amount;
        lastDueDate = f['due_date'] as String;
      }
    }

    return {
      'total': paid + due,
      'paid': paid,
      'due': due,
      'lastDueDate': lastDueDate,
    };
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE,
        password TEXT,
        role TEXT,
        approved INTEGER
      )
    ''');
    }

    if (oldVersion < 3) {
      // 🔥 ADD user_id column to students table
      await db.execute(
        'ALTER TABLE students ADD COLUMN user_id INTEGER',
      );
    }
  }


  Future<void> _createDB(Database db, int version) async {
    // USERS
    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT UNIQUE,
      password TEXT,
      role TEXT,
      approved INTEGER
    )
  ''');

    // STUDENTS
    await db.execute('''
    CREATE TABLE students (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      name TEXT,
      class TEXT,
      roll TEXT UNIQUE,
      guardian TEXT
    )
  ''');

    // RESULTS
    await db.execute('''
    CREATE TABLE results (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      student_id INTEGER,
      subject TEXT,
      marks REAL,
      grade TEXT,
      comment TEXT
    )
  ''');

    // FEES
    await db.execute('''
    CREATE TABLE fees (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      student_id INTEGER,
      amount REAL,
      due_date TEXT,
      status TEXT
    )
  ''');
  }

  Future<void> updateResult(Result result) async {
    final db = await database;
    await db.update(
      'results',
      {
        'marks': result.marks,
        'grade': result.grade,
        'comment': result.comment,
      },
      where: 'id = ?',
      whereArgs: [result.id],
    );
  }

  Future<int> insertStudent(Student student) async {
    final db = await instance.database;

    debugPrint('🟢 INSERT STUDENT: ${student.toMap()}');

    return await db.insert('students', student.toMap());
  }


// FETCH all students
  Future<List<Student>> getAllStudents() async {
    final db = await instance.database;
    final result = await db.query('students');

    return result.map((e) => Student.fromMap(e)).toList();
  }

  // INSERT fee
  Future<int> insertFee(Fee fee) async {
    final db = await instance.database;
    return await db.insert('fees', fee.toMap());
  }

// GET fee by student
  Future<List<Fee>> getFeesByStudent(int studentId) async {
    final db = await instance.database;

    final result = await db.query(
      'fees',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );

    return result.map((e) => Fee.fromMap(e)).toList();
  }
// INSERT result
  Future<int> insertResult(Result result) async {
    final db = await instance.database;
    return await db.insert('results', result.toMap());
  }

// GET results by student
  Future<List<Result>> getResultsByStudent(int studentId) async {
    final db = await instance.database;

    final result = await db.query(
      'results',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );

    return result.map((e) => Result.fromMap(e)).toList();
  }

  Future<User?> login(String email, String password) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (res.isNotEmpty) {
      return User(
        id: res.first['id'] as int,
        email: res.first['email'] as String,
        password: res.first['password'] as String,
        role: res.first['role'] as String,
        approved: res.first['approved'] as int,
      );
    }
    return null;
  }

// REGISTER USER (Student / Parent)
  Future<int> registerUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

// LOGIN USER
  Future<User?> loginUser(String email, String password) async {
    try {
      final db = await database;

      final res = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );

      if (res.isNotEmpty) {
        return User.fromMap(res.first);
      }
      return null;
    } catch (e, s) {
      debugPrint('❌ LOGIN ERROR: $e');
      debugPrint('📌 STACK: $s');
      return null; // NEVER crash
    }
  }


// GET users by role
  Future<List<User>> getAllUsersByRole(String role) async {
    final db = await database;
    final res = await db.query('users', where: 'role = ?', whereArgs: [role]);
    return res.map((e) => User.fromMap(e)).toList();
  }

// UPDATE approval
  Future<void> updateUserApproval(int userId, int approved) async {
    final db = await database;
    await db.update(
      'users',
      {'approved': approved},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

// UPDATE student profile
  Future<void> updateStudent(Student student) async {
    final db = await database;
    await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

// DELETE student + user
  Future<void> deleteStudent(int userId) async {
    final db = await database;

    await db.delete('students', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }
// GET approved student by roll/index
  Future<Student?> getApprovedStudentByRoll(String roll) async {
    final db = await database;

    final res = await db.rawQuery('''
    SELECT s.* FROM students s
    JOIN users u ON u.id = s.user_id
    WHERE s.roll = ? AND u.approved = 1
  ''', [roll]);

    if (res.isNotEmpty) {
      return Student.fromMap(res.first);
    }
    return null;
  }

// GET student by userId (for student dashboard)
  Future<Student?> getStudentByUserId(int userId) async {
    final db = await database;
    final res =
    await db.query('students', where: 'user_id = ?', whereArgs: [userId]);

    if (res.isNotEmpty) {
      return Student.fromMap(res.first);
    }
    return null;
  }
// 🔢 Get next auto roll number
  Future<String> getNextStudentRoll() async {
    final db = await database;

    final res = await db.rawQuery(
      'SELECT MAX(CAST(roll AS INTEGER)) as maxRoll FROM students',
    );

    if (res.isNotEmpty && res.first['maxRoll'] != null) {
      final next = (res.first['maxRoll'] as int) + 1;
      return next.toString();
    }

    // First student roll
    return '1001';
  }


}
