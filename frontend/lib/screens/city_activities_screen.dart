import 'package:flutter/material.dart';
import 'package:frontend/models/city.dart';
import 'package:frontend/providers/activity_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/widgets/image_slider.dart';
import 'package:url_launcher/url_launcher.dart';

class CityActivitiesScreen extends StatefulWidget {
  final City city;
  const CityActivitiesScreen({super.key, required this.city});

  @override
  State<CityActivitiesScreen> createState() => _CityActivitiesScreenState();
}

class _CityActivitiesScreenState extends State<CityActivitiesScreen> {

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityProvider>().loadActivities(widget.city.id, widget.city.lat, widget.city.lon);
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final activityProvider = context.watch<ActivityProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Tours & Activities in ${widget.city.name}'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 250.0, vertical: 16.0),
        child: activityProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
          itemCount: activityProvider.activities.length,
          itemBuilder: (context, index) {
            final activity = activityProvider.activities[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image slider
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12.0),
                      topRight: Radius.circular(12.0),
                    ),
                    child: ImageSlider(images: activity.images),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          activity.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Description
                        Text(
                          activity.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Price and duration row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Price
                            Row(
                              children: [
                                const Icon(Icons.attach_money, size: 18, color: Colors.green),
                                Text(
                                  '${activity.priceAmount} ${activity.priceCurrency}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            // Duration
                            activity.minDuration.isNotEmpty ?
                            Row(
                              children: [
                                const Icon(Icons.schedule, size: 18, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text(
                                  activity.minDuration,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ) : const SizedBox.shrink(),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Book button
                        ElevatedButton.icon(
                          onPressed: () => _launchBookingLink(activity.bookingLink),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.all(16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.bookmark, color: Colors.white),
                          label: const Text(
                            'Book Now',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _launchBookingLink(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid booking link')),
      );
      return;
    }

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open booking link')),
      );
    }
  }
}