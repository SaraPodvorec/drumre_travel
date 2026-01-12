import 'package:flutter/material.dart';
import 'package:frontend/models/city.dart';
import 'package:frontend/models/review.dart';
import 'package:frontend/providers/activity_provider.dart';
import 'package:frontend/providers/city_provider.dart';
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

    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.4;

    return Scaffold(
      appBar: MainAppBar(title: widget.city.name),
      body: Row(
        children: [
          // Side panel with city image and stats
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: Color.fromARGB(255, 0, 96, 175),
                          width: 5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.city.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // City stats
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ratingItem(
                              Icons.star,
                              Colors.amber.shade600,
                              '4.5',
                            ), //MOCK VALUE
                            ratingItem(
                              Icons.attractions,
                              Colors.deepPurpleAccent,
                              '4.5',
                            ), //MOCK VALUE
                            ratingItem(
                              Icons.people,
                              Colors.cyan.shade600,
                              '4.5',
                            ), //MOCK VALUE
                          ],
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: [
                            richTextBuilder(
                              'Visited by: ',
                              '${widget.city.numOfReviews} users',
                              responsiveFontSize(context, 18),
                            ),
                            const SizedBox(height: 16),
                            richTextBuilder(
                              'Wishlisted by: ',
                              '${widget.city.onWishlists} users',
                              responsiveFontSize(context, 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Main city content area
          Expanded(
            flex: 2,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          textBuilder(
                            '${widget.city.name}, ${widget.city.country}',
                            responsiveFontSize(context, 26),
                            FontWeight.bold,
                            color: Color.fromARGB(255, 0, 96, 175),
                          ),
                          textBuilder(
                            widget.city.description ?? '',
                            responsiveFontSize(context, 16),
                            FontWeight.normal,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    richTextBuilder(
                                      'Population: ',
                                      '${widget.city.population ?? 'N/A'}',
                                      responsiveFontSize(context, 16),
                                    ),
                                    richTextBuilder(
                                      'Currency: ',
                                      widget.city.currency ?? 'N/A',
                                      responsiveFontSize(context, 16),
                                    ),
                                    richTextBuilder(
                                      'Temperature: ',
                                      '${widget.city.temperature}°C',
                                      responsiveFontSize(context, 16),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    richTextBuilder(
                                      'Timezone: ',
                                      widget.city.timezone,
                                      responsiveFontSize(context, 16),
                                    ),
                                    richTextBuilder(
                                      'Language: ',
                                      widget.city.language ?? 'N/A',
                                      responsiveFontSize(context, 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(
                            thickness: 5,
                            color: Color.fromARGB(255, 0, 96, 175),
                          ),
                          textBuilder(
                            'Activities:',
                            responsiveFontSize(context, 18),
                            FontWeight.bold,
                            color: Color.fromARGB(255, 0, 96, 175),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: cardHeight,
                            child: activityProvider.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : activityProvider.activities.isEmpty
                                ? const Center(
                                    child: Text('No activities available'),
                                  )
                                : Builder(
                                    builder: (context) {
                                      final activities =
                                          activityProvider.activities;
                                      final maxCount = activities.length < 4
                                          ? activities.length
                                          : 4;

                                      return Row(
                                        children: [
                                          for (var i = 0; i < 4; i++)
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  right: i < 3 ? 12.0 : 0,
                                                ),
                                                child: i < maxCount
                                                    ? activityCard(
                                                        activities[i],
                                                      )
                                                    : const SizedBox.shrink(),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<CityProvider>().setSelectedCity(
                                  widget.city,
                                );
                                Navigator.pushNamed(
                                  context,
                                  '/city-activities',
                                );
                              },
                              child: const Text(
                                'View Activities',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const Divider(
                            thickness: 5,
                            color: Color.fromARGB(255, 0, 96, 175),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              textBuilder(
                                'Reviews:',
                                responsiveFontSize(context, 18),
                                FontWeight.bold,
                                color: Color.fromARGB(255, 0, 96, 175),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/leave-review',
                                    arguments: widget.city.name,
                                  );
                                },
                                icon: const Icon(Icons.rate_review),
                                label: const Text('Leave a review'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 0, 96, 175),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),

                          if (_isReviewsLoading)
                            const Center(child: CircularProgressIndicator())
                          else if (_reviews.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text(
                                  'No reviews yet. Be the first to leave one!',
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _reviews.length,
                              itemBuilder: (context, index) {
                                return reviewCard(_reviews[index]);
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  double responsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < 1200) return baseSize * (width / 1024);
    return baseSize * (width / 1440);
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
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.name,
                      maxLines: 3,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        fontSize: responsiveFontSize(context, 14),
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blue.shade100,
                backgroundImage: review.userPicture != null
                    ? NetworkImage(Api.getProxyImageUrl(review.userPicture!))
                    : null,
                child: review.userPicture == null
                    ? const Icon(Icons.person, size: 18, color: Colors.blue)
                    : null,
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
