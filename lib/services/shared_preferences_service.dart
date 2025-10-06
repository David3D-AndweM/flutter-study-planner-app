import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import 'storage_service.dart';

/// SharedPreferences implementation of StorageService
/// Provides local storage using Flutter's shared_preferences package
/// Stores tasks as JSON strings for simple persistence
class SharedPreferencesService implements StorageService {
  static const String _tasksKey = 'tasks';
  SharedPreferences? _prefs;

  @override
  String get storageType => 'SharedPreferences';

  @override
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<List<Task>> getAllTasks() async {
    if (_prefs == null) await initialize();
    
    final tasksJson = _prefs!.getStringList(_tasksKey) ?? [];
    return tasksJson.map((json) => Task.fromJson(json)).toList();
  }

  @override
  Future<Task> addTask(Task task) async {
    final tasks = await getAllTasks();
    
    // Generate a simple ID based on current timestamp
    final newId = DateTime.now().millisecondsSinceEpoch;
    final newTask = task.copyWith(id: newId);
    
    tasks.add(newTask);
    await _saveTasks(tasks);
    
    return newTask;
  }

  @override
  Future<Task> updateTask(Task task) async {
    final tasks = await getAllTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    
    if (index != -1) {
      tasks[index] = task.copyWith(updatedAt: DateTime.now());
      await _saveTasks(tasks);
      return tasks[index];
    }
    
    throw Exception('Task not found');
  }

  @override
  Future<void> deleteTask(int id) async {
    final tasks = await getAllTasks();
    tasks.removeWhere((task) => task.id == id);
    await _saveTasks(tasks);
  }

  @override
  Future<List<Task>> getTasksForDate(DateTime date) async {
    final tasks = await getAllTasks();
    final targetDate = DateTime(date.year, date.month, date.day);
    
    return tasks.where((task) {
      final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      return taskDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  @override
  Future<List<Task>> getTodayTasks() async {
    return getTasksForDate(DateTime.now());
  }

  Future<void> _saveTasks(List<Task> tasks) async {
    if (_prefs == null) await initialize();
    
    final tasksJson = tasks.map((task) => task.toJson()).toList();
    await _prefs!.setStringList(_tasksKey, tasksJson);
  }
}