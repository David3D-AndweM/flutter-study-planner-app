/// Task model class representing a single task/todo item
/// Contains all necessary fields for task management including
/// title, description, due date, reminder time, and completion status
class Task {
  final int? id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final DateTime? reminderTime;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.reminderTime,
    this.isCompleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Creates a copy of the task with updated fields
  /// Used for editing existing tasks while maintaining immutability
  /// Returns a new Task instance with specified fields updated
  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    DateTime? reminderTime,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      reminderTime: reminderTime ?? this.reminderTime,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Converts Task to Map for storage
  /// Used for database operations and serialization
  /// Returns a Map with all task fields as key-value pairs
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'reminderTime': reminderTime?.millisecondsSinceEpoch,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Factory constructor to create Task from Map
  /// Used for deserializing tasks from storage
  /// [map] - Map containing task data from database or storage
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id']?.toInt(),
      title: map['title'] ?? '',
      description: map['description'],
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate']),
      reminderTime: map['reminderTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['reminderTime'])
          : null,
      isCompleted: (map['isCompleted'] ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  /// Converts Task to JSON string for SharedPreferences storage
  /// Returns a JSON string representation of the task
  /// Used for simple local storage without external dependencies
  String toJson() {
    return '{"id":${id ?? 'null'},"title":"$title","description":"${description ?? ''}","dueDate":${dueDate.millisecondsSinceEpoch},"reminderTime":${reminderTime?.millisecondsSinceEpoch ?? 'null'},"isCompleted":${isCompleted ? 'true' : 'false'},"createdAt":${createdAt.millisecondsSinceEpoch},"updatedAt":${updatedAt.millisecondsSinceEpoch}}';
  }

  // Create Task from JSON string
  factory Task.fromJson(String jsonString) {
    // Simple JSON parsing for basic use case
    // Note: In production, consider using dart:convert for robust JSON handling
    final map = <String, dynamic>{};
    final cleanJson = jsonString.replaceAll('{', '').replaceAll('}', '');
    final pairs = cleanJson.split(',');
    
    for (final pair in pairs) {
      final keyValue = pair.split(':');
      if (keyValue.length == 2) {
        final key = keyValue[0].replaceAll('"', '').trim();
        final value = keyValue[1].replaceAll('"', '').trim();
        
        if (value == 'null') {
          map[key] = null;
        } else if (value == 'true') {
          map[key] = true;
        } else if (value == 'false') {
          map[key] = false;
        } else if (int.tryParse(value) != null) {
          map[key] = int.parse(value);
        } else {
          map[key] = value;
        }
      }
    }
    
    return Task.fromMap(map);
  }

  @override
  String toString() {
    return 'Task{id: $id, title: $title, description: $description, dueDate: $dueDate, reminderTime: $reminderTime, isCompleted: $isCompleted}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.dueDate == dueDate &&
        other.reminderTime == reminderTime &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        dueDate.hashCode ^
        reminderTime.hashCode ^
        isCompleted.hashCode;
  }
}