import 'package:flutter/material.dart';
import '../models/social_user.dart';
import '../services/social_service.dart';

class SocialProvider extends ChangeNotifier {
  List<SocialUser> users = [];
  bool isLoading = false;
  String? error;

  /// Convenience getter: set of IDs the logged-in user is following
  Set<String> get followingIds => users.where((u) => u.isFollowing).map((u) => u.id).toSet();

  /// Load all users for discovery
  Future<void> loadUsers() async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await SocialService.fetchAllUsers();
      final List usersJson = data['users'] ?? [];
      final Set<String> currentFollowingIds = Set<String>.from(data['following'] ?? []);

      users = usersJson.map((u) => SocialUser.fromJson(u, currentFollowingIds)).toList();
      error = null;
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  /// Toggle follow/unfollow
  Future<void> toggleFollow(SocialUser user) async {
    final previous = user.isFollowing;
    user.isFollowing = !previous;
    user.followersCount += user.isFollowing ? 1 : -1;
    notifyListeners();

    try {
      if (user.isFollowing) {
        await SocialService.follow(user.id);
      } else {
        await SocialService.unfollow(user.id);
      }
    } catch (e) {
      // Rollback if network fails
      user.isFollowing = previous;
      user.followersCount += user.isFollowing ? 1 : -1;
      notifyListeners();
    }
  }

  /// Fetch another user's profile for viewing
  Future<SocialUser> fetchUserProfile(String userId) async {
    return SocialService.getUserProfile(userId, followingIds);
  }
}
