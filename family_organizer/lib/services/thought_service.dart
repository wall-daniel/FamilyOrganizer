import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:family_organizer/common/api_config.dart';
import 'package:family_organizer/models/thought.dart';
import 'package:family_organizer/models/user.dart'; // Assuming User model is needed for Thought

class ThoughtService {
  final String _baseUrl = ApiConfig.baseUrl;

  Future<Thought> postThought(String content, String token) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/thoughts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'content': content}),
    );

    if (response.statusCode == 201) {
      return Thought.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to post thought: ${response.body}');
    }
  }

  Future<List<Thought>> fetchThoughts(String token, {int page = 1, int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/thoughts?page=$page&limit=$limit'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> thoughtsJson = json.decode(response.body);
      return thoughtsJson.map((json) => Thought.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load thoughts: ${response.body}');
    }
  }
}
