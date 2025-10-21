import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:family_organizer/models/task.dart';
import 'package:family_organizer/common/api_config.dart';
import 'package:family_organizer/common/http_client.dart';

class TaskService extends ChangeNotifier {
  final String _baseUrl = ApiConfig.baseUrl;
  final List<Task> _tasks = [];
  final HttpClient _httpClient = HttpClient();

  List<Task> get tasks => _tasks;

  Future<void> fetchTasks() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/tasks'),
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
    }
  }

  Future<void> addTask(Task task) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/tasks'),
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
      final response = await _httpClient.put(
        Uri.parse('$_baseUrl/tasks/${task.id}'),
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
      final response = await _httpClient.delete(
        Uri.parse('$_baseUrl/tasks/$id'),
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
}
