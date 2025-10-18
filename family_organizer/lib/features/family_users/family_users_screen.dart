import 'package:flutter/material.dart';
import 'package:family_organizer/models/user.dart';
import 'package:family_organizer/services/user_service.dart';

class FamilyUsersScreen extends StatefulWidget {
  static const String routeName = '/family-users';
  const FamilyUsersScreen({super.key});

  @override
  State<FamilyUsersScreen> createState() => _FamilyUsersScreenState();
}

class _FamilyUsersScreenState extends State<FamilyUsersScreen> {
  late Future<List<User>> _familyUsers;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _familyUsers = _userService.getFamilyUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Users'),
      ),
      body: FutureBuilder<List<User>>(
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
                    subtitle: Text(user.email),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
