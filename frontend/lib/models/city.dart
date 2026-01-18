import 'package:frontend/models/friends_impression.dart';

class City {
  final String id;
  final String name; 
  final String country;
  final String continent;
  final double lat;
  final double lon;
  final String timezone;
  final double temperature;
  final String imageUrl;
  final String imageAuthor;
  final String imageAuthorLink;
  final String imageDescription;
  final String imageAltDescription;
  final double numOfReviews;
  final double averageImpression;
  final double onWishlists;
  final String? description;
  final int? population;
  final String? currency;
  final String? language;

  final FriendsImpression? friendsImpression;
  
  City({
    required this.id,
    required this.name,
    required this.country,
    required this.continent,
    required this.lat,
    required this.lon,
    required this.timezone,
    required this.temperature,
    required this.imageUrl,
    required this.imageAuthor,
    required this.imageAuthorLink,
    required this.imageDescription,
    required this.imageAltDescription,
    required this.numOfReviews,
    required this.averageImpression,
    required this.onWishlists,
    this.description,
    this.population,
    this.currency,
    this.language,
    this.friendsImpression
  });

  factory City.fromJson(Map<String, dynamic> json) {
    final dynamicId = json['_id'] ?? json['id'] ?? '';
    return City(
      id: dynamicId.toString(),
      name: json['city'] as String? ?? '',
      country: json['country'] as String? ?? '',
      continent: json['continent'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
      timezone: json['timezone'] as String? ?? '',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String? ?? '',
      imageAuthor: json['imageAuthor'] as String? ?? '',
      imageAuthorLink: json['imageAuthorLink'] as String? ?? '',
      imageDescription: json['imageDescription'] as String? ?? '',
      imageAltDescription: json['imageAltDescription'] as String? ?? '',
      numOfReviews: (json['numOfReviews'] as num?)?.toDouble() ?? 0.0,
      averageImpression: (json['avgImpression'] as num?)?.toDouble() ??  (json['averageImpression'] as num?)?.toDouble() ?? 0.0,
      onWishlists: (json['onWishlists'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ??
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.', // MOCK
      population: (json['population'] as num?)?.toInt(), 
      currency: json['currency'] as String?,              
      language: json['language'] as String?,
      friendsImpression: json['friendsImpression'] != null 
          ? FriendsImpression.fromJson(json['friendsImpression']) 
          : null,        
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'city': name,
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
      'numOfReviews': numOfReviews,
      'averageImpression': averageImpression,
      'onWishlists': onWishlists,
      'description': description, 
      'population': population, 
      'currency': currency, 
      'language': language, 
    };
  }
}