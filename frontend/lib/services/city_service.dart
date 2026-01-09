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

}