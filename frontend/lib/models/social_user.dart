import 'package:frontend/models/city.dart';
import 'package:frontend/models/review.dart';

class SocialUser {
  final String id;
  final String name;
  final String email;
  final String picture;
  final List<String> following; // IDs of users this user follows
  int followersCount;
  final List<City> favoriteCities;
  final List<City> wishlistedCities;
  final List<CityReview> reviews;

  bool isFollowing;

  SocialUser({
    required this.id,
    required this.name,
    required this.email,
    required this.picture,
    this.following = const [],
    this.followersCount = 0,
    this.favoriteCities = const [],
    this.wishlistedCities = const [],
    this.reviews = const [],
    this.isFollowing = false,
  });

  factory SocialUser.fromJson(Map<String, dynamic> json, Set<String> followingIds) {
    print('json: $json');
    final userJson = json['user'] ?? json;
    final id = userJson['id'] ?? userJson['_id'] ?? '';
    print('Creating SocialUser with id: $id');
    return SocialUser(
      id: id,
      name: userJson['name'] ?? '',
      email: userJson['email'] ?? '',
      picture: userJson['picture'] ?? '',
      following: List<String>.from(userJson['following'] ?? []),
      followersCount: userJson['followersCount'] ?? 0,
      favoriteCities: (userJson['favoriteCities'] as List? ?? [])
          .map((c) => City.fromJson(c))
          .toList(),
      wishlistedCities: (userJson['wishlistedCities'] as List? ?? [])
          .map((c) => City.fromJson(c))
          .toList(),
      reviews: (json['reviews'] as List? ?? [])
          .map((r) => CityReview.fromJson(r))
          .toList(),    );
  }
}
