import 'package:http/browser_client.dart';
import 'dart:convert';

class UserService {
  static const baseUrl = "http://localhost:3000/api";
  
  static final _client = BrowserClient()..withCredentials = true;

  static Future<Map<String, dynamic>> getUserData() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/user/data'),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to load user data');
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> addFavoriteCity(String cityId) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/user/favorites/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'cityId': cityId}),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error adding favorite: $e');
      rethrow;
    }
  }

  static Future<void> removeFavoriteCity(String cityId) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/user/favorites/remove/$cityId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  static Future<void> addWishlistCity(String cityId) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/user/wishlist/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'cityId': cityId}),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error adding to wishlist: $e');
      rethrow;
    }
  }
  static Future<void> removeWishlistCity(String cityId) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/user/wishlist/remove/$cityId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteCity(String cityId) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/user/deleted-cities/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'cityId': cityId}),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> restoreCity(String cityId) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/user/deleted-cities/remove/$cityId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

}