class Activity {
  final String cityId;
  final String name;
  final String description;
  final double priceAmount;
  final String priceCurrency;
  final List<String> images;
  final String bookingLink;
  final String minDuration;

  Activity({
    required this.cityId,
    required this.name,
    required this.description,
    required this.priceAmount,
    required this.priceCurrency,
    required this.images,
    required this.bookingLink,
    required this.minDuration,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    final price = json['price'] as Map<String, dynamic>? ?? {};
    
    return Activity(
      cityId: json['cityId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priceAmount: (price['amount'] as num?)?.toDouble() ?? 0.0,
      priceCurrency: price['currency'] as String? ?? '',
      images: List<String>.from(json['images'] ?? []),
      bookingLink: json['bookingLink'] as String? ?? '',
      minDuration: json['minimumDuration'] as String? ?? '',
    );
  }
}