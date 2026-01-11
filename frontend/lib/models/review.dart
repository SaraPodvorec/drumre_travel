class CityReview {
  final String id;
  final String? userName;
  final String? userPicture;
  final int impression;
  final int people;
  final int sights;
  final int safety;
  final int affordability;
  final String comments;
  final DateTime createdAt;

  CityReview({
    required this.id,
    this.userName,
    this.userPicture,
    required this.impression,
    required this.people,
    required this.sights,
    required this.safety,
    required this.affordability,
    required this.comments,
    required this.createdAt
  });

  factory CityReview.fromJson(Map<String, dynamic> json) {
    return CityReview(
      id: json['id'],
      userName: json['name'],
      userPicture: json['picture'],
      impression: (json['impression'] as num).toInt(),
      people: (json['people'] as num).toInt(),
      sights: (json['sights'] as num).toInt(),
      safety: (json['safety'] as num).toInt(),
      affordability: (json['affordability'] as num).toInt(),
      comments: json['comments'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}