import 'package:flutter/material.dart';
import 'package:family_organizer/models/grocery_item.dart'; // Import the GroceryItem model

class GroceryService extends ChangeNotifier {
  final List<GroceryItem> _groceryItems = [];

  List<GroceryItem> get groceryItems => _groceryItems;

  void addGroceryItem(GroceryItem item) {
    _groceryItems.add(item);
    notifyListeners();
  }

  void toggleItemCompletion(String id) {
    final index = _groceryItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      _groceryItems[index].isCompleted = !_groceryItems[index].isCompleted;
      notifyListeners();
    }
  }

  void removeGroceryItem(String id) {
    _groceryItems.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // TODO: Add methods for editing items, filtering, etc.
}
