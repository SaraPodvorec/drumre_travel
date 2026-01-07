import 'package:flutter/material.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/city_provider.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/widgets/city_card.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final cityProvider = context.watch<CityProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (authProvider.userData != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        if (authProvider.userData!['picture'] != null)
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(
                              Api.getProxyImageUrl(
                                authProvider.userData!['picture'],
                              ),
                            ),
                          ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authProvider.userData!['name'] ?? 'User',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                authProvider.userData!['email'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                'Favorite Cities (${userProvider.favoriteCities.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (userProvider.favoriteCities.isEmpty)
                Text(
                  'No favorite cities yet',
                  style: TextStyle(color: Colors.grey[600]),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 240,
                  ),
                  itemCount: userProvider.favoriteCities.length,
                  itemBuilder: (context, index) {
                    final cityId = userProvider.favoriteCities[index];
                    final cityIndex =
                        cityProvider.cities.indexWhere((c) => c.id == cityId);

                    if (cityIndex == -1) return const SizedBox.shrink();

                    final city = cityProvider.cities[cityIndex];

                    return CityCard(
                      city: city,
                      imageHeight: 100,
                      cardHeight: 240,
                      showDeleteButton: false,
                      onFavoriteToggle: () {
                        userProvider.removeFavorite(city.id);
                      },
                      onViewActivities: () {
                        context.read<CityProvider>().setSelectedCity(city);
                        Navigator.pushNamed(context, '/city-activities');
                      },
                    );
                  },
                ),
              const SizedBox(height: 32),
              Text(
                'Wishlist Cities (${userProvider.wishlistedCities.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (userProvider.wishlistedCities.isEmpty)
                Text(
                  'No wishlist cities yet',
                  style: TextStyle(color: Colors.grey[600]),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 240,
                  ),
                  itemCount: userProvider.wishlistedCities.length,
                  itemBuilder: (context, index) {
                    final cityId = userProvider.wishlistedCities[index];
                    final cityIndex =
                        cityProvider.cities.indexWhere((c) => c.id == cityId);

                    if (cityIndex == -1) return const SizedBox.shrink();

                    final city = cityProvider.cities[cityIndex];

                    return CityCard(
                      city: city,
                      imageHeight: 100,
                      cardHeight: 240,
                      showFavoriteButton: false,
                      showBookmarkButton: true,
                      onBookmarkToggle: () {
                        userProvider.removeWishlist(city.id);
                      },
                      onViewActivities: () {
                        context.read<CityProvider>().setSelectedCity(city);
                        Navigator.pushNamed(context, '/city-activities');
                      },
                    );
                  },
                ),
              const SizedBox(height: 32),
              Text(
                'Hidden Cities (${userProvider.deletedCities.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (userProvider.deletedCities.isEmpty)
                Text(
                  'No hidden cities',
                  style: TextStyle(color: Colors.grey[600]),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 240,
                  ),
                  itemCount: userProvider.deletedCities.length,
                  itemBuilder: (context, index) {
                    final cityId = userProvider.deletedCities[index];
                    final cityIndex =
                        cityProvider.cities.indexWhere((c) => c.id == cityId);

                    if (cityIndex == -1) return const SizedBox.shrink();

                    final city = cityProvider.cities[cityIndex];

                    return CityCard(
                      city: city,
                      imageHeight: 100,
                      cardHeight: 240,
                      showFavoriteButton: false,
                      onDelete: () {
                        userProvider.restoreCity(city.id);
                      },
                      onViewActivities: () {
                        context.read<CityProvider>().setSelectedCity(city);
                        Navigator.pushNamed(context, '/city-activities');
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}