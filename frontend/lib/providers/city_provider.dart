import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/services/review_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/city.dart';
import '../services/city_service.dart';

class CityProvider extends ChangeNotifier {
  final CityService _cityService = CityService();
  List<City> cities = [];
  City? selectedCity;
  bool isLoading = false;
  String? error;
  bool isSearching = false;

  final Map<String, double> _avgImpressions = {};
  final Set<String> _avgImpressionLoading = {};

  CityProvider() {
    _restoreSelectedCity();
  }

  Future<void> loadCities() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      cities = await _cityService.fetchCities();
      await _restoreSelectedCity();
    } catch (e) {
      error = 'Failed to load cities: $e';
      print('Error loading cities: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadCitiesWithFilters(Map<String, dynamic> filters) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      cities = await _cityService.fetchCitiesWithFilters(filters);
    } catch (e) {
      error = 'Failed to load cities with filters: $e';
      print('Error loading cities with filters: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<City?> searchCity(String cityName) async {
    isSearching = true;
    error = null;
    notifyListeners();

    try {
      final city = await _cityService.searchCity(cityName);
      // Add the searched city to the list if it's not already there
      if (!cities.any((c) => c.id == city.id)) {
        cities.add(city);
      }
      isSearching = false;
      notifyListeners();
      return city;
    } catch (e) {
      error = 'City not found: $e';
      print('Error searching city: $e');
      isSearching = false;
      notifyListeners();
      return null;
    }
  }

  void setSelectedCity(City city) {
    selectedCity = city;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('selectedCity', jsonEncode(city.toJson()));
    });
    notifyListeners();
  }

  Future<void> _restoreSelectedCity() async {
    final prefs = await SharedPreferences.getInstance();
    final city = prefs.getString('selectedCity');
    if (city != null) {
      try {
        selectedCity = City.fromJson(jsonDecode(city));
        notifyListeners();
      } catch (e) {
        print('Error restoring city: $e');
      }
    }
  }

  double? getAvgImpression(String cityId) {
    final value = _avgImpressions[cityId];
    return value;
  }

  Future<void> fetchAvgImpression(String cityId) async {
    if (_avgImpressions.containsKey(cityId)) {
      return;
    }

    if (_avgImpressionLoading.contains(cityId)) {
      return;
    }

    _avgImpressionLoading.add(cityId);

    try {
      final data = await ReviewService.getCityReviewsData(cityId);

      final rawAvg = data['avgImpression'];

      final avg = rawAvg is num ? rawAvg.toDouble() : 0.0;

      _avgImpressions[cityId] = avg;
    } catch (e, stack) {
      print(stack.toString());

      _avgImpressions[cityId] = 0.0;
    } finally {
      _avgImpressionLoading.remove(cityId);

      notifyListeners();
    }
  }
}
