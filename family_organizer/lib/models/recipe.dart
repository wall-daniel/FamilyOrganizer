import 'ingredient.dart';

class Recipe {
  final int? id;
  String name;
  List<Ingredient> ingredients;
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
      ingredients: (json['ingredients'] as List)
          .map((i) => Ingredient.fromJson(i))
          .toList(),
      instructions: (json['instructions'] is List)
          ? List<String>.from(json['instructions'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'instructions': instructions,
    };
  }
}
