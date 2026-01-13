import 'package:flutter/material.dart';
import 'package:frontend/models/city.dart';
import 'package:frontend/models/review.dart';
import 'package:frontend/providers/activity_provider.dart';
import 'package:frontend/providers/city_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/screens/leave_review_screen.dart';
import 'package:frontend/screens/other_user_profile_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/review_service.dart';
import 'package:frontend/widgets/main_app_bar.dart';
import 'package:frontend/widgets/review_card.dart';
import 'package:provider/provider.dart';

class CityDetailsScreen extends StatefulWidget {
  final City city;
  const CityDetailsScreen({super.key, required this.city});

  @override
  State<CityDetailsScreen> createState() => _CityDetailsScreenState();
}

class _CityDetailsScreenState extends State<CityDetailsScreen> {
  List<CityReview> _reviews = [];
  bool _isReviewsLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityProvider>().loadActivities(
        widget.city.id,
        widget.city.lat,
        widget.city.lon,
      );
    });
  }

  Future<void> _fetchReviews() async {
    try {
      final List<dynamic> data = await ReviewService.getReviewsByCity(
        widget.city.id,
      );
      setState(() {
        _reviews = data.map((json) => CityReview.fromJson(json)).toList();
        _isReviewsLoading = false;
      });
    } catch (e) {
      setState(() => _isReviewsLoading = false);
      print("Error fetching reviews: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = context.watch<ActivityProvider>();
    final userProvider = context.watch<UserProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;
    final cardHeight = MediaQuery.of(context).size.height * 0.4;
    final isFavorite = userProvider.favoriteCities.contains(widget.city.id);
    final isWishlisted = userProvider.wishlistCities.contains(widget.city.id);

    Widget sidePanel() {
      return Container(
        width: isWide ? screenWidth * 0.25 : double.infinity,
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    widget.city.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Text(
                    widget.city.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ratingItem(Icons.star, Colors.amber.shade600, '4.5'),
                ratingItem(Icons.people, Colors.cyan.shade600, '4.5'),
                ratingItem(Icons.attractions, Colors.deepPurpleAccent, '4.5'),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                Text('Visited by ${widget.city.numOfReviews} users', style: TextStyle( fontSize: 18)),
                const SizedBox(height: 12),
                Text('Wishlisted by ${widget.city.onWishlists} users', style: TextStyle( fontSize: 18)),
              ],
            ),
          ],
        ),
      );
    }

    Widget mainContent() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${widget.city.name}, ${widget.city.country}', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 96, 175), fontSize: 26),),
              Spacer(),
              IconButton(
                onPressed: () {
                  if (isFavorite) {
                    userProvider.removeFavorite(widget.city.id);
                  } else {
                    userProvider.addFavorite(widget.city.id);
                  }
                },
                icon: Icon(
                  Icons.favorite,
                  color: isFavorite ? Colors.red : Colors.grey,
                  size: isWide ? 32 : 28,
                ),
              ),
              IconButton(
                onPressed: () {
                  if (isWishlisted) {
                    userProvider.removeWishlist(widget.city.id);
                  } else {
                    userProvider.addWishlist(widget.city.id);
                  }
                },
                icon: Icon(
                  Icons.bookmark,
                  color: isWishlisted ? Colors.amber : Colors.grey,
                  size: isWide ? 32 : 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(widget.city.description ?? '<No description available>',  style: TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Population: ${widget.city.population ?? 'N/A'}', style: TextStyle(fontSize: 16),),
                    Text('Currency: ${widget.city.currency ?? 'N/A'}',  style: TextStyle(fontSize: 16)),
                    Text('Temperature: ${widget.city.temperature}°C',  style: TextStyle(fontSize: 16))
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Timezone: ${widget.city.timezone}',  style: TextStyle(fontSize: 16)),
                    Text('Language: ${widget.city.language ?? 'N/A'}',  style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Activities',  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Color.fromARGB(255, 0, 96, 175))),
          const SizedBox(height: 12),
          SizedBox(
            height: cardHeight,
            child: activityProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : activityProvider.activities.isEmpty
                ? const Center(child: Text('No activities available'))
                : Builder(
                    builder: (context) {
                      final activities = activityProvider.activities;
                      final maxCount = activities.length < 5
                          ? activities.length
                          : 5;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          for (var i = 0; i < 5; i++)
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: 16,
                                ),
                                child: i < maxCount
                                    ? activityCard(activities[i])
                                    : const SizedBox.shrink(),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                context.read<CityProvider>().setSelectedCity(widget.city);
                Navigator.pushNamed(context, '/city-activities');
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 96, 175),
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 32,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View Activities',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Reviews', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Color.fromARGB(255, 0, 96, 175)),),
              FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return LeaveReviewScreen(
                          initialCityName: widget.city.name,
                        );
                      },
                    ),
                  ).then((_) => _fetchReviews());
                },
                icon: const Icon(Icons.rate_review),
                label: const Text('Leave a review'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 96, 175),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isReviewsLoading)
            const Center(child: CircularProgressIndicator())
          else if (_reviews.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No reviews yet. Be the first to leave one!'),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reviews.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => reviewCard(_reviews[index]),
            ),
          const SizedBox(height: 24),
        ],
      );
    }

    return Scaffold(
      appBar: MainAppBar(title: widget.city.name),
      body: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sidePanel(),
                const SizedBox(width: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: mainContent(),
                    ),
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [sidePanel(), mainContent()],
                ),
              ),
            ),
    );
  }

  Widget ratingItem(IconData icon, Color iconColor, String value) {
    return Row(
      children: [
        Icon(icon, size: 28, color: iconColor),
        const SizedBox(width: 6),
        Text(value, style: const TextStyle(color: Colors.black)),
      ],
    );
  }

  Widget textBuilder(
    String title,
    double fontSize,
    FontWeight fontWeight, {
    Color? color,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color ?? Colors.black,
        ),
      ),
    );
  }

  Widget richTextBuilder(
    String title,
    String value,
    double fontSize, {
    Color? color,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: fontSize, color: color ?? Colors.black),
          children: [
            TextSpan(
              text: title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget activityCard(dynamic activity) {
    final imageUrl = activity.images.isNotEmpty
        ? activity.images.first
        : 'https://via.placeholder.com/300x200?text=No+Image';

    return Card(
      child: SizedBox.expand(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
                child: Image.network(
                  Api.getProxyImageUrl(imageUrl),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.name,
                      maxLines: 3,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
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

  String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}.";
  }

  Widget reviewCard(CityReview review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            OtherUserProfileScreen(userId: review.userId!),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: review.userPicture != null
                        ? NetworkImage(
                            Api.getProxyImageUrl(review.userPicture!),
                          )
                        : null,
                    child: review.userPicture == null
                        ? const Icon(Icons.person, size: 18, color: Colors.blue)
                        : null,
                  ),
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
                          review.userName ?? 'Anonymous',
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
                        Spacer(),
                        Wrap(
                          spacing: 16,
                          children: [
                            _iconValue(
                              Icons.star,
                              Colors.amber.shade600,
                              review.impression,
                            ),
                            _iconValue(
                              Icons.people,
                              Colors.cyan.shade600,
                              review.people,
                            ),
                            _iconValue(
                              Icons.attractions,
                              Colors.deepPurpleAccent,
                              review.sights,
                            ),
                            _iconValue(
                              Icons.security,
                              Colors.green.shade600,
                              review.safety,
                            ),
                            _iconValue(
                              Icons.attach_money,
                              Colors.orange.shade600,
                              review.affordability,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

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
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
