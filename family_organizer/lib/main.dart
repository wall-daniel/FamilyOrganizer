import 'package:flutter/material.dart';
import 'package:family_organizer/features/dashboard/dashboard_screen.dart';
import 'package:family_organizer/features/tasks/tasks_screen.dart';
import 'package:family_organizer/features/meal_planning/meal_planning_screen.dart';
import 'package:family_organizer/features/grocery_list/grocery_list_screen.dart';
import 'package:family_organizer/features/recipes/recipe_list_screen.dart';
import 'package:family_organizer/features/recipes/add_recipe_screen.dart';
import 'package:family_organizer/services/task_service.dart';
import 'package:provider/provider.dart';
import 'package:family_organizer/services/meal_service.dart';
import 'package:family_organizer/services/grocery_service.dart';
import 'package:family_organizer/services/recipe_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TaskService()),
        ChangeNotifierProvider(create: (context) => MealService()),
        ChangeNotifierProvider(create: (context) => GroceryService()),
        ChangeNotifierProvider(create: (context) => RecipeService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Organizer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: DashboardScreen.routeName,
      routes: {
        DashboardScreen.routeName: (context) => const DashboardScreen(),
        TasksScreen.routeName: (context) => const TasksScreen(),
        MealPlanningScreen.routeName: (context) => const MealPlanningScreen(),
        GroceryListScreen.routeName: (context) => const GroceryListScreen(),
        RecipeListScreen.routeName: (context) => const RecipeListScreen(),
        AddRecipeScreen.routeName: (context) => const AddRecipeScreen(),
      },
    );
  }
}
