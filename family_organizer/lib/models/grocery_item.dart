class GroceryItem {
  final int? id;
  String name;
  String quantity;
  String category; // New category field
  bool isCompleted;

  GroceryItem({
    this.id,
    required this.name,
    this.quantity = '',
    this.category = 'Other', // Default category
    this.isCompleted = false,
  });

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'] ?? '',
      category: json['category'] ?? 'Other',
      isCompleted: json['is_completed'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'category': category,
      'is_completed': isCompleted ? 1 : 0,
    };
  }
}
