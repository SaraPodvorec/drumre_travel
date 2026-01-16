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

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final cityProvider = context.watch<CityProvider>();
    final isFavorite = userProvider.favoriteCities.contains(city.id);
    final isWishlisted = userProvider.wishlistCities.contains(city.id);

    cityProvider.fetchAvgImpression(city.id);
    final avgImpression = cityProvider.getAvgImpression(city.id);

    const cardHeight = 250.0;
    const imageHeight = 150.0;
    const padding = 12.0;
    const spacing = 6.0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardHeight = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : 350.0;
          final imageRatio = cardHeight < 300 ? 0.55 : 0.6;
          final contentRatio = cardHeight < 300 ? 0.45 : 0.4;
          final padding = cardHeight < 250 ? 8.0 : 12.0;
          final verticalSpacing = cardHeight < 250 ? 2.0 : 4.0;
          return SizedBox(
            height: cardHeight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: cardHeight * imageRatio,
                  width: double.infinity,
                  child: Image.network(
                    city.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                city.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: cardHeight < 250 ? 14 : null,
                                    ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            if (onFavoriteToggle != null)
                              SizedBox(
                                width: cardHeight < 250 ? 28 : 32,
                                height: cardHeight < 250 ? 28 : 32,
                                child: IconButton(
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite
                                        ? Colors.red
                                        : Colors.grey,
                                    size: cardHeight < 250 ? 18 : 20,
                                  ),
                                  onPressed: onFavoriteToggle,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            if (onBookmarkToggle != null)
                              SizedBox(
                                width: cardHeight < 250 ? 28 : 32,
                                height: cardHeight < 250 ? 28 : 32,
                                child: IconButton(
                                  icon: Icon(
                                    isWishlisted
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    color: isWishlisted
                                        ? Colors.amber
                                        : Colors.grey,
                                    size: cardHeight < 250 ? 18 : 20,
                                  ),
                                  onPressed: onBookmarkToggle,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            if (onDelete != null)
                              SizedBox(
                                width: cardHeight < 250 ? 28 : 32,
                                height: cardHeight < 250 ? 28 : 32,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.block,
                                    color: Colors.grey,
                                    size: cardHeight < 250 ? 18 : 20,
                                  ),
                                  onPressed: onDelete,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: verticalSpacing),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: cardHeight < 250 ? 12 : 14,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                city.country,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontSize: cardHeight < 250 ? 11 : null,
                                      fontWeight: FontWeight.w500,
                                    ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 10),

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
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: onViewCityDetails,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: cardHeight < 250 ? 8 : 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'View details',
                              style: TextStyle(
                                fontSize: cardHeight < 250 ? 12 : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
