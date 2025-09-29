import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:family_organizer/services/meal_service.dart';
import 'package:family_organizer/models/meal.dart';
import 'package:family_organizer/services/recipe_service.dart'; // Import RecipeService
import 'package:family_organizer/models/recipe.dart'; // Import Recipe model

class MealPlanningScreen extends StatelessWidget {
  const MealPlanningScreen({super.key});

  static const String routeName = '/meal-planning';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Consumer<MealService>(
        builder: (context, mealService, child) {
          // Generate a list of the next 7 days
          final List<DateTime> next7Days = List.generate(7, (index) {
            return DateTime.now().add(Duration(days: index));
          });

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: next7Days.length,
            itemBuilder: (context, index) {
              final day = next7Days[index];
              final mealsForDay = mealService.meals
                  .where((meal) =>
                      meal.scheduledDate.year == day.year &&
                      meal.scheduledDate.month == day.month &&
                      meal.scheduledDate.day == day.day)
                  .toList();

              return MealDayCard(
                day: day,
                meals: mealsForDay,
                onAddMeal: (date) {
                  _showAddMealDialog(context, mealService, date);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showAddMealDialog(
      BuildContext context, MealService mealService, DateTime scheduledDate) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController ingredientsController = TextEditingController();

    Recipe? selectedRecipe; // To hold the selected recipe

    showDialog(
      context: context,
      builder: (context) {
        final recipeService = Provider.of<RecipeService>(context, listen: false);
        final List<Recipe> availableRecipes = recipeService.recipes;

        return StatefulBuilder( // Use StatefulBuilder to update dialog UI
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Meal'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (availableRecipes.isNotEmpty) ...[
                      DropdownButtonFormField<Recipe>(
                        decoration: const InputDecoration(labelText: 'Select Recipe (Optional)'),
                        value: selectedRecipe,
                        items: availableRecipes.map((recipe) {
                          return DropdownMenuItem<Recipe>(
                            value: recipe,
                            child: Text(recipe.name),
                          );
                        }).toList(),
                        onChanged: (Recipe? recipe) {
                          setState(() {
                            selectedRecipe = recipe;
                            if (selectedRecipe != null) {
                              nameController.text = selectedRecipe!.name;
                              descriptionController.text = selectedRecipe!.description;
                              ingredientsController.text = selectedRecipe!.ingredients.join(', ');
                            } else {
                              nameController.clear();
                              descriptionController.clear();
                              ingredientsController.clear();
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Meal Name'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    TextField(
                      controller: ingredientsController,
                      decoration: const InputDecoration(
                          labelText: 'Ingredients (comma-separated)'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      final newMeal = Meal(
                        id: DateTime.now().toIso8601String(),
                        name: nameController.text,
                        description: descriptionController.text,
                        ingredients: ingredientsController.text
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList(),
                        scheduledDate: scheduledDate,
                      );
                      mealService.addMeal(newMeal);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class MealDayCard extends StatelessWidget {
  const MealDayCard({
    super.key,
    required this.day,
    required this.meals,
    required this.onAddMeal,
  });

  final DateTime day;
  final List<Meal> meals;
  final Function(DateTime) onAddMeal;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_getDayName(day.weekday)}, ${day.day}/${day.month}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => onAddMeal(day),
                ),
              ],
            ),
            const Divider(),
            if (meals.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('No meals planned for this day.'),
              )
            else
              ...meals.map((meal) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      meal.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }
}
