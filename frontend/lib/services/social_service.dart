import 'dart:convert';
import 'package:http/browser_client.dart';

class SocialService {
  static const baseUrl = "http://localhost:3000/api";
  static final _client = BrowserClient()..withCredentials = true;

  static Future<Map<String, dynamic>> fetchAllUsers() async {
    final res = await _client.get(
      Uri.parse('$baseUrl/user/all'),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load users');
    }

    return jsonDecode(res.body);
  }

  static Future<void> follow(String userId) async {
    final res = await _client.post(
      Uri.parse('$baseUrl/user/follow/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to follow');
    }
  }

  static Future<void> unfollow(String userId) async {
    final res = await _client.delete(
      Uri.parse('$baseUrl/user/follow/remove/$userId'),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to unfollow');
    }
  }
}
