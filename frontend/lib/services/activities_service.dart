import 'package:frontend/services/api_service.dart';
import '../models/activity.dart';


class ActivitiesService {
  Future<List<Activity>> fetchActivities(
    String cityId,
    double lat,
    double lon, {
    bool forceRefresh = false,
  }) async {
    final forceParam = forceRefresh ? '&force=true' : '';
    final res = await Api.getRequest('/activities?cityId=$cityId&lat=$lat&lon=$lon$forceParam');
    final List<dynamic> activities = res;
    return activities.map((json) => Activity.fromJson(json)).toList();
  } 
}