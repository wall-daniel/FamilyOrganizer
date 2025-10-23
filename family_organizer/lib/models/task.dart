import 'package:family_organizer/models/user.dart';

class Task {
  final int? id;
  String title;
  String description;
  bool completed;
  DateTime? dueDate;
  int? assignedUserId;
  User? assignedUser;

  Task({
    this.id,
    required this.title,
    this.description = '',
    this.completed = false,
    this.dueDate,
    this.assignedUserId,
    this.assignedUser,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      completed: json['completed'],
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      assignedUserId: json['assigned_user_id'],
      assignedUser: json['assigned_user'] != null ? User.fromJson(json['assigned_user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      'due_date': dueDate?.toIso8601String(),
      'assigned_user_id': assignedUserId,
    };
  }
}
