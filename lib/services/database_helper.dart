import 'storage_service.dart';
import 'shared_preferences_service.dart';
import 'sqlite_service.dart';
import '../models/task.dart';

/// Database helper class for SQLite operations
/// Manages database creation, versioning, and table operations
/// Provides low-level database access for the SQLite service
class DatabaseHelper {
  static DatabaseHelper? _instance;
  static StorageService? _storageService;
  
  DatabaseHelper._internal();
  
  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  // Initialize with preferred storage method
  Future<void> initialize({bool useSQLite = false}) async {
    if (useSQLite) {
      _storageService = SQLiteService();
    } else {
      _storageService = SharedPreferencesService();
    }
    
    await _storageService!.initialize();
  }

  StorageService get storage {
    if (_storageService == null) {
      throw Exception('DatabaseHelper not initialized. Call initialize() first.');
    }
    return _storageService!;
  }

  // Convenience methods
  Future<List<Task>> getAllTasks() => storage.getAllTasks();
  Future<Task> addTask(Task task) => storage.addTask(task);
  Future<Task> updateTask(Task task) => storage.updateTask(task);
  Future<void> deleteTask(int id) => storage.deleteTask(id);
  Future<List<Task>> getTasksForDate(DateTime date) => storage.getTasksForDate(date);
  Future<List<Task>> getTodayTasks() => storage.getTodayTasks();
  String get storageType => storage.storageType;
}