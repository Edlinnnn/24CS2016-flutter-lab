import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'student.dart';

// Singleton class that manages the SQLite database
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const String _dbName = 'karunya_students.db';
  static const String table = 'students';

  Database? _database;

  Future<Database> get database async {
    _database ??= await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    // On the web the database is kept in browser storage (IndexedDB)
    final String path =
        kIsWeb ? _dbName : p.join(await getDatabasesPath(), _dbName);

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            regNo TEXT NOT NULL UNIQUE,
            department TEXT NOT NULL,
            cgpa REAL NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // CREATE - insert a new student record
  Future<int> insertStudent(Student student) async {
    final db = await database;
    final data = student.toMap()..remove('id'); // id is auto-generated
    return db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  // READ - fetch all student records (newest first)
  Future<List<Student>> getAllStudents() async {
    final db = await database;
    final rows = await db.query(table, orderBy: 'id DESC');
    return rows.map((row) => Student.fromMap(row)).toList();
  }

  // READ - number of records stored
  Future<int> countStudents() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) AS total FROM $table');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}