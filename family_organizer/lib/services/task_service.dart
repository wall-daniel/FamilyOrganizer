import 'package:flutter/material.dart';
import 'package:family_organizer/models/task.dart'; // Assuming Task model will be created here

class TaskService extends ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void removeTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  // TODO: Add more methods for updating tasks, marking as complete, etc.
}
