import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:family_organizer/models/grocery_item.dart';
import 'package:family_organizer/common/api_config.dart'; // Import ApiConfig
import 'package:family_organizer/services/auth_service.dart';

class GroceryService extends ChangeNotifier {
  final String _baseUrl = ApiConfig.baseUrl; // Use central API config
  final List<GroceryItem> _groceryItems = [];
  final AuthService _authService = AuthService();

  List<GroceryItem> get groceryItems => _groceryItems;

  Future<Map<String, String>> _getHeaders() async {
    String? token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'x-access-token': token ?? '',
    };
  }

  Future<void> fetchGroceryItems() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/grocery_items'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        Iterable l = json.decode(response.body);
        _groceryItems.clear();
        _groceryItems.addAll(List<GroceryItem>.from(l.map((model) => GroceryItem.fromJson(model))));
        notifyListeners();
      } else {
        throw Exception('Failed to load grocery items');
      }
    } catch (e) {
      print('Error fetching grocery items: $e');
      // Handle error, e.g., show a snackbar
    }
  }

  Future<void> addGroceryItem(GroceryItem item) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/grocery_items'),
        headers: await _getHeaders(),
        body: json.encode(item.toJson()),
      );
      if (response.statusCode == 201) {
        final newItem = GroceryItem.fromJson(json.decode(response.body));
        _groceryItems.add(newItem);
        notifyListeners();
      } else {
        throw Exception('Failed to add grocery item');
      }
    } catch (e) {
      print('Error adding grocery item: $e');
    }
  }

  Future<void> toggleItemCompletion(int id) async {
    final index = _groceryItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      GroceryItem itemToUpdate = _groceryItems[index];
      itemToUpdate.isCompleted = !itemToUpdate.isCompleted;

      try {
        final response = await http.put(
          Uri.parse('$_baseUrl/grocery_items/$id'),
          headers: await _getHeaders(),
          body: json.encode(itemToUpdate.toJson()),
        );
        if (response.statusCode == 200) {
          notifyListeners();
        } else {
          // Revert local change if API call fails
          itemToUpdate.isCompleted = !itemToUpdate.isCompleted;
          throw Exception('Failed to update grocery item completion');
        }
      } catch (e) {
        print('Error toggling grocery item completion: $e');
        // Revert local change if API call fails
        itemToUpdate.isCompleted = !itemToUpdate.isCompleted;
      }
    }
  }

  Future<void> removeGroceryItem(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/grocery_items/$id'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        _groceryItems.removeWhere((item) => item.id == id);
        notifyListeners();
      } else {
        throw Exception('Failed to delete grocery item');
      }
    } catch (e) {
      print('Error removing grocery item: $e');
    }
  }

  // TODO: Add methods for editing items, filtering, etc.
}
