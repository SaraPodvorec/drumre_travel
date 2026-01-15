import 'package:frontend/models/topsight.dart';
import 'package:frontend/services/api_service.dart';

class SightsService {
  Future<List<CityTopSight>> fetchTopSights(String cityId) async {
    final res = await Api.getRequest('/topSights?cityId=$cityId');
    final List<dynamic> topSights = res;
    return topSights.map((json) => CityTopSight.fromJson(json)).toList();
  }
}
