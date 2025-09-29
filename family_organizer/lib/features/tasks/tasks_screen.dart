import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:family_organizer/services/task_service.dart';
import 'package:family_organizer/models/task.dart'; // Import the Task model

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  static const String routeName = '/tasks';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Tasks'),
      ),
      body: Consumer<TaskService>(
        builder: (context, taskService, child) {
          if (taskService.tasks.isEmpty) {
            return const Center(
              child: Text('No tasks yet! Add one using the + button.'),
            );
          }
          return ListView.builder(
            itemCount: taskService.tasks.length,
            itemBuilder: (context, index) {
              final task = taskService.tasks[index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text(task.description),
                trailing: Checkbox(
                  value: task.isCompleted,
                  onChanged: (bool? value) {
                    // TODO: Implement task completion toggle
                  },
                ),
                onTap: () {
                  // TODO: Implement task editing
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement adding new task
          // For now, add a dummy task
          final newTask = Task(
            id: DateTime.now().toIso8601String(),
            title: 'New Task ${DateTime.now().second}',
            description: 'This is a dummy task.',
          );
          Provider.of<TaskService>(context, listen: false).addTask(newTask);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
