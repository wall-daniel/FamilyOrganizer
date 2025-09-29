import 'package:flutter/material.dart';
import 'package:family_organizer/models/meal.dart'; // Import the Meal model

class MealService extends ChangeNotifier {
  final List<Meal> _meals = [];

  List<Meal> get meals => _meals;

  void addMeal(Meal meal) {
    _meals.add(meal);
    notifyListeners();
  }

  void removeMeal(String id) {
    _meals.removeWhere((meal) => meal.id == id);
    notifyListeners();
  }

  // TODO: Add methods for updating meals, filtering by date, etc.
}
