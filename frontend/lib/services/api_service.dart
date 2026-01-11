import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';

class Api {
  static const baseUrl = "http://localhost:3000/api";

  static Future<dynamic> getRequest(String endpoint) async {
    try {
      final res = await http.get(Uri.parse("$baseUrl$endpoint"));
      if (res.statusCode != 200) {
        throw Exception('Failed to load data: ${res.statusCode}');
      }
      final data = json.decode(res.body);
      return data;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<dynamic> postRequest(String endpoint, Map data) async {
    final client = http.Client();
    if (client is BrowserClient) {
      client.withCredentials = true;
    }
    try {
      final res = await client.post(
        Uri.parse("$baseUrl$endpoint"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception('Failed to post data: ${res.statusCode}');
      }
      final responseData = json.decode(res.body);
      return responseData;
    } catch (e) {
      throw Exception('Network error: $e');
    } finally {
      client.close();
    }
  }

  static Future<dynamic> deleteRequest(String endpoint) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl$endpoint"));
      if (res.statusCode != 200 && res.statusCode != 204) {
        throw Exception('Failed to delete data: ${res.statusCode}');
      }
      final data = json.decode(res.body);
      return data;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // proxy image URL through backend to avoid CORS issues
  static String getProxyImageUrl(String imageUrl) {
    return "$baseUrl/proxy-image?url=${Uri.encodeComponent(imageUrl)}";
  }
}