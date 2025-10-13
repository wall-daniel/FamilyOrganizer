import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:family_organizer/models/recipe.dart';
import 'package:family_organizer/common/api_config.dart'; // Import ApiConfig
import 'package:family_organizer/services/auth_service.dart';

class RecipeService extends ChangeNotifier {
  final String _baseUrl = ApiConfig.baseUrl; // Use central API config
  final List<Recipe> _recipes = [];
  final AuthService _authService = AuthService();

  List<Recipe> get recipes => _recipes;

  Future<Map<String, String>> _getHeaders() async {
    String? token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'x-access-token': token ?? '',
    };
  }

  Future<void> fetchRecipes() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/recipes'),
        headers: await _getHeaders(),
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
      // Handle error
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/recipes'),
        headers: await _getHeaders(),
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
      final response = await http.put(
        Uri.parse('$_baseUrl/recipes/${recipe.id}'),
        headers: await _getHeaders(),
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
      final response = await http.delete(
        Uri.parse('$_baseUrl/recipes/$id'),
        headers: await _getHeaders(),
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

  // TODO: Add methods for updating recipes, filtering, etc.
}
