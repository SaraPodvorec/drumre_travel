import 'package:flutter/material.dart';
import 'package:frontend/models/review.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/city_provider.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/review_service.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/widgets/city_card.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<CityReview> _reviews = [];
  bool _isReviewsLoading = true;
  int followersCount = 0;
  int followingCount = 0;

  Future<void> _fetchReviews() async {
    try {
      final data = await UserService.getUserData();
      final List<dynamic> reviews = await ReviewService.getReviewsByUser(
        data['user_id'].toString(),
      );
      setState(() {
        _reviews = reviews.map((json) => CityReview.fromJson(json)).toList();
        _isReviewsLoading = false;
      });
    } catch (e) {
      setState(() => _isReviewsLoading = false);
      print("Error fetching reviews: $e");
    }
  }

  Future<void> _loadFollowStats() async {
    try {
      final stats = await UserService.getFollowStats();
      setState(() {
        followersCount = stats['followers'] ?? 0;
        followingCount = stats['following'] ?? 0;
      });
    } catch (e) {
      print('Error loading follow stats: $e');
    }
  }
  @override
  void initState() {
    super.initState();
    _fetchReviews();
    _loadFollowStats();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final cityProvider = context.watch<CityProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        followersCount.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Followers'),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        followingCount.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Following'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

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
                    final cityIndex = cityProvider.cities.indexWhere(
                      (c) => c.id == cityId,
                    );

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
                      onViewCityDetails: () {
                        context.read<CityProvider>().setSelectedCity(city);
                        Navigator.pushNamed(context, '/city-details');
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
                    final cityIndex = cityProvider.cities.indexWhere(
                      (c) => c.id == cityId,
                    );

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
                      onViewCityDetails: () {
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
                    final cityIndex = cityProvider.cities.indexWhere(
                      (c) => c.id == cityId,
                    );

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
                      onViewCityDetails: () {
                        context.read<CityProvider>().setSelectedCity(city);
                        Navigator.pushNamed(context, '/city-activities');
                      },
                    );
                  },
                ),
              const SizedBox(height: 32),

              Text(
                'My Reviews (${_reviews.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              if (_isReviewsLoading)
                const Center(child: CircularProgressIndicator())
              else if (_reviews.isEmpty)
                Text(
                  'You haven’t written any reviews yet',
                  style: TextStyle(color: Colors.grey[600]),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _reviews.length,
                  itemBuilder: (context, index) {
                    return _profileReviewItem(_reviews[index]);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileReviewItem(CityReview review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_city,
                  size: 18,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.city ?? 'Unknown city',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(review.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Wrap(
                      spacing: 16,
                      children: [
                        _iconValue(
                          Icons.favorite,
                          Colors.red,
                          review.impression,
                        ),
                        _iconValue(
                          Icons.people,
                          Colors.blueGrey,
                          review.people,
                        ),
                        _iconValue(
                          Icons.account_balance,
                          Colors.indigo,
                          review.sights,
                        ),
                        _iconValue(Icons.shield, Colors.green, review.safety),
                        _iconValue(
                          Icons.attach_money,
                          Colors.teal,
                          review.affordability,
                        ),
                      ],
                    ),

                    if (review.comments.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        review.comments,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
      ],
    );
  }

  Widget _iconValue(IconData icon, Color color, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}.";
  }
}
