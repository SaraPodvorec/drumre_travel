import 'package:flutter/material.dart';
import 'package:frontend/models/city.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:provider/provider.dart';

class CityCard extends StatelessWidget {
  final City city;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onBookmarkToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onViewCityDetails;
  final bool showDeleteButton;
  final bool showFavoriteButton;
  final bool showBookmarkButton;
  final double imageHeight;
  final double cardHeight;

  const CityCard({
    super.key,
    required this.city,
    this.onFavoriteToggle,
    this.onBookmarkToggle,
    this.onDelete,
    this.onViewCityDetails,
    this.showDeleteButton = true,
    this.showFavoriteButton = true,
    this.showBookmarkButton = true,
    this.imageHeight = 100,
    this.cardHeight = 240,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isFavorite = userProvider.favoriteCities.contains(city.id);
    final isWishlisted = userProvider.wishlistedCities.contains(city.id);
    
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
            child: Image.network(
              city.imageUrl,
              height: imageHeight,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        city.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        if (showFavoriteButton)
                          IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                            ),
                            onPressed: onFavoriteToggle,
                          ),
                        if (showBookmarkButton)
                          IconButton(
                            icon: Icon(
                              isWishlisted ? Icons.bookmark : Icons.bookmark_border,
                              color: isWishlisted ? Colors.amber : Colors.grey,
                            ),
                            onPressed: onBookmarkToggle,
                          ),
                        if (showDeleteButton)
                          IconButton(
                            icon: const Icon(Icons.block, color: Colors.grey),
                            onPressed: onDelete,
                          ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 4),
                        Text(city.country),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.thermostat, size: 16),
                        const SizedBox(width: 4),
                        Text('${city.temperature.toStringAsFixed(1)}°C'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onViewCityDetails,
                    child: const Text(
                      'View Details',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}