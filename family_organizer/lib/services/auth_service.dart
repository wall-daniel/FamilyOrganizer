import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:family_organizer/common/api_config.dart';
import 'package:family_organizer/models/user.dart';
import 'package:family_organizer/services/user_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final String _baseUrl = ApiConfig.baseUrl; // Use central API config
  final _storage = FlutterSecureStorage();

  Future<String?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      String token = jsonDecode(response.body)['token'];
      await _storage.write(key: 'token', value: token);
      return null; // Success, no error message
    } else {
      final errorData = jsonDecode(response.body);
      return errorData['message'] ?? 'An unknown error occurred during login.';
    }
  }

  Future<String?> register(String familyName, String username, String password, String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'family_name': familyName,
        'username': username,
        'password': password,
        'email': email,
      }),
    );

    if (response.statusCode == 201) {
      return null; // Success, no error message
    } else {
      final errorData = jsonDecode(response.body);
      return errorData['message'] ?? 'An unknown error occurred during registration.';
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<bool> isAuthenticated() async {
    String? token = await getToken();
    return token != null;
  }

  Future<User?> getCurrentUser() async {
    String? token = await getToken();
    if (token == null) {
      return null;
    }

    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String userId = decodedToken['id'].toString(); // Assuming 'id' is in the token

      // Fetch full user details using UserService
      final userService = UserService(); // Create an instance of UserService
      List<User> familyUsers = await userService.getFamilyUsers();
      return familyUsers.firstWhere((user) => user.id == userId);
    } catch (e) {
      print('Error decoding token or fetching user: $e');
      return null;
    }
  }
}
