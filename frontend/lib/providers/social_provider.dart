import 'package:flutter/material.dart';
import '../models/social_user.dart';
import '../services/social_service.dart';

class SocialProvider extends ChangeNotifier {
  List<SocialUser> users = [];
  bool isLoading = false;
  String? error;

  Future<void> loadUsers() async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await SocialService.fetchAllUsers();
      final List usersJson = data['users'];
      final Set<String> followingIds =
          Set<String>.from(data['following']);

      users = usersJson
          .map((u) => SocialUser.fromJson(u, followingIds))
          .toList();

      error = null;
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFollow(SocialUser user) async {
    final previous = user.isFollowing;
    user.isFollowing = !previous;
    notifyListeners();

    try {
      if (user.isFollowing) {
        await SocialService.follow(user.id);
      } else {
        await SocialService.unfollow(user.id);
      }
    } catch (e) {
      user.isFollowing = previous; // rollback
      notifyListeners();
    }
  }
}
