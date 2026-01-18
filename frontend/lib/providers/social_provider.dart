import 'package:flutter/material.dart';
import '../models/social_user.dart';
import '../services/social_service.dart';

class SocialProvider extends ChangeNotifier {
  SocialProvider() {
    loadUsers();
  }
  List<SocialUser> users = [];
  bool isLoading = false;
  String? error;

  Set<String> get followingIds =>
      users.where((u) => u.isFollowing).map((u) => u.id).toSet();

  Future<void> loadUsers() async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await SocialService.fetchAllUsers();
      final List usersJson = data['users'] ?? [];
      final Set<String> currentFollowingIds = Set<String>.from(
        data['following'] ?? [],
      );

      users = usersJson.map((u) {
        final user = SocialUser.fromJson(u, currentFollowingIds);
        return user;
      }).toList();

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
    user.followersCount += user.isFollowing ? 1 : -1;

    final index = users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      users[index] = user;
    }

    notifyListeners();

    try {
      if (user.isFollowing) {
        await SocialService.follow(user.id);
      } else {
        await SocialService.unfollow(user.id);
      }
    } catch (e) {
      user.isFollowing = previous;
      user.followersCount += user.isFollowing ? 1 : -1;

      if (index != -1) users[index] = user;

      notifyListeners();
    }
  }

  Future<SocialUser> fetchUserProfile(String userId) async {
    return SocialService.getUserProfile(userId, followingIds);
  }
  
  void reset() {
    users = [];
    isLoading = false;
    error = null;
    notifyListeners();
  }
}
