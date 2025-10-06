import '../models/task.dart';

/// Abstract interface for storage services
/// Defines the contract for task storage implementations
/// Allows for easy switching between different storage methods
abstract class StorageService {
  /// Initializes the storage service
  /// Must be called before using other methods
  Future<void> initialize();
  Future<List<Task>> getAllTasks();
  /// Adds a new task to storage
  /// Returns the task with assigned ID
  Future<Task> addTask(Task task);
  Future<Task> updateTask(Task task);
  /// Deletes a task from storage by ID
  /// [id] - The unique identifier of the task to delete
  Future<void> deleteTask(int id);
  /// Retrieves all tasks for a specific date
  /// [date] - The date to filter tasks by
  Future<List<Task>> getTasksForDate(DateTime date);
  Future<List<Task>> getTodayTasks();
  /// Returns the type of storage being used
  /// Used for display in settings screen
  String get storageType;
}