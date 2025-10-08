import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:family_organizer/services/meal_service.dart';
import 'package:family_organizer/models/meal.dart';
import 'package:family_organizer/services/recipe_service.dart'; // Import RecipeService
import 'package:family_organizer/models/recipe.dart'; // Import Recipe model

class MealPlanningScreen extends StatefulWidget {
  const MealPlanningScreen({super.key});

  static const String routeName = '/meal-planning';

  @override
  State<MealPlanningScreen> createState() => _MealPlanningScreenState();
}

class _MealPlanningScreenState extends State<MealPlanningScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MealService>(context, listen: false).fetchMeals();
    });
  }

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
                  .where((meal) {
                    final mealDate = DateTime.tryParse(meal.date ?? '');
                    return mealDate != null &&
                           mealDate.year == day.year &&
                           mealDate.month == day.month &&
                           mealDate.day == day.day;
                  })
                  .toList();

              return MealDayCard(
                day: day,
                meals: mealsForDay,
                onAddMeal: (date) {
                  _showAddMealDialog(context, mealService, date);
                },
                onDeleteMeal: (meal) {
                  mealService.deleteMeal(meal);
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
    Recipe? selectedRecipe;
    String? selectedMealTime;
    final List<String> mealTimes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

    showDialog(
      context: context,
      builder: (context) {
        final recipeService = Provider.of<RecipeService>(context, listen: false);
        final List<Recipe> availableRecipes = recipeService.recipes;

        return StatefulBuilder(
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
                            } else {
                              nameController.clear();
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
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Meal Time'),
                      value: selectedMealTime,
                      items: mealTimes.map((time) {
                        return DropdownMenuItem<String>(
                          value: time,
                          child: Text(time),
                        );
                      }).toList(),
                      onChanged: (String? time) {
                        setState(() {
                          selectedMealTime = time;
                        });
                      },
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
                    if (nameController.text.isNotEmpty && selectedMealTime != null) {
                      final newMeal = Meal(
                        name: nameController.text,
                        date: scheduledDate.toIso8601String().split('T').first,
                        recipeId: selectedRecipe?.id,
                        mealTime: selectedMealTime,
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
    required this.onDeleteMeal,
  });

  final DateTime day;
  final List<Meal> meals;
  final Function(DateTime) onAddMeal;
  final Function(Meal) onDeleteMeal;

  Widget _mealTimeChip(String? mealTime) {
    final Map<String, Color> colors = {
      'Breakfast': Colors.orange.shade200,
      'Lunch': Colors.lightGreen.shade200,
      'Dinner': Colors.blue.shade200,
      'Snack': Colors.purple.shade200,
    };
    final Map<String, IconData> icons = {
      'Breakfast': Icons.wb_sunny,
      'Lunch': Icons.lunch_dining,
      'Dinner': Icons.nightlight_round,
      'Snack': Icons.fastfood,
    };
    final color = colors[mealTime] ?? Colors.grey.shade300;
    final icon = icons[mealTime] ?? Icons.help_outline;
    return Chip(
        label: SizedBox(
          width: 64,
          child: Text(
            mealTime ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 14),
          ),
        ),
        avatar: Icon(icon, size: 18, color: Colors.black54),
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sort meals by mealTime
    final sortedMeals = List<Meal>.from(meals)
      ..sort((a, b) {
        final order = {
          'Breakfast': 0,
          'Lunch': 1,
          'Dinner': 2,
          'Snack': 3,
        };
        return (order[a.mealTime ?? ''] ?? 99).compareTo(order[b.mealTime ?? ''] ?? 99);
      });
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
              ...sortedMeals.map((meal) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _mealTimeChip(meal.mealTime),
                            const SizedBox(width: 8),
                            Text(
                              meal.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Delete meal',
                          onPressed: () => onDeleteMeal(meal),
                        ),
                      ],
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
