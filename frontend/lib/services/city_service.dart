import '../models/city.dart';
import 'api_service.dart';

class CityService {

  Future<List<City>> fetchCities() async {
    final res = await Api.getRequest('/cities');
    final List<dynamic> cities = res;

    return cities.map((cityJson) => City.fromJson(cityJson)).toList();
  }

  Future<City> searchCity(String cityName) async {
    final res = await Api.getRequest('/cities/search?query=$cityName');
    return City.fromJson(res);
  }

  Future<List<City>> fetchCitiesWithFilters(Map<String, dynamic> filters) async {
    final queryParams = <String>[];
    
    filters.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        queryParams.add('$key=$value');
      }
    });
    
    final queryString = queryParams.isEmpty ? '' : '?${queryParams.join('&')}';
    final res = await Api.getRequest('/cities/filters$queryString');
    
    final List<dynamic> cities = res['cities'];
    return cities.map((cityJson) => City.fromJson(cityJson)).toList();
  }

}