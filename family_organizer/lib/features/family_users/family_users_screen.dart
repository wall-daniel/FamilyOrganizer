import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:family_organizer/models/user.dart';
import 'package:family_organizer/services/user_service.dart';
import 'package:family_organizer/services/auth_service.dart';

class FamilyUsersScreen extends StatefulWidget {
  static const String routeName = '/family-users';
  const FamilyUsersScreen({super.key});

  @override
  State<FamilyUsersScreen> createState() => _FamilyUsersScreenState();
}

class _FamilyUsersScreenState extends State<FamilyUsersScreen> {
  late Future<List<User>> _familyUsers;
  late Future<User?> _currentUser;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _familyUsers = _userService.getFamilyUsers();
      _currentUser = Provider.of<AuthService>(context, listen: false).getCurrentUser();
    });
  }

  Future<void> _acceptUser(String userId) async {
    try {
      await _userService.acceptUser(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User accepted successfully!')),
      );
      _loadData(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept user: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Users'),
      ),
      body: FutureBuilder<User?>(
        future: _currentUser,
        builder: (context, currentUserSnapshot) {
          if (currentUserSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (currentUserSnapshot.hasError) {
            return Center(child: Text('Error loading current user: ${currentUserSnapshot.error}'));
          }

          final User? currentUser = currentUserSnapshot.data;
          final bool canAcceptUsers = currentUser?.isAccepted ?? false;

          return FutureBuilder<List<User>>(
            future: _familyUsers,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No family users found.'));
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    User user = snapshot.data![index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(user.username),
                        subtitle: Text('${user.email} - ${user.isAccepted ? "Accepted" : "Pending"}'),
                        trailing: canAcceptUsers && !user.isAccepted
                            ? ElevatedButton(
                                onPressed: () => _acceptUser(user.id),
                                child: const Text('Accept'),
                              )
                            : null,
                      ),
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
