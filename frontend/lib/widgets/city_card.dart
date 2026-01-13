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
  final bool showBookmarkButton;
  final bool showFavoriteButton;

  const CityCard({
    super.key,
    required this.city,
    this.onFavoriteToggle,
    this.onBookmarkToggle,
    this.onDelete,
    this.onViewCityDetails,
    this.showBookmarkButton = true,
    this.showFavoriteButton = true,
    this.showDeleteButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isFavorite = userProvider.favoriteCities.contains(city.id);
    final isWishlisted = userProvider.wishlistCities.contains(city.id);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
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
                // Image
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

                // Content area
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + actions
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                city.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
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
                                    color: isFavorite ? Colors.red : Colors.grey,
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
                                    color: isWishlisted ? Colors.amber : Colors.grey,
                                    size: cardHeight < 250 ? 18 : 20,
                                  ),
                                  onPressed: onBookmarkToggle,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            if(onDelete != null) 
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

                        // Location and temperature
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
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: cardHeight < 250 ? 11 : null,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.thermostat, 
                              size: cardHeight < 250 ? 12 : 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${city.temperature.toStringAsFixed(1)}°C',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: cardHeight < 250 ? 11 : null,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Button
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
}