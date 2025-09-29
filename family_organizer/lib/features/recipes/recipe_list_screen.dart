import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:family_organizer/services/recipe_service.dart';
import 'package:family_organizer/models/recipe.dart';
import 'package:family_organizer/features/recipes/add_recipe_screen.dart';

class RecipeListScreen extends StatelessWidget {
  const RecipeListScreen({super.key});

  static const String routeName = '/recipes';

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
                  subtitle: Text(recipe.description),
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
                                      child: Text('• $ingredient'),
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
                            children: List.generate(recipe.instructions.length, (index) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                                child: Text('${index + 1}. ${recipe.instructions[index]}'),
                              );
                            }),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                recipeService.removeRecipe(recipe.id);
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
