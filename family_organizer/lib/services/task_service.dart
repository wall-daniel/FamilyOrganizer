import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:family_organizer/models/task.dart';
import 'package:family_organizer/common/api_config.dart'; // Import ApiConfig
import 'package:family_organizer/services/auth_service.dart';

class TaskService extends ChangeNotifier {
  final String _baseUrl = ApiConfig.baseUrl; // Use central API config
  final List<Task> _tasks = [];
  final AuthService _authService = AuthService();

  List<Task> get tasks => _tasks;

  Future<Map<String, String>> _getHeaders() async {
    String? token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'x-access-token': token ?? '',
    };
  }

  Future<void> fetchTasks() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/tasks'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        Iterable l = json.decode(response.body);
        _tasks.clear();
        _tasks.addAll(List<Task>.from(l.map((model) => Task.fromJson(model))));
        notifyListeners();
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      print('Error fetching tasks: $e');
      // Handle error
    }
  }

  Future<void> addTask(Task task) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/tasks'),
        headers: await _getHeaders(),
        body: json.encode(task.toJson()),
      );
      if (response.statusCode == 201) {
        final newTask = Task.fromJson(json.decode(response.body));
        _tasks.add(newTask);
        notifyListeners();
      } else {
        throw Exception('Failed to add task');
      }
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    if (task.id == null) {
      print('Error: Cannot update task without an ID.');
      return;
    }
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/tasks/${task.id}'),
        headers: await _getHeaders(),
        body: json.encode(task.toJson()),
      );
      if (response.statusCode == 200) {
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = task;
          notifyListeners();
        }
      } else {
        throw Exception('Failed to update task');
      }
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  Future<void> removeTask(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/tasks/$id'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        _tasks.removeWhere((task) => task.id == id);
        notifyListeners();
      } else {
        throw Exception('Failed to delete task');
      }
    } catch (e) {
      print('Error removing task: $e');
    }
  }

  // TODO: Add more methods for updating tasks, marking as complete, etc.
}
