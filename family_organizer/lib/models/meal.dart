class Meal {
  final String id;
  String name;
  String description;
  List<String> ingredients;
  DateTime scheduledDate; // Date for which the meal is planned

  Meal({
    required this.id,
    required this.name,
    this.description = '',
    this.ingredients = const [],
    required this.scheduledDate,
  });

  // Optional: Add methods for serialization/deserialization if needed later
}
