import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:family_organizer/models/recipe.dart';
import 'package:family_organizer/common/api_config.dart';
import 'package:family_organizer/common/http_client.dart';

class RecipeService extends ChangeNotifier {
  final String _baseUrl = ApiConfig.baseUrl;
  final List<Recipe> _recipes = [];
  final HttpClient _httpClient = HttpClient();

  List<Recipe> get recipes => _recipes;

  Future<void> fetchRecipes() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/recipes'),
      );
      if (response.statusCode == 200) {
        Iterable l = json.decode(response.body);
        _recipes.clear();
        _recipes.addAll(List<Recipe>.from(l.map((model) => Recipe.fromJson(model))));
        notifyListeners();
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      print('Error fetching recipes: $e');
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/recipes'),
        body: json.encode(recipe.toJson()),
      );
      if (response.statusCode == 201) {
        final newRecipe = Recipe.fromJson(json.decode(response.body));
        _recipes.add(newRecipe);
        notifyListeners();
      } else {
        throw Exception('Failed to add recipe');
      }
    } catch (e) {
      print('Error adding recipe: $e');
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    if (recipe.id == null) {
      print('Error: Cannot update recipe without an ID.');
      return;
    }
    try {
      final response = await _httpClient.put(
        Uri.parse('$_baseUrl/recipes/${recipe.id}'),
        body: json.encode(recipe.toJson()),
      );
      if (response.statusCode == 200) {
        final index = _recipes.indexWhere((r) => r.id == recipe.id);
        if (index != -1) {
          _recipes[index] = recipe;
          notifyListeners();
        }
      } else {
        throw Exception('Failed to update recipe');
      }
    } catch (e) {
      print('Error updating recipe: $e');
    }
  }

  Future<void> removeRecipe(int id) async {
    try {
      final response = await _httpClient.delete(
        Uri.parse('$_baseUrl/recipes/$id'),
      );
      if (response.statusCode == 200) {
        _recipes.removeWhere((recipe) => recipe.id == id);
        notifyListeners();
      } else {
        throw Exception('Failed to delete recipe');
      }
    } catch (e) {
      print('Error removing recipe: $e');
    }
  }
}
