import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:family_organizer/services/recipe_service.dart';
import 'package:family_organizer/models/recipe.dart';
import 'package:family_organizer/features/recipes/add_recipe_screen.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  static const String routeName = '/recipes';

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecipeService>(context, listen: false).fetchRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Consumer<RecipeService>(
        builder: (context, recipeService, child) {
          if (recipeService.recipes.isEmpty) {
            return const Center(
              child: Text('No recipes yet! Add one using the + button.'),
            );
          }
          return ListView.builder(
            itemCount: recipeService.recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipeService.recipes[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 2.0,
                child: ExpansionTile(
                  title: Text(
                    recipe.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ingredients:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: recipe.ingredients
                                .map((ingredient) => Padding(
                                      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                                      child: Text(
                                        '• ${ingredient.name}${ingredient.quantity != null && ingredient.quantity!.isNotEmpty ? ' (${ingredient.quantity})' : ''}',
                                      ),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Instructions:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: recipe.instructions
                                .map((step) => Padding(
                                      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                                      child: Text('• $step'),
                                    ))
                                .toList(),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                if (recipe.id != null) { // Ensure id is not null
                                  recipeService.removeRecipe(recipe.id!);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AddRecipeScreen.routeName);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
