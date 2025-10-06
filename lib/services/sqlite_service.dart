import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';
import 'storage_service.dart';

class SQLiteService implements StorageService {
  static const String _databaseName = 'study_planner.db';
  static const int _databaseVersion = 1;
  static const String _tableName = 'tasks';
  
  Database? _database;

  @override
  String get storageType => 'SQLite';

  @override
  Future<void> initialize() async {
    if (_database != null) return;
    
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);
    
    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        dueDate INTEGER NOT NULL,
        reminderTime INTEGER,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');
  }

  @override
  Future<List<Task>> getAllTasks() async {
    if (_database == null) await initialize();
    
    final List<Map<String, dynamic>> maps = await _database!.query(_tableName);
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  @override
  Future<Task> addTask(Task task) async {
    if (_database == null) await initialize();
    
    final taskMap = task.toMap();
    taskMap.remove('id'); // Let SQLite auto-generate the ID
    
    final id = await _database!.insert(_tableName, taskMap);
    return task.copyWith(id: id);
  }

  @override
  Future<Task> updateTask(Task task) async {
    if (_database == null) await initialize();
    
    final updatedTask = task.copyWith(updatedAt: DateTime.now());
    await _database!.update(
      _tableName,
      updatedTask.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    
    return updatedTask;
  }

  @override
  Future<void> deleteTask(int id) async {
    if (_database == null) await initialize();
    
    await _database!.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Task>> getTasksForDate(DateTime date) async {
    if (_database == null) await initialize();
    
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
    
    final List<Map<String, dynamic>> maps = await _database!.query(
      _tableName,
      where: 'dueDate >= ? AND dueDate <= ?',
      whereArgs: [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
    );
    
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  @override
  Future<List<Task>> getTodayTasks() async {
    return getTasksForDate(DateTime.now());
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}