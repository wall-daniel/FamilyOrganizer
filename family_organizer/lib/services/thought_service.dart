import 'dart:convert';
import 'package:family_organizer/common/api_config.dart';
import 'package:family_organizer/models/thought.dart';
import 'package:family_organizer/common/http_client.dart';

class ThoughtService {
  final String _baseUrl = ApiConfig.baseUrl;
  final HttpClient _httpClient = HttpClient();

  Future<Thought> postThought(String content, String token) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/thoughts'),
      body: json.encode({'content': content}),
    );

    if (response.statusCode == 201) {
      return Thought.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to post thought: ${response.body}');
    }
  }

  Future<List<Thought>> fetchThoughts(String token, {int page = 1, int limit = 10}) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/thoughts?page=$page&limit=$limit'),
    );

    if (response.statusCode == 200) {
      List<dynamic> thoughtsJson = json.decode(response.body);
      return thoughtsJson.map((json) => Thought.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load thoughts: ${response.body}');
    }
  }
}
