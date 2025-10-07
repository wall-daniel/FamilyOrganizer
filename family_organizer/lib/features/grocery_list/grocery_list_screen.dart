import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:family_organizer/services/grocery_service.dart';
import 'package:family_organizer/models/grocery_item.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  static const String routeName = '/grocery-list';

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GroceryService>(context, listen: false).fetchGroceryItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery List'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Consumer<GroceryService>(
        builder: (context, groceryService, child) {
          if (groceryService.groceryItems.isEmpty) {
            return const Center(
              child: Text('No grocery items yet! Add one using the + button.'),
            );
          }
          return ListView.builder(
            itemCount: groceryService.groceryItems.length,
            itemBuilder: (context, index) {
              final item = groceryService.groceryItems[index];
              return ListTile(
                title: Text(
                  item.name,
                  style: TextStyle(
                    decoration: item.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                leading: Checkbox(
                  value: item.isCompleted,
                  onChanged: (bool? value) {
                    if (item.id != null) {
                      groceryService.toggleItemCompletion(item.id!);
                    }
                  },
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    if (item.id != null) {
                      groceryService.removeGroceryItem(item.id!);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Consumer<GroceryService>(
        builder: (context, groceryService, child) {
          return FloatingActionButton(
            onPressed: () {
              _showAddGroceryItemDialog(context, groceryService);
            },
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}

void _showAddGroceryItemDialog(
    BuildContext context, GroceryService groceryService) {
  final TextEditingController nameController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add New Grocery Item'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Item Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final newItem = GroceryItem(
                  name: nameController.text,
                  quantity: '', // Default quantity
                  isCompleted: false,
                );
                groceryService.addGroceryItem(newItem);
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}
