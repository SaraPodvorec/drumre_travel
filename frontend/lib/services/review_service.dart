import 'api_service.dart';

class ReviewService {
  static Future<Map<String, dynamic>> submitReview({
    required String cityName,
    required int impression,
    required int people,
    required int sights,
    required int safety,
    required int affordability,
    String? comments,
  }) async {
    final data = {
      'cityName': cityName,
      'impression': impression,
      'people': people,
      'sights': sights,
      'safety': safety,
      'affordability': affordability,
      'comments': comments ?? '',
    };

    return await Api.postRequest('/review', data);
  }

  static Future<List<dynamic>> getReviewsByCity(String cityId) async {
    final data = {'cityId': cityId};
    final response = await Api.postRequest('/review/city', data);
    return response as List<dynamic>;
  }

  static Future<List<dynamic>> getReviewsByUser(String userId) async {
    final data = {'userId': userId};
    final response = await Api.postRequest('/review/user', data);
    return response as List<dynamic>;
  }

  static Future<Map<String, dynamic>> deleteReview(String reviewId) async {
    return await Api.deleteRequest('/review/$reviewId');
  }
}