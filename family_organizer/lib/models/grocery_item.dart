class GroceryItem {
  final String id;
  String name;
  bool isCompleted;

  GroceryItem({
    required this.id,
    required this.name,
    this.isCompleted = false,
  });

  // Optional: Add methods for serialization/deserialization if needed later
}
