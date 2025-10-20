import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:family_organizer/common/api_config.dart';
import 'package:family_organizer/models/user.dart';

class UserService {
  final String _baseUrl = ApiConfig.baseUrl;
  final _storage = FlutterSecureStorage(); // Re-add _storage for acceptUser
  Future<List<User>> getFamilyUsers(String token) async {
    // No need to read from storage again, token is passed directly
    // if (token == null) { // This check is now handled by the caller
    //   throw Exception('Authentication token not found.');
    // }

    final response = await http.get(
      Uri.parse('$_baseUrl/family/users'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<User>.from(l.map((model) => User.fromJson(model)));
    } else {
      throw Exception('Failed to load family users: ${response.body}');
    }
  }

  Future<void> acceptUser(int userId) async { // Changed to int
    String? token = await _storage.read(key: 'token');

    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    final response = await http.put(
      Uri.parse('$_baseUrl/family/users/$userId/accept'), // userId is now int, will be interpolated
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to accept user: ${response.body}');
    }
  }
}
