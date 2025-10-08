class Recipe {
  final int? id;
  String name;
  List<String> ingredients;
  List<String> instructions;

  Recipe({
    this.id,
    required this.name,
    this.ingredients = const [],
    this.instructions = const [],
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      ingredients: (json['ingredients'] is List)
          ? List<String>.from(json['ingredients'])
          : [],
      instructions: (json['instructions'] is List)
          ? List<String>.from(json['instructions'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ingredients': ingredients,
      'instructions': instructions,
    };
  }
}
