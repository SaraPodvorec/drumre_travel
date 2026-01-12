import 'dart:convert';
import 'package:frontend/models/social_user.dart';
import 'package:http/browser_client.dart';

class SocialService {
  static const baseUrl = "http://localhost:3000/api";
  static final _client = BrowserClient()..withCredentials = true;

  /// Fetch all users and the current user's following IDs
  static Future<Map<String, dynamic>> fetchAllUsers() async {
    final res = await _client.get(Uri.parse('$baseUrl/user/all'));

    if (res.statusCode != 200) throw Exception('Failed to load users');

    return jsonDecode(res.body);
  }

  static Future<void> follow(String userId) async {
    final res = await _client.post(
      Uri.parse('$baseUrl/user/follow/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );

    if (res.statusCode != 200) throw Exception('Failed to follow');
  }

  static Future<void> unfollow(String userId) async {
    final res = await _client.delete(
      Uri.parse('$baseUrl/user/follow/remove/$userId'),
    );

    if (res.statusCode != 200) throw Exception('Failed to unfollow');
  }

  static Future<SocialUser> getUserProfile(String userId, Set<String> followingIds) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/user/$userId/profile'),
    );

    if (response.statusCode != 200) throw Exception('Failed to fetch user profile');

    final data = jsonDecode(response.body);
    return SocialUser.fromJson(data, followingIds);
  }
}
