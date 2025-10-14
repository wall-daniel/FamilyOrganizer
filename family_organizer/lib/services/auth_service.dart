import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:family_organizer/common/api_config.dart';

class AuthService {
  final String _baseUrl = ApiConfig.baseUrl; // Use central API config
  final _storage = new FlutterSecureStorage();

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

  Future<String?> register(String familyName, String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'family_name': familyName,
        'username': username,
        'password': password,
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
}
