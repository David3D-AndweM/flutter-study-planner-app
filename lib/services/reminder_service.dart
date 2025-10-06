import 'package:flutter/material.dart';
import '../models/task.dart';

/// Service for managing task reminders and notifications
/// Handles checking for due reminders and displaying alerts
/// Integrates with app lifecycle to check reminders when app becomes active
class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  bool _remindersEnabled = true;
  List<Task> _tasksWithReminders = [];

  bool get remindersEnabled => _remindersEnabled;

  void setRemindersEnabled(bool enabled) {
    _remindersEnabled = enabled;
  }

  void updateTasksWithReminders(List<Task> tasks) {
    _tasksWithReminders = tasks.where((task) => 
        task.reminderTime != null && 
        !task.isCompleted &&
        task.reminderTime!.isAfter(DateTime.now())
    ).toList();
  }

  List<Task> checkForDueReminders() {
    if (!_remindersEnabled) return [];
    
    final now = DateTime.now();
    final dueReminders = _tasksWithReminders.where((task) {
      if (task.reminderTime == null) return false;
      
      // Check if reminder time is within the last 5 minutes
      final timeDifference = now.difference(task.reminderTime!).inMinutes;
      return timeDifference >= 0 && timeDifference <= 5;
    }).toList();

    return dueReminders;
  }

  Future<void> showReminderDialog(BuildContext context, List<Task> dueTasks) async {
    if (dueTasks.isEmpty || !_remindersEnabled) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.notifications, color: Colors.orange),
            const SizedBox(width: 8),
            Text(dueTasks.length == 1 ? 'Task Reminder' : 'Task Reminders'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (dueTasks.length == 1)
                Text('You have a task due soon!')
              else
                Text('You have ${dueTasks.length} tasks due soon!'),
              const SizedBox(height: 16),
              ...dueTasks.map((task) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.task_alt, color: Colors.blue),
                    title: Text(task.title),
                    subtitle: task.description != null 
                        ? Text(task.description!)
                        : null,
                    trailing: Text(
                      _formatReminderTime(task.reminderTime!),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              )).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Dismiss'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Could navigate to today screen or specific task
            },
            child: const Text('View Tasks'),
          ),
        ],
      ),
    );
  }

  String _formatReminderTime(DateTime reminderTime) {
    final now = DateTime.now();
    final difference = reminderTime.difference(now);
    
    if (difference.inMinutes < 0) {
      return 'Overdue';
    } else if (difference.inMinutes == 0) {
      return 'Now';
    } else if (difference.inMinutes < 60) {
      return 'in ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'in ${difference.inHours}h';
    } else {
      return 'in ${difference.inDays}d';
    }
  }

  // Simulate checking reminders when app becomes active
  Future<void> checkRemindersOnAppResume(BuildContext context, List<Task> allTasks) async {
    updateTasksWithReminders(allTasks);
    final dueReminders = checkForDueReminders();
    
    if (dueReminders.isNotEmpty) {
      // Small delay to ensure UI is ready
      await Future.delayed(const Duration(milliseconds: 500));
      if (context.mounted) {
        await showReminderDialog(context, dueReminders);
      }
    }
  }
}