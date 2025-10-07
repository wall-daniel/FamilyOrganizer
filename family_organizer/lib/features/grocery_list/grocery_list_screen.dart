import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:family_organizer/services/grocery_service.dart';
import 'package:family_organizer/models/grocery_item.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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
    final isWideScreen = MediaQuery.of(context).size.width > 700;
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
          // Group items by category
          final categories = <String>{};
          for (var item in groceryService.groceryItems) {
            categories.add(item.category);
          }
          final grouped = {
            for (var cat in categories)
              cat: groceryService.groceryItems.where((i) => i.category == cat).toList()
          };
          final allCards = grouped.entries.map((entry) {
            return Card(
              margin: const EdgeInsets.all(12),
              elevation: 3,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 400),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.key, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      ...entry.value.map((item) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        elevation: 1,
                        child: ListTile(
                          leading: Checkbox(
                            value: item.isCompleted,
                            onChanged: (bool? value) {
                              if (item.id != null) {
                                groceryService.toggleItemCompletion(item.id!);
                              }
                            },
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: TextStyle(
                                    decoration: item.isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    fontWeight: FontWeight.w600,
                                    color: item.isCompleted
                                        ? Colors.grey
                                        : Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              if (item.quantity.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item.quantity,
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red.shade400),
                            tooltip: 'Delete',
                            onPressed: () {
                              if (item.id != null) {
                                groceryService.removeGroceryItem(item.id!);
                              }
                            },
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            );
          }).toList();
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: isWideScreen
                  ? MasonryGridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => allCards[index],
                itemCount: allCards.length,
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: allCards,
              ),
            ),
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
  final TextEditingController quantityController = TextEditingController();
  String selectedCategory = 'Other';
  final List<String> categories = [
    'Meat', 'Produce', 'Dairy', 'Snacks', 'household', 'Other'
  ];

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add New Grocery Item'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                ),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity (Optional)'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: categories.map((cat) => DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => selectedCategory = value);
                  },
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
              ],
            );
          },
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
                  quantity: quantityController.text,
                  category: selectedCategory,
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
