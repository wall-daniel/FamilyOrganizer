import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const String routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary, // Ensures text/icons are visible on colored background
        title: Row(
          children: [
            const Icon(Icons.family_restroom, size: 30),
            const SizedBox(width: 10),
            Text(
              'Family Organizer',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine the number of columns based on screen width
          int crossAxisCount = constraints.maxWidth > 600 ? 3 : 1;
          double childAspectRatio = constraints.maxWidth > 600 ? 1.0 : 3.0; // Wider cards on mobile

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: _featureItems.length,
            itemBuilder: (context, index) {
              final item = _featureItems[index];
              return FeatureCard(
                title: item['title']!,
                icon: item['icon'] as IconData,
                onTap: () {
                  // TODO: Implement navigation to respective feature screens
                  Navigator.pushNamed(context, item['route'] as String);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  const FeatureCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48.0, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16.0),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final List<Map<String, dynamic>> _featureItems = [
  {
    'title': 'Tasks',
    'icon': Icons.check_box,
    'route': '/tasks',
  },
  {
    'title': 'Meal Planning',
    'icon': Icons.restaurant_menu,
    'route': '/meal-planning',
  },
  {
    'title': 'Grocery List',
    'icon': Icons.shopping_cart,
    'route': '/grocery-list',
  },
  {
    'title': 'Recipes',
    'icon': Icons.menu_book,
    'route': '/recipes',
  },
  {
    'title': 'Family Users',
    'icon': Icons.group,
    'route': '/family-users',
  },
];
