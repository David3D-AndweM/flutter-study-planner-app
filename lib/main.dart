// Main entry point for the Study Planner App
// This Flutter application provides task management with calendar integration
// and local storage capabilities

import 'package:flutter/material.dart';
import 'screens/today_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/settings_screen.dart';
import 'services/reminder_service.dart';
import 'services/shared_preferences_service.dart';

void main() {
  runApp(const StudyPlannerApp());
}

class StudyPlannerApp extends StatelessWidget {
  const StudyPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'David\'s Study Planner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  final ReminderService _reminderService = ReminderService();
  final SharedPreferencesService _storageService = SharedPreferencesService();

  static const List<Widget> _screens = <Widget>[
    TodayScreen(),
    CalendarScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkRemindersOnStart();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkRemindersOnResume();
    }
  }

  Future<void> _checkRemindersOnStart() async {
    // Small delay to ensure UI is ready
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      _checkRemindersOnResume();
    }
  }

  Future<void> _checkRemindersOnResume() async {
    try {
      await _storageService.initialize();
      final allTasks = await _storageService.getAllTasks();
      if (mounted) {
        await _reminderService.checkRemindersOnAppResume(context, allTasks);
      }
    } catch (e) {
      // Silently handle errors to avoid disrupting user experience
      debugPrint('Error checking reminders: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: _onItemTapped,
      ),
    );
  }
}
