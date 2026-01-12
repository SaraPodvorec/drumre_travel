class SocialUser {
  final String id;
  final String name;
  final String email;
  final String picture;
  bool isFollowing;

  SocialUser({
    required this.id,
    required this.name,
    required this.email,
    required this.picture,
    required this.isFollowing,
  });

  factory SocialUser.fromJson(
    Map<String, dynamic> json,
    Set<String> followingIds,
  ) {
    return SocialUser(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      picture: json['picture'],
      isFollowing: followingIds.contains(json['_id']),
    );
  }
}
