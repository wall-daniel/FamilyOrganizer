class Recipe {
  final String id;
  String name;
  String description;
  List<String> ingredients;
  List<String> instructions;

  Recipe({
    required this.id,
    required this.name,
    this.description = '',
    this.ingredients = const [],
    this.instructions = const [],
  });

  // Optional: Add methods for serialization/deserialization if needed later
}
