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
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
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
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        class TEXT,
        roll TEXT,
        guardian TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE fees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER,
        amount REAL,
        due_date TEXT,
        status TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER,
        subject TEXT,
        marks REAL,
        grade TEXT
      )
    ''');

  }
  // INSERT student
  Future<int> insertStudent(Student student) async {
    final db = await instance.database;
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


}
