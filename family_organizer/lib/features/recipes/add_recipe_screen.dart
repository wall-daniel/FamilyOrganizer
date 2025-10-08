import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:family_organizer/services/recipe_service.dart';
import 'package:family_organizer/models/recipe.dart';
import 'package:family_organizer/models/ingredient.dart' as model;

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  static const String routeName = '/add-recipe';

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  List<model.Ingredient> _ingredients = [model.Ingredient(name: '')];
  List<TextEditingController> _instructionControllers = [TextEditingController()];

  @override
  void dispose() {
    _nameController.dispose();
    for (var ing in _ingredients) {
      // No controllers to dispose
    }
    for (var c in _instructionControllers) { c.dispose(); }
    super.dispose();
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      final newRecipe = Recipe(
        name: _nameController.text,
        ingredients: _ingredients
            .where((ing) => ing.name.trim().isNotEmpty)
            .map((ing) => model.Ingredient(name: ing.name.trim(), quantity: ing.quantity?.trim()))
            .toList(),
        instructions: _instructionControllers.map((c) => c.text.trim()).where((e) => e.isNotEmpty).toList(),
      );
      Provider.of<RecipeService>(context, listen: false).addRecipe(newRecipe);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Recipe'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Recipe Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a recipe name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text('Ingredients:', style: Theme.of(context).textTheme.titleMedium),
              ..._ingredients.asMap().entries.map((entry) {
                final i = entry.key;
                final ing = entry.value;
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: ing.name,
                        decoration: InputDecoration(
                          labelText: 'Ingredient ${i + 1}',
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _ingredients[i] = model.Ingredient(name: val, quantity: ing.quantity);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue: ing.quantity,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _ingredients[i] = model.Ingredient(name: ing.name, quantity: val);
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: _ingredients.length > 1
                          ? () {
                              setState(() {
                                _ingredients.removeAt(i);
                              });
                            }
                          : null,
                    ),
                  ],
                );
              }),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Ingredient'),
                onPressed: () {
                  setState(() {
                    _ingredients.add(model.Ingredient(name: ''));
                  });
                },
              ),
              const SizedBox(height: 16),
              Text('Instructions:', style: Theme.of(context).textTheme.titleMedium),
              ..._instructionControllers.asMap().entries.map((entry) {
                final i = entry.key;
                final c = entry.value;
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: c,
                        decoration: InputDecoration(
                          labelText: 'Step ${i + 1}',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: _instructionControllers.length > 1
                          ? () {
                              setState(() {
                                _instructionControllers.removeAt(i);
                              });
                            }
                          : null,
                    ),
                  ],
                );
              }),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Step'),
                onPressed: () {
                  setState(() {
                    _instructionControllers.add(TextEditingController());
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveRecipe,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Save Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
