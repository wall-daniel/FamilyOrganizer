import 'dart:convert';
import 'package:family_organizer/common/api_config.dart';
import 'package:family_organizer/models/user.dart';
import 'package:family_organizer/common/http_client.dart';

class UserService {
  final String _baseUrl = ApiConfig.baseUrl;
  final HttpClient _httpClient = HttpClient();

  Future<List<User>> getFamilyUsers(String token) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/family/users'),
    );

    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<User>.from(l.map((model) => User.fromJson(model)));
    } else {
      throw Exception('Failed to load family users: ${response.body}');
    }
  }

  Future<void> acceptUser(int userId) async {
    final response = await _httpClient.put(
      Uri.parse('$_baseUrl/family/users/$userId/accept'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to accept user: ${response.body}');
    }
  }
}
