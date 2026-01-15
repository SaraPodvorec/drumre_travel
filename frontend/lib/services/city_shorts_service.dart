import 'package:frontend/models/city_short_videos.dart';
import 'package:frontend/services/api_service.dart';

class CityShortsService {
  Future<List<CityShortVideos>> fetchTopShortVideos(String cityId) async {
    final res = await Api.getRequest('/cityShorts?cityId=$cityId');
    final List<dynamic> topShorts = res;
    return topShorts.map((json) => CityShortVideos.fromJson(json)).toList();
  }
}