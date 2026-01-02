import 'package:frontend/services/api_service.dart';
import '../models/activity.dart';


class ActivitiesService {
  Future<List<Activity>> fetchActivities(String cityId, double lat, double lon) async {
    final res = await Api.getRequest('/activities?cityId=$cityId&lat=$lat&lon=$lon');
    final List<dynamic> activities = res;
    return activities.map((json) => Activity.fromJson(json)).toList();
  } 
}