import 'package:flutter/material.dart';
import 'package:frontend/models/city.dart';
import 'package:frontend/models/review.dart';
import 'package:frontend/providers/activity_provider.dart';
import 'package:frontend/providers/city_provider.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/review_service.dart';
import 'package:frontend/widgets/main_app_bar.dart';
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
                              Icons.favorite,
                              Colors.red,
                              '4.5',
                            ), //MOCK VALUE
                            ratingItem(
                              Icons.attractions,
                              Colors.amber,
                              '4.5',
                            ), //MOCK VALUE
                            ratingItem(
                              Icons.people,
                              Colors.lightBlueAccent,
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
                          textBuilder(
                            'Reviews:',
                            responsiveFontSize(context, 18),
                            FontWeight.bold,
                            color: Color.fromARGB(255, 0, 96, 175),
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
                              shrinkWrap:
                                  true, 
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage: review.userPicture != null
                      ? NetworkImage(Api.getProxyImageUrl(review.userPicture!))
                      : null,
                  child: review.userPicture == null
                      ? const Icon(Icons.person, color: Colors.blue)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName ?? 'Anonymous',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatDate(review.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                _overallRating(review.impression),
              ],
            ),

            const SizedBox(height: 14),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ratingChip('👥 People', review.people),
                _ratingChip('🏛️ Sights', review.sights),
                _ratingChip('🛡️ Safety', review.safety),
                _ratingChip('💰 Cost', review.affordability),
              ],
            ),

            if (review.comments.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                review.comments,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _overallRating(int rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: List.generate(
          5,
          (i) => Icon(
            i < rating ? Icons.star : Icons.star_border,
            size: 16,
            color: Colors.amber,
          ),
        ),
      ),
    );
  }

  Widget _ratingChip(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Text(
            value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(width: 2),
          const Icon(Icons.star, size: 12, color: Colors.amber),
        ],
      ),
    );
  }
}
