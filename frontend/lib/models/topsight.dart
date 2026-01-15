class CityTopSight {
  final String id;
  final String cityId;
  final String name;
  final String? description;
  final String? link;
  final String image;

  CityTopSight({
    required this.id,
    required this.cityId,
    required this.name,
    this.description,
    this.link,
    required this.image,
  });

  factory CityTopSight.fromJson(Map<String, dynamic> json) {
    return CityTopSight(
      id: json['_id'] ?? '',
      cityId: json['cityId'] ?? '',
      name: json['name'] ?? 'Unknown Sight',
      description: json['description'],
      link: json['link'],
      image: json['image'] ?? 'https://via.placeholder.com/300x200?text=No+Image',
    );
  }
}