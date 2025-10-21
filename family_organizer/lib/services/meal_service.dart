import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:family_organizer/models/meal.dart';
import 'package:family_organizer/common/api_config.dart';
import 'package:family_organizer/common/http_client.dart';

class MealService extends ChangeNotifier {
  final String _baseUrl = ApiConfig.baseUrl;
  final List<Meal> _meals = [];
  final HttpClient _httpClient = HttpClient();

  List<Meal> get meals => _meals;

  Future<void> fetchMeals() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/meals'),
      );
      if (response.statusCode == 200) {
        Iterable l = json.decode(response.body);
        _meals.clear();
        _meals.addAll(List<Meal>.from(l.map((model) => Meal.fromJson(model))));
        notifyListeners();
      } else {
        throw Exception('Failed to load meals');
      }
    } catch (e) {
      print('Error fetching meals: $e');
    }
  }

  Future<void> addMeal(Meal meal) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/meals'),
        body: json.encode(meal.toJson()),
      );
      if (response.statusCode == 201) {
        final newMeal = Meal.fromJson(json.decode(response.body));
        _meals.add(newMeal);
        notifyListeners();
      } else {
        throw Exception('Failed to add meal');
      }
    } catch (e) {
      print('Error adding meal: $e');
    }
  }

  Future<void> updateMeal(Meal meal) async {
    if (meal.id == null) {
      print('Error: Cannot update meal without an ID.');
      return;
    }
    try {
      final response = await _httpClient.put(
        Uri.parse('$_baseUrl/meals/${meal.id}'),
        body: json.encode(meal.toJson()),
      );
      if (response.statusCode == 200) {
        final index = _meals.indexWhere((m) => m.id == meal.id);
        if (index != -1) {
          _meals[index] = meal;
          notifyListeners();
        }
      } else {
        throw Exception('Failed to update meal');
      }
    } catch (e) {
      print('Error updating meal: $e');
    }
  }

  Future<void> removeMeal(int id) async {
    try {
      final response = await _httpClient.delete(
        Uri.parse('$_baseUrl/meals/$id'),
      );
      if (response.statusCode == 200) {
        _meals.removeWhere((meal) => meal.id == id);
        notifyListeners();
      } else {
        throw Exception('Failed to delete meal');
      }
    } catch (e) {
      print('Error removing meal: $e');
    }
  }

  Future<void> deleteMeal(Meal meal) async {
    if (meal.id == null) return;
    await removeMeal(meal.id!);
  }
}
