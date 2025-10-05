class Meal {
  final int? id;
  String name;
  String date; // Changed from scheduledDate to date (String)
  int? recipeId; // Added recipeId to link to recipes

  Meal({
    this.id,
    required this.name,
    required this.date,
    this.recipeId,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      name: json['name'],
      date: json['date'] ?? '',
      recipeId: json['recipe_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'recipe_id': recipeId,
    };
  }
}
