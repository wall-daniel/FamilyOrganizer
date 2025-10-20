import 'package:flutter/material.dart';
import 'package:family_organizer/features/dashboard/dashboard_screen.dart';
import 'package:family_organizer/features/tasks/tasks_screen.dart';
import 'package:family_organizer/features/meal_planning/meal_planning_screen.dart';
import 'package:family_organizer/features/grocery_list/grocery_list_screen.dart';
import 'package:family_organizer/features/recipes/recipe_list_screen.dart';
import 'package:family_organizer/features/recipes/add_recipe_screen.dart';
import 'package:family_organizer/features/auth/login_screen.dart';
import 'package:family_organizer/features/auth/register_screen.dart';
import 'package:family_organizer/features/family_users/family_users_screen.dart';
import 'package:family_organizer/features/thoughts/thoughts_screen.dart'; // Import the new thoughts screen
import 'package:family_organizer/services/task_service.dart';
import 'package:provider/provider.dart';
import 'package:family_organizer/services/meal_service.dart';
import 'package:family_organizer/services/thought_service.dart'; // Import the new thought service
import 'package:family_organizer/services/grocery_service.dart';
import 'package:family_organizer/services/recipe_service.dart';
import 'package:family_organizer/services/auth_service.dart';
import 'package:family_organizer/services/user_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TaskService()),
        ChangeNotifierProvider(create: (context) => MealService()),
        ChangeNotifierProvider(create: (context) => GroceryService()),
        ChangeNotifierProvider(create: (context) => RecipeService()),
        Provider(create: (context) => AuthService()),
        Provider(create: (context) => UserService()),
        Provider(create: (context) => ThoughtService()), // Register ThoughtService
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
      home: AuthWrapper(),
      routes: {
        TasksScreen.routeName: (context) => const TasksScreen(),
        MealPlanningScreen.routeName: (context) => const MealPlanningScreen(),
        GroceryListScreen.routeName: (context) => const GroceryListScreen(),
        RecipeListScreen.routeName: (context) => const RecipeListScreen(),
        AddRecipeScreen.routeName: (context) => const AddRecipeScreen(),
        FamilyUsersScreen.routeName: (context) => const FamilyUsersScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/thoughts': (context) => const ThoughtsScreen(), // Add the new thoughts route
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return FutureBuilder<bool>(
      future: authService.isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          if (snapshot.data == true) {
            return const DashboardScreen();
          } else {
            return LoginScreen();
          }
        }
      },
    );
  }
}
