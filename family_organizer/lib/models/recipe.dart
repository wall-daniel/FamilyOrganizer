class Recipe {
  final int? id;
  String name;
  List<String> ingredients;
  String instructions; // Changed from List<String> to String to match backend

  Recipe({
    this.id,
    required this.name,
    this.ingredients = const [],
    this.instructions = '',
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      ingredients: (json['ingredients'] as String? ?? '')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      instructions: json['instructions'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ingredients': ingredients.join(', '), // Convert list to comma-separated string
      'instructions': instructions,
    };
  }
}
