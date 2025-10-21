import 'package:http/http.dart' as http;
import 'package:family_organizer/services/auth_service.dart';

class HttpClient {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    String? token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  Future<http.Response> get(Uri url) async {
    return http.get(url, headers: await _getHeaders());
  }

  Future<http.Response> post(Uri url, {Object? body}) async {
    return http.post(url, headers: await _getHeaders(), body: body);
  }

  Future<http.Response> put(Uri url, {Object? body}) async {
    return http.put(url, headers: await _getHeaders(), body: body);
  }

  Future<http.Response> delete(Uri url) async {
    return http.delete(url, headers: await _getHeaders());
  }
}
