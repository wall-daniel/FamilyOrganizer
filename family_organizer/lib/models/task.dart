class Task {
  final int? id;
  String title;
  String description;
  bool completed; // Changed from isCompleted to completed

  Task({
    this.id,
    required this.title,
    this.description = '',
    this.completed = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      completed: json['completed'] == 1, // SQLite boolean is 0 or 1
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed ? 1 : 0, // Convert bool to int for backend
    };
  }
}
