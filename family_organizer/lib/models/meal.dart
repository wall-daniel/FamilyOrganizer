class Meal {
  final int? id;
  String name;
  String date; // Changed from scheduledDate to date (String)
  int? recipeId; // Added recipeId to link to recipes
  String? mealTime; // breakfast, lunch, dinner, snack

  Meal({
    this.id,
    required this.name,
    required this.date,
    this.recipeId,
    this.mealTime,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      name: json['name'],
      date: json['date'] ?? '',
      recipeId: json['recipe_id'],
      mealTime: json['meal_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'recipe_id': recipeId,
      'meal_time': mealTime,
    };
  }
}
