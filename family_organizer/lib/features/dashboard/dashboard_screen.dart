import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:family_organizer/services/auth_service.dart';
import 'package:family_organizer/models/user.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static const String routeName = '/';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<User?> _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    _currentUser = Provider.of<AuthService>(context, listen: false).getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthService>(context, listen: false).logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
      body: FutureBuilder<User?>(
        future: _currentUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading user data: ${snapshot.error}'));
          }

          final User? currentUser = snapshot.data;
          final bool isAccepted = currentUser?.isAccepted ?? false;

          return Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 600 ? 3 : 1;
                  double childAspectRatio = constraints.maxWidth > 600 ? 1.0 : 3.0;

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
                      final bool isFamilyUsersCard = item['route'] == '/family-users';
                      final bool canNavigate = isAccepted || isFamilyUsersCard;

                      return FeatureCard(
                        title: item['title']!,
                        icon: item['icon'] as IconData,
                        onTap: canNavigate
                            ? () {
                                Navigator.pushNamed(context, item['route'] as String);
                              }
                            : null, // Disable onTap if not accepted and not Family Users card
                        isDisabled: !canNavigate, // Pass disabled state to card
                      );
                    },
                  );
                },
              ),
              if (!isAccepted)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock, color: Colors.white, size: 60),
                            const SizedBox(height: 20),
                            Text(
                              'Your account is pending acceptance by a family member. You can view family users but cannot access other features yet.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/family-users');
                              },
                              child: const Text('View Family Users'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
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
    this.isDisabled = false,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onTap; // Make onTap nullable
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: isDisabled ? Colors.grey.shade300 : null, // Grey out if disabled
      child: InkWell(
        onTap: isDisabled ? null : onTap, // Disable InkWell if card is disabled
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48.0,
                color: isDisabled ? Colors.grey.shade500 : Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16.0),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isDisabled ? Colors.grey.shade600 : null,
                    ),
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
