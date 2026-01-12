import 'package:flutter/material.dart';
import 'package:frontend/models/review.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/city_provider.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/review_service.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/widgets/city_card.dart';
import 'package:frontend/widgets/review_card.dart';
import 'package:frontend/widgets/profile.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchReviews();
    _loadFollowStats();
  }

  Future<void> _fetchReviews() async {
    try {
      final data = await UserService.getUserData();
      final reviews = await ReviewService.getReviewsByUser(
        data['user_id'].toString(),
      );

      setState(() {
        _reviews = reviews.map((e) => CityReview.fromJson(e)).toList();
        _isReviewsLoading = false;
      });
    } catch (_) {
      setState(() => _isReviewsLoading = false);
    }
  }

  Future<void> _loadFollowStats() async {
    try {
      final stats = await UserService.getFollowStats();
      setState(() {
        followersCount = stats['followers'] ?? 0;
        followingCount = stats['following'] ?? 0;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final cityProvider = context.watch<CityProvider>();

    final profile = auth.userData;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(16, 80, 16, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0060AF), Color(0xFF4FA3FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundImage: profile?['picture'] != null
                          ? NetworkImage(
                              Api.getProxyImageUrl(profile!['picture']),
                            )
                          : null,
                      child: profile?['picture'] == null
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile?['name'] ?? 'User',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile?['email'] ?? '',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    StatsRow(
                      followers: followersCount,
                      following: followingCount,
                      reviews: _reviews.length,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                CitySection(
                  title:
                      'Favorite Cities (${userProvider.favoriteCities.length})',
                  emptyText: 'No favorite cities yet',
                  cityIds: userProvider.favoriteCities,
                  cityProvider: cityProvider,

                  onCityTap: (context, city) {
                    context.read<CityProvider>().setSelectedCity(city);
                    Navigator.pushNamed(context, '/city-details');
                  },

                  onFavoriteToggle: (city) {
                    userProvider.removeFavorite(city.id);
                  },
                ),

                CitySection(
                  title:
                      'Wishlist Cities (${userProvider.wishlistCities.length})',
                  emptyText: 'No wishlist cities yet',
                  cityIds: userProvider.wishlistCities,
                  cityProvider: cityProvider,

                  onCityTap: (context, city) {
                    context.read<CityProvider>().setSelectedCity(city);
                    Navigator.pushNamed(context, '/city-details');
                  },

                  onBookmarkToggle: (city) {
                    userProvider.removeWishlist(city.id);
                  },
                ),

                CitySection(
                  title: 'Hidden Cities (${userProvider.deletedCities.length})',
                  emptyText: 'No hidden cities',
                  cityIds: userProvider.deletedCities,
                  cityProvider: cityProvider,
                  isHidden: true,

                  onCityTap: (context, city) {
                    context.read<CityProvider>().setSelectedCity(city);
                    Navigator.pushNamed(context, '/city-details');
                  },

                  onDelete: (city) {
                    userProvider.restoreCity(city.id);
                  },
                ),

                const SizedBox(height: 32),

                Text(
                  'My Reviews',
                  style: Theme.of(context).textTheme.headlineMedium,
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
                  ..._reviews.map((r) => ReviewCard(review: r)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
