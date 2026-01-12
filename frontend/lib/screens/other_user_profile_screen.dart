import 'package:flutter/material.dart';
import 'package:frontend/widgets/review_card.dart';
import 'package:provider/provider.dart';
import '../models/social_user.dart';
import '../providers/social_provider.dart';
import '../widgets/city_card.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final String userId; // The ID of the user to view

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserProfile();
    });
  }

  Future<void> _fetchUserProfile() async {
    setState(() => isLoading = true);
    final socialProvider = context.read<SocialProvider>();

    try {
      final profile = await socialProvider.fetchUserProfile(widget.userId);
      setState(() => userProfile = profile);
    } catch (e) {
      print("Error fetching user profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load profile: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final socialProvider = context.watch<SocialProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(userProfile?.name ?? 'Profile')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userProfile == null
              ? const Center(child: Text("User not found"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(userProfile!.picture),
                            onBackgroundImageError: (_, __) {},
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userProfile!.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userProfile!.email,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'Followers: ${userProfile!.followersCount}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      'Following: ${userProfile!.following.length}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await socialProvider.toggleFollow(userProfile!);
                              setState(() {});
                            },
                            child: Text(
                              userProfile!.isFollowing ? 'Unfollow' : 'Follow',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

// Inside your build method, replace the GridView sections with this:

// Favorite Cities
if (userProfile!.favoriteCities.isNotEmpty) ...[
  const Text(
    "Favorite Cities",
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ),
  const SizedBox(height: 12),
  Wrap(
    spacing: 12,
    runSpacing: 12,
    children: userProfile!.favoriteCities.map((city) {
      return SizedBox(
        width: (MediaQuery.of(context).size.width - 16 * 2 - 12 * 3) / 4,
        child: CityCard(
          city: city,
          imageHeight: 50,
          cardHeight: 120,
          showFavoriteButton: false,
          onViewCityDetails: () {
            Navigator.pushNamed(
              context,
              '/city-details',
              arguments: city,
            );
          },
        ),
      );
    }).toList(),
  ),
  const SizedBox(height: 24),
],

// Wishlisted Cities
if (userProfile!.wishlistedCities.isNotEmpty) ...[
  const Text(
    "Wishlist Cities",
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ),
  const SizedBox(height: 12),
  Wrap(
    spacing: 12,
    runSpacing: 12,
    children: userProfile!.wishlistedCities.map((city) {
      return SizedBox(
        width: (MediaQuery.of(context).size.width - 16 * 2 - 12 * 3) / 4,
        child: CityCard(
          city: city,
          imageHeight: 50,
          cardHeight: 120,
          showFavoriteButton: false,
          onViewCityDetails: () {
            Navigator.pushNamed(
              context,
              '/city-details',
              arguments: city,
            );
          },
        ),
      );
    }).toList(),
  ),
  const SizedBox(height: 24),
],


                      if (userProfile!.reviews.isNotEmpty) ...[
                        const Text(
                          "Reviews",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: userProfile!.reviews.length * 110,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: userProfile!.reviews.length,
                            itemBuilder: (context, index) {
                              final review = userProfile!.reviews[index];
                              return ReviewCard(review: review);
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}
