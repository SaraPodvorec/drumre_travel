class City {
  final String id;
  final String name; 
  final String country;
  final double lat;
  final double lon;
  final String timezone;
  final double temperature;
  final String imageUrl;
  final String imageAuthor;
  final String imageAuthorLink;
  final String imageDescription;
  final String imageAltDescription;

  City({
    required this.id,
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
    required this.timezone,
    required this.temperature,
    required this.imageUrl,
    required this.imageAuthor,
    required this.imageAuthorLink,
    required this.imageDescription,
    required this.imageAltDescription,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['_id'] as String? ?? '', 
      name: json['city'] as String? ?? '', 
      country: json['country'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
      timezone: json['timezone'] as String? ?? '',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String? ?? '',
      imageAuthor: json['imageAuthor'] as String? ?? '',
      imageAuthorLink: json['imageAuthorLink'] as String? ?? '',
      imageDescription: json['imageDescription'] as String? ?? '',
      imageAltDescription: json['imageAltDescription'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'imageUrl': imageUrl,
      'lat': lat,
      'lon': lon,
      'timezone': timezone,
      'temperature': temperature,
      'imageAuthor': imageAuthor,
      'imageAuthorLink': imageAuthorLink,
      'imageDescription': imageDescription,
      'imageAltDescription': imageAltDescription,
    };
  }
}