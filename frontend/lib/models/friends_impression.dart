class FriendsImpression {
  final double avgImpression;
  final double avgPeople;
  final double avgSights;
  final double avgSafety;
  final double avgAffordability;

  FriendsImpression({
    required this.avgImpression,
    required this.avgPeople,
    required this.avgSights,
    required this.avgSafety,
    required this.avgAffordability,
  });

  factory FriendsImpression.fromJson(Map<String, dynamic> json) {
    return FriendsImpression(
      avgImpression: (json['avgImpression'] as num).toDouble(),
      avgPeople: (json['avgPeople'] as num).toDouble(),
      avgSights: (json['avgSights'] as num).toDouble(),
      avgSafety: (json['avgSafety'] as num).toDouble(),
      avgAffordability: (json['avgAffordability'] as num).toDouble(),
    );
  }
}