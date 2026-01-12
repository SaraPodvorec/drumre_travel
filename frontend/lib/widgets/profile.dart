import 'package:flutter/material.dart';
import 'package:frontend/models/city.dart';
import 'package:frontend/providers/city_provider.dart';
import 'package:frontend/widgets/city_card.dart';

class StatsRow extends StatelessWidget {
  final int followers;
  final int following;
  final int reviews;

  const StatsRow({
    required this.followers,
    required this.following,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    Widget item(String label, int value) => Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        statPill('Followers', followers),
        statPill('Following', following),
        statPill('Reviews', reviews),
      ],
    );
  }
}

Widget statPill(String label, int value) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    margin: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
      ],
    ),
  );
}

class CitySection extends StatelessWidget {
  final String title;
  final String emptyText;
  final List<String> cityIds;
  final CityProvider cityProvider;
  final bool isHidden;

  final void Function(BuildContext context, City city) onCityTap;
  final void Function(City city)? onFavoriteToggle;
  final void Function(City city)? onBookmarkToggle;
  final void Function(City city)? onDelete;
  final bool showDeleteButton;
  final bool showFavoriteButton;
  final bool showBookmarkButton;

  const CitySection({
    super.key,
    required this.title,
    required this.emptyText,
    required this.cityIds,
    required this.cityProvider,
    required this.onCityTap,
    this.onFavoriteToggle,
    this.onBookmarkToggle,
    this.onDelete,
    this.isHidden = false,
    this.showDeleteButton = true,
    this.showFavoriteButton = true,
    this.showBookmarkButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),

        if (cityIds.isEmpty)
          Text(emptyText, style: TextStyle(color: Colors.grey[600]))
        else
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: cityIds.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final cityIndex = cityProvider.cities.indexWhere(
                  (c) => c.id == cityIds[index],
                );

                if (cityIndex == -1) return const SizedBox.shrink();
                final city = cityProvider.cities[cityIndex];

                return SizedBox(
                  width: 200,
                  child: CityCard(
                    city: city,
                    imageHeight: 110,
                    cardHeight: 250,

                    showFavoriteButton: onFavoriteToggle != null && !isHidden,
                    showBookmarkButton: onBookmarkToggle != null,
                    showDeleteButton: onDelete != null || isHidden,

                    onFavoriteToggle: onFavoriteToggle != null
                        ? () => onFavoriteToggle!(city)
                        : null,

                    onBookmarkToggle: onBookmarkToggle != null
                        ? () => onBookmarkToggle!(city)
                        : null,

                    onDelete: onDelete != null ? () => onDelete!(city) : null,

                    onViewCityDetails: () => onCityTap(context, city),
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 32),
      ],
    );
  }
}
