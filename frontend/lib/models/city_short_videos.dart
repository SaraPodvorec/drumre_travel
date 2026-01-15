class CityShortVideos {
  CityShortVideos({
    required this.cityId,
    required this.title,
    required this.source,
    required this.extensions,
    required this.thumbnail,
    required this.link,
    required this.lastFetched,
  });

  final String cityId;
  final String title;
  final String source;
  final String extensions;
  final String thumbnail;
  final String link;
  final DateTime lastFetched;

  factory CityShortVideos.fromJson(Map<String, dynamic> json) {
    return CityShortVideos(
      cityId: json['cityId'] ?? '',
      title: json['title'] ?? '',
      source: json['source'] ?? '',
      extensions: json['extensions'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      link: json['link'] ?? '',
      lastFetched: json['lastFetched'] != null
          ? DateTime.parse(json['lastFetched'])
          : DateTime.now(),
    );
  }
}