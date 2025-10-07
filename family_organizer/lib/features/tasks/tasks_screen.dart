import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:family_organizer/services/task_service.dart';
import 'package:family_organizer/models/task.dart'; // Import the Task model

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  static const String routeName = '/tasks';

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch tasks after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskService>(context, listen: false).fetchTasks();
    });
  }

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
                  value: task.completed,
                  onChanged: (bool? value) {
                    if (task.id != null && value != null) {
                      taskService.updateTask(
                        Task(
                          id: task.id,
                          title: task.title,
                          description: task.description,
                          completed: value,
                        ),
                      );
                    }
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
      floatingActionButton: Consumer<TaskService>( // Wrap FAB in its own Consumer
        builder: (context, taskService, child) {
          return FloatingActionButton(
            onPressed: () {
              _showAddTaskDialog(context, taskService);
            },
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, TaskService taskService) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Task Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description (Optional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final newTask = Task(
                    title: titleController.text,
                    description: descriptionController.text,
                    completed: false,
                  );
                  taskService.addTask(newTask);
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
