import 'package:flutter/material.dart';
import '../services/reminder_service.dart';
import '../services/shared_preferences_service.dart';

/// Settings screen for app configuration
/// Provides toggles for reminders and displays storage information
/// Shows app statistics and storage method details
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ReminderService _reminderService = ReminderService();
  final SharedPreferencesService _storageService = SharedPreferencesService();
  bool _remindersEnabled = true;
  String _storageMethod = 'SharedPreferences';
  int _totalTasks = 0;
  int _completedTasks = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadTaskStats();
  }

  void _loadSettings() {
    setState(() {
      _remindersEnabled = _reminderService.remindersEnabled;
      _storageMethod = _storageService.storageType;
    });
  }

  Future<void> _loadTaskStats() async {
    try {
      await _storageService.initialize();
      final allTasks = await _storageService.getAllTasks();
      setState(() {
        _totalTasks = allTasks.length;
        _completedTasks = allTasks.where((task) => task.isCompleted).length;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  void _toggleReminders(bool value) {
    setState(() {
      _remindersEnabled = value;
    });
    _reminderService.setRemindersEnabled(value);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value ? 'Reminders enabled' : 'Reminders disabled',
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'David\'s Study Planner',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.school,
        size: 48,
        color: Colors.deepPurple,
      ),
      children: [
        const Text(
          'Developed by David Mwape - A comprehensive Flutter app for managing study tasks and schedules with calendar integration and reminders.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Features:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text('• Task management with due dates'),
        const Text('• Calendar view with task highlighting'),
        const Text('• Reminder notifications'),
        const Text('• Local data storage'),
        const Text('• Material Design UI'),
        const SizedBox(height: 16),
        const Text(
          'Developer: David Mwape',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
        ),
        const Text('Computer Science Student'),
        const Text('Flutter & Mobile App Development'),
      ],
    );
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'Are you sure you want to delete all tasks? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final allTasks = await _storageService.getAllTasks();
        for (final task in allTasks) {
          if (task.id != null) {
            await _storageService.deleteTask(task.id!);
          }
        }
        _loadTaskStats();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All data cleared successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error clearing data: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Reminders Section
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Enable Reminders'),
              subtitle: const Text('Get notified about upcoming tasks'),
              trailing: Switch(
                value: _remindersEnabled,
                onChanged: _toggleReminders,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Storage Section
          Card(
            child: ListTile(
              leading: const Icon(Icons.storage),
              title: const Text('Storage Method'),
              subtitle: Text('Currently using: $_storageMethod'),
              trailing: const Icon(Icons.info_outline),
            ),
          ),
          const SizedBox(height: 16),
          
          // Statistics Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.analytics),
                      const SizedBox(width: 8),
                      Text(
                        'Statistics',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Tasks:'),
                      Text('$_totalTasks'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Completed:'),
                      Text('$_completedTasks'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Pending:'),
                      Text('${_totalTasks - _completedTasks}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Data Management Section
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Clear All Data'),
              subtitle: const Text('Delete all tasks permanently'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _clearAllData,
            ),
          ),
          const SizedBox(height: 16),
          
          // Developer Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.deepPurple),
                      const SizedBox(width: 8),
                      Text(
                        'Developer Info',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(Icons.code, size: 16, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('David Mwape', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(Icons.school, size: 16, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Computer Science Student'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(Icons.flutter_dash, size: 16, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Flutter & Mobile Development'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // About Section
          Card(
            child: ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              subtitle: const Text('David\'s Study Planner v1.0.0 - By David Mwape'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _showAboutDialog,
            ),
          ),
        ],
      ),
    );
  }
}