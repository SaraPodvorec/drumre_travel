import 'package:flutter/material.dart';
import 'package:frontend/models/city.dart';
import 'package:frontend/models/review.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/providers/activity_provider.dart';
import 'package:frontend/providers/city_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/screens/leave_review_screen.dart';
import 'package:frontend/screens/other_user_profile_screen.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/review_service.dart';
import 'package:frontend/widgets/horizontal_shorts_list.dart';
import 'package:frontend/widgets/horizontal_sights.dart';
import 'package:frontend/widgets/main_app_bar.dart';
import 'package:provider/provider.dart';

class WeatherInfo {
  final double temp;
  final String main;

  WeatherInfo({required this.temp, required this.main});
}

class CityDetailsScreen extends StatefulWidget {
  final City city;
  const CityDetailsScreen({super.key, required this.city});

  @override
  State<CityDetailsScreen> createState() => _CityDetailsScreenState();
}

class _CityDetailsScreenState extends State<CityDetailsScreen> {
  List<CityReview> _reviews = [];
  bool _isReviewsLoading = true;
  double _avgImpression = 0.0;
  double _avgPeople = 0.0;
  double _avgSights = 0.0;
  double _avgSafety = 0.0;
  double _avgAffordability = 0.0;
  int _numOfReviews = 0;
  bool _isRatingsLoading = true;
  User? _currentUser;
  WeatherInfo? _currentWeather;
  bool _isWeatherLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
    _fetchRatingsData();
    context.read<UserProvider>().loadUserData();
    _fetchCurrentWeather(); //comment to not spend
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityProvider>().loadActivities(
        widget.city.id,
        widget.city.lat,
        widget.city.lon,
      );
    });
  }

  Future<void> _fetchCurrentWeather() async {
    try {
      setState(() {
        _isWeatherLoading = true;
      });
      final data = await Api.getRequest('/weather/${widget.city.name}');
      print("Weather data for ${widget.city.name}: $data");
      setState(() {
        _currentWeather = WeatherInfo(
          temp: (data['temperature'] ?? 0.0).toDouble(),
          main: data['main'] ?? 'N/A',
        );
      });
    } catch (e) {
      print("Error fetching weather data: $e");
    }
    setState(() {
      _isWeatherLoading = false;
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

  Future<void> _fetchRatingsData() async {
    try {
      final data = await ReviewService.getCityReviewsData(widget.city.id);
      setState(() {
        _avgImpression = (data['avgImpression'] ?? 0.0).toDouble();
        _avgPeople = (data['avgPeople'] ?? 0.0).toDouble();
        _avgSights = (data['avgSights'] ?? 0.0).toDouble();
        _avgSafety = (data['avgSafety'] ?? 0.0).toDouble();
        _avgAffordability = (data['avgAffordability'] ?? 0.0).toDouble();
        _numOfReviews = data['numOfReviews'] ?? 0;
        _isRatingsLoading = false;
      });
    } catch (e) {
      setState(() => _isRatingsLoading = false);
      print("Error fetching ratings data: $e");
    }
  }

  String _emojiForWeather(String main) {
    final m = main.toLowerCase();
    if (m.contains('clear')) return '☀️';
    if (m.contains('cloud')) return '☁️';
    if (m.contains('rain')) return '🌧️';
    if (m.contains('snow')) return '❄️';
    if (m.contains('storm') || m.contains('thunder')) return '⛈️';
    if (m.contains('drizzle')) return '🌦️';
    if (m.contains('mist') || m.contains('fog')) return '🌫️';
    return '🌍';
  }

  IconData weatherIconFromMain(String main) {
    final m = main.toLowerCase();

    if (m.contains('clear')) return Icons.sunny;
    if (m.contains('cloud')) return Icons.cloud;
    if (m.contains('rain')) return Icons.grain;
    if (m.contains('snow')) return Icons.ac_unit;
    if (m.contains('storm') || m.contains('thunder')) return Icons.flash_on;
    if (m.contains('drizzle')) return Icons.grain;
    if (m.contains('mist') || m.contains('fog')) return Icons.blur_on;

    return Icons.public;
  }

  String _labelForWeather(String main) {
    final m = main.toLowerCase();
    if (m.contains('clear')) return 'Sunny';
    if (m.contains('cloud')) return 'Cloudy';
    if (m.contains('rain')) return 'Rainy';
    if (m.contains('snow')) return 'Snowy';
    if (m.contains('storm') || m.contains('thunder')) return 'Stormy';
    if (m.contains('drizzle')) return 'Drizzle';
    if (m.contains('mist') || m.contains('fog')) return 'Foggy';
    return main;
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
    final currentUser = userProvider.currentUser;

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
            _isRatingsLoading
                ? const Center(child: CircularProgressIndicator())
                : Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 24,
                    runSpacing: 16,
                    children: [
                      ratingItem(
                        Icons.star,
                        Colors.amber.shade600,
                        _avgImpression.toStringAsFixed(1),
                      ),
                      ratingItem(
                        Icons.people,
                        Colors.cyan.shade600,
                        _avgPeople.toStringAsFixed(1),
                      ),
                      ratingItem(
                        Icons.attractions,
                        Colors.deepPurpleAccent,
                        _avgSights.toStringAsFixed(1),
                      ),
                      ratingItem(
                        Icons.security,
                        Colors.green.shade600,
                        _avgSafety.toStringAsFixed(1),
                      ),
                      ratingItem(
                        Icons.attach_money,
                        Colors.orange.shade600,
                        _avgAffordability.toStringAsFixed(1),
                      ),
                    ],
                  ),

            const SizedBox(height: 16),
            Column(
              children: [
                Text(
                  'Visited by $_numOfReviews users',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 12),
                Text(
                  'Wishlisted by ${widget.city.onWishlists} users',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget mainContent() {
      final weather = _currentWeather;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${widget.city.name}, ${widget.city.country}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 96, 175),
                  fontSize: 26,
                ),
              ),
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
          Text(
            widget.city.description ?? '<No description available>',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          // Under the description
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              infoChip(
                icon: Icons.location_city,
                title: 'Population',
                value: widget.city.population?.toString() ?? 'N/A',
                color: Colors.purple.shade300,
              ),
              infoChip(
                icon: Icons.attach_money,
                title: 'Currency',
                value: widget.city.currency ?? 'N/A',
                color: Colors.orange.shade300,
              ),
              infoChip(
                title: 'Weather',
                value: _isWeatherLoading
                    ? 'Loading...'
                    : weather == null
                    ? widget.city.temperature.toString()
                    : '${weather.temp.toStringAsFixed(1)}°C · ${_labelForWeather(weather.main)}',
                color: Colors.blue.shade300,
                isWeather: true,
                icon: Icons.public,
                weatherMain: weather?.main
              ),
              infoChip(
                icon: Icons.access_time,
                title: 'Timezone',
                value: widget.city.timezone,
                color: Colors.teal.shade300,
              ),
              infoChip(
                icon: Icons.language,
                title: 'Language',
                value: widget.city.language ?? 'N/A',
                color: Colors.redAccent.shade200,
              ),
            ],
          ),

          const SizedBox(height: 24),
          HorizontalSightsList(cityId: widget.city.id),
          const SizedBox(height: 24),
          HorizontalShortsList(cityId: widget.city.id),
          const SizedBox(height: 24),
          Text(
            'Activities',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Color.fromARGB(255, 0, 96, 175),
            ),
          ),
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
                                padding: EdgeInsets.only(right: 16),
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
              Text(
                'Reviews',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color.fromARGB(255, 0, 96, 175),
                ),
              ),
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

  Widget infoChip({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool isWeather = false,
    String? weatherMain,
  }) {
    final background = Color.alphaBlend(color.withOpacity(0.28), Colors.white);

    return Material(
      color: Colors.transparent,
      elevation: 5,
      shadowColor: color.withOpacity(0.45),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [background, color.withOpacity(0.35)],
          ),
          border: Border.all(color: color.withOpacity(0.35), width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            isWeather && weatherMain != null
                ? Icon(weatherIconFromMain(weatherMain), size: 18, color: color)
                : Icon(icon, size: 18, color: color),

            const SizedBox(width: 8),

            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget ratingItem(IconData icon, Color iconColor, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: iconColor),
        const SizedBox(width: 6),
        Text(value, style: const TextStyle(color: Colors.black)),
      ],
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
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      activity.name,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold),
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
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;
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
                    print("cureent user ${userProvider.currentUserId} i review.user ${review.userId}");
                    if (review.userId != userProvider.currentUserId) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              OtherUserProfileScreen(userId: review.userId!),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProfileScreen()),
                      );
                    }
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
