class User {
  final String googleId;
  final String email;
  final String name;
  final String picture;

  User({
    required this.googleId,
    required this.email,
    required this.name,
    required this.picture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      googleId: json['googleId'],
      email: json['email'],
      name: json['name'],
      picture: json['picture'],
    );
  }
}