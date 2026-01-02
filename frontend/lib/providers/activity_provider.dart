import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../services/activities_service.dart';

class ActivityProvider extends ChangeNotifier {
  final ActivitiesService _activitiesService = ActivitiesService();
  List<Activity> activities = [];
  bool isLoading = false;
  String? error;

  Future<void> loadActivities(String cityId, double lat, double lon) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      activities = await _activitiesService.fetchActivities(cityId, lat, lon);
    } catch (e) {
      error = 'Failed to load activities: $e';
      print('Error loading activities: $e');
    }

    isLoading = false;
    notifyListeners();
  }
}