import 'package:family_organizer/models/user.dart';
import 'package:family_organizer/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    // Fetch tasks and users after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskService>(context, listen: false).fetchTasks();
      Provider.of<UserService>(context, listen: false).fetchFamilyUsers();
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
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.description),
                    if (task.dueDate != null)
                      Text('Due: ${DateFormat.yMd().add_jm().format(task.dueDate!)}'),
                    if (task.assignedUser != null)
                      Text('Assigned to: ${task.assignedUser!.username}'),
                  ],
                ),
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
                          dueDate: task.dueDate,
                          assignedUserId: task.assignedUserId,
                        ),
                      );
                    }
                  },
                ),
                onTap: () {
                  _showAddTaskDialog(context, taskService, task: task);
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

  void _showAddTaskDialog(BuildContext context, TaskService taskService, {Task? task}) {
    final TextEditingController titleController = TextEditingController(text: task?.title);
    final TextEditingController descriptionController = TextEditingController(text: task?.description);
    DateTime? selectedDate = task?.dueDate;
    int? selectedUserId = task?.assignedUserId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(task == null ? 'Add New Task' : 'Edit Task'),
              content: SingleChildScrollView(
                child: Column(
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
                    const SizedBox(height: 20),
                    // Due Date Picker
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedDate == null
                                ? 'No due date'
                                : 'Due: ${DateFormat.yMd().add_jm().format(selectedDate!)}',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                            );
                            if (date != null) {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(selectedDate ?? DateTime.now()),
                              );
                              if (time != null) {
                                setState(() {
                                  selectedDate = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    time.hour,
                                    time.minute,
                                  );
                                });
                              }
                            }
                          },
                        )
                      ],
                    ),
                    // Assigned User Dropdown
                    Consumer<UserService>(
                      builder: (context, userService, child) {
                        if (userService.users.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return DropdownButtonFormField<int>(
                          value: selectedUserId,
                          hint: const Text('Assign to...'),
                          onChanged: (int? newValue) {
                            setState(() {
                              selectedUserId = newValue;
                            });
                          },
                          items: userService.users.map<DropdownMenuItem<int>>((User user) {
                            return DropdownMenuItem<int>(
                              value: user.id,
                              child: Text(user.username),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      final updatedTask = Task(
                        id: task?.id,
                        title: titleController.text,
                        description: descriptionController.text,
                        completed: task?.completed ?? false,
                        dueDate: selectedDate,
                        assignedUserId: selectedUserId,
                      );
                      if (task == null) {
                        taskService.addTask(updatedTask);
                      } else {
                        taskService.updateTask(updatedTask);
                      }
                    }
                    Navigator.pop(context);
                  },
                  child: Text(task == null ? 'Add' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
