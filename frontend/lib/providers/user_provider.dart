import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  List<String> favoriteCities = [];
  List<String> deletedCities = [];
  List<String> wishlistCities = [];
  String selecetedClimate = '';
  String selectedCitySize = '';
  Set<String> selectedContinents = {};
  bool isLoading = false;
  String? error;

  User? currentUser;
  String? currentUserId;

  bool _onboardingCompleted = false;
  bool _initialized = false;

  bool get onboardingCompleted => _onboardingCompleted;
  bool get isInitialized => _initialized;
  int followersCount = 0;
  int followingCount = 0;

  Future<void> loadFollowStats() async {
    try {
      final stats = await UserService.getFollowStats();
      followersCount = stats['followers'] ?? 0;
      followingCount = stats['following'] ?? 0;
      notifyListeners();
    } catch (e) {
      print('Error loading follow stats: $e');
    }
  }

  Future<void> loadUserData() async {
    isLoading = true;
    notifyListeners();
    
    try {
      final data = await UserService.getUserData();
      wishlistCities = List<String>.from(
        (data['wishlistCities'] as List?)?.map((c) => c.toString()) ?? []
      );
      favoriteCities = List<String>.from(
        (data['favoriteCities'] as List?)?.map((c) => c.toString()) ?? []
      );
      deletedCities = List<String>.from(
        (data['deletedCities'] as List?)?.map((c) => c.toString()) ?? []
      );
      _onboardingCompleted = data['onboardingCompleted'] == true;
      currentUserId = data['user_id'];
      error = null;
    } catch (e) {
      error = e.toString();
    }
    
    isLoading = false;
    _initialized = true;
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
  Future<void> addWishlist(String cityId) async {
    try {
      await UserService.addWishlistCity(cityId);
      if (!wishlistCities.contains(cityId)) {
        wishlistCities.add(cityId);
      }
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
  Future<void> removeWishlist(String cityId) async {
    try {
      await UserService.removeWishlistCity(cityId);
      wishlistCities.remove(cityId);
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

  Future<void> completeOnboarding({
    required String climate,
    required String citySize,
    required Set<String> continents,
  }) async {
    try {
      await UserService.completeOnboarding(
        impressionPreference: climate,
        citySize: citySize,
        continents: continents.toList(),
      );

      selecetedClimate = climate;
      selectedCitySize = citySize;
      selectedContinents = continents;

      _onboardingCompleted = true;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  void clearUserData() {
    wishlistCities = [];
    favoriteCities = [];
    deletedCities = [];
    selecetedClimate = '';
    selectedCitySize = '';
    selectedContinents.clear();
    _initialized = false;
    error = null;
    notifyListeners();
  }
}