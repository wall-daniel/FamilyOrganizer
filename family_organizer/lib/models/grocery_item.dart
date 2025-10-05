class GroceryItem {
  final int? id;
  String name;
  String quantity; // Added quantity field
  bool isCompleted;

  GroceryItem({
    this.id, // Make id optional for new items
    required this.name,
    this.quantity = '',
    this.isCompleted = false,
  });

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'] ?? '', // Handle null quantity
      isCompleted: json['is_completed'] == 1, // SQLite boolean is 0 or 1
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'is_completed': isCompleted ? 1 : 0, // Convert bool to int for backend
    };
  }
}
