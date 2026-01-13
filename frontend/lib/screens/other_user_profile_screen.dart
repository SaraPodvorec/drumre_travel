import 'package:flutter/material.dart';
import 'package:frontend/models/social_user.dart';
import 'package:frontend/providers/social_provider.dart';
import 'package:frontend/providers/city_provider.dart';
import 'package:frontend/widgets/review_card.dart';
import 'package:frontend/widgets/profile.dart';
import 'package:provider/provider.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final String userId;

  const OtherUserProfileScreen({super.key, required this.userId});

  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  SocialUser? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  Future<void> _loadProfile() async {
    setState(() => isLoading = true);
    try {
      final socialProvider = context.read<SocialProvider>();
      final profile = await socialProvider.fetchUserProfile(widget.userId);
      setState(() => userProfile = profile);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load user profile')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final socialProvider = context.watch<SocialProvider>();
    final cityProvider = context.watch<CityProvider>();

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (userProfile == null) {
      return const Scaffold(body: Center(child: Text('User not found')));
    }

    final isFollowing = socialProvider.users
        .firstWhere((u) => u.id == userProfile!.id)
        .isFollowing;

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
                      backgroundImage: NetworkImage(userProfile!.picture),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userProfile!.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userProfile!.email,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Spacer(),
                    StatsRow(
                      followers: userProfile!.followersCount,
                      following: userProfile!.following.length,
                      reviews: userProfile!.reviews.length,
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          socialProvider.toggleFollow(userProfile!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isFollowing ? Colors.grey.shade400 : Colors.blue,
                      ),
                      child: Text(isFollowing ? 'Unfollow' : 'Follow'),
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
                // Favorite Cities (view-only)
                CitySection(
                  title:
                      'Favorite Cities (${userProfile!.favoriteCities.length})',
                  emptyText: 'No favorite cities',
                  cityIds:
                      userProfile!.favoriteCities.map((c) => c.id).toList(),
                  cityProvider: cityProvider,
                  onCityTap: (context, city) {
                    cityProvider.setSelectedCity(city);
                    Navigator.pushNamed(context, '/city-details');
                  },
                  // showFavoriteButton: false,
                ),

                const SizedBox(height: 24),

                // Wishlist Cities (view-only)
                CitySection(
                  title: 'Wishlist (${userProfile!.wishlistCities.length})',
                  emptyText: 'No wishlist cities',
                  cityIds: userProfile!.wishlistCities.map((c) => c.id).toList(),
                  cityProvider: cityProvider,
                  // showFavoriteButton: false,
                  onCityTap: (context, city) {
                    cityProvider.setSelectedCity(city);
                    Navigator.pushNamed(context, '/city-details');
                  },
                ),

                const SizedBox(height: 32),

                // Reviews
                if (userProfile!.reviews.isEmpty)
                  Text(
                    'This user hasn’t written any reviews yet',
                    style: TextStyle(color: Colors.grey[600]),
                  )
                else ...[
                  const Text(
                    'Reviews',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...userProfile!.reviews
                      .map((r) => ReviewCard(review: r))
                      .toList(),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
