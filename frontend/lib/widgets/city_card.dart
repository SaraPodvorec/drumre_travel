import 'package:flutter/material.dart';
import 'package:frontend/models/city.dart';
import 'package:frontend/providers/city_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:provider/provider.dart';

class CityCard extends StatelessWidget {
  final City city;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onBookmarkToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onViewCityDetails;

  const CityCard({
    super.key,
    required this.city,
    this.onFavoriteToggle,
    this.onBookmarkToggle,
    this.onDelete,
    this.onViewCityDetails,
  });

  static const double cardHeight = 300; // fixed card height
  static const double imageHeight = cardHeight * 0.75; // 40% for image

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final cityProvider = context.watch<CityProvider>();
    final isFavorite = userProvider.favoriteCities.contains(city.id);
    final isWishlisted = userProvider.wishlistCities.contains(city.id);

    cityProvider.fetchAvgImpression(city.id);
    final avgImpression = cityProvider.getAvgImpression(city.id);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: cardHeight, // fixed height
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            SizedBox(
              height: imageHeight,
              width: double.infinity,
              child: Image.network(
                city.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              ),
            ),

            // Content (scrollable if needed)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + icons
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            city.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        if (onFavoriteToggle != null)
                          IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                            ),
                            onPressed: onFavoriteToggle,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        if (onBookmarkToggle != null)
                          IconButton(
                            icon: Icon(
                              isWishlisted
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: isWishlisted ? Colors.amber : Colors.grey,
                            ),
                            onPressed: onBookmarkToggle,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        if (onDelete != null)
                          IconButton(
                            icon: const Icon(Icons.block, color: Colors.grey),
                            onPressed: onDelete,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                
                    const SizedBox(height: 12),
                
                    // Location + rating
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            city.country,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _buildSoftChip(
                          icon: Icons.star,
                          label: avgImpression != null
                              ? avgImpression.toStringAsFixed(1)
                              : 'N/A',
                          color: _getRatingBackgroundColor(avgImpression),
                          textColor: _getRatingTextColor(avgImpression),
                        ),
                      ],
                    ),
                
                    const SizedBox(height: 18),
                
                    // View details button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onViewCityDetails,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('View details'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoftChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingBackgroundColor(double? rating) {
    if (rating == null) return Colors.grey[200]!;
    if (rating < 2.0) return Colors.red[100]!;
    if (rating < 4.0) return Colors.orange[100]!;
    return Colors.green[100]!;
  }

  Color _getRatingTextColor(double? rating) {
    if (rating == null) return Colors.grey[500]!;
    if (rating < 2.0) return Colors.red[800]!;
    if (rating < 4.0) return Colors.orange[800]!;
    return Colors.green[800]!;
  }
}
