import 'package:flutter/material.dart';
import 'package:family_organizer/models/recipe.dart'; // Import the Recipe model

class RecipeService extends ChangeNotifier {
  final List<Recipe> _recipes = [];

  List<Recipe> get recipes => _recipes;

  void addRecipe(Recipe recipe) {
    _recipes.add(recipe);
    notifyListeners();
  }

  void removeRecipe(String id) {
    _recipes.removeWhere((recipe) => recipe.id == id);
    notifyListeners();
  }

  // TODO: Add methods for updating recipes, filtering, etc.
}
