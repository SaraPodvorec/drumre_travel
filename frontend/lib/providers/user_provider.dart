import 'package:flutter/material.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  List<String> favoriteCities = [];
  List<String> deletedCities = [];
  bool isLoading = false;
  String? error;

  // load user data when user logs in
  Future<void> loadUserData() async {
    isLoading = true;
    notifyListeners();
    
    try {
      final data = await UserService.getUserData();
      favoriteCities = List<String>.from(
        (data['favoriteCities'] as List?)?.map((c) => c.toString()) ?? []
      );
      deletedCities = List<String>.from(
        (data['deletedCities'] as List?)?.map((c) => c.toString()) ?? []
      );
      error = null;
    } catch (e) {
      error = e.toString();
    }
    
    isLoading = false;
    notifyListeners();
  }

  Future<void> addFavorite(String cityId) async {
    try {
      await UserService.addFavoriteCity(cityId);
      if (!favoriteCities.contains(cityId)) {
        favoriteCities.add(cityId);
      }
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeFavorite(String cityId) async {
    try {
      await UserService.removeFavoriteCity(cityId);
      favoriteCities.remove(cityId);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteCity(String cityId) async {
    try {
      await UserService.deleteCity(cityId);
      deletedCities.add(cityId);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> restoreCity(String cityId) async {
    try {
      await UserService.restoreCity(cityId);
      deletedCities.remove(cityId);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  void clearUserData() {
    favoriteCities = [];
    deletedCities = [];
    error = null;
    notifyListeners();
  }
}