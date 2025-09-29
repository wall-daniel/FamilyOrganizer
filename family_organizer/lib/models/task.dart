class Task {
  final String id;
  String title;
  String description;
  bool isCompleted;
  DateTime? dueDate;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.dueDate,
  });

  // Optional: Add methods for serialization/deserialization if needed later
}
