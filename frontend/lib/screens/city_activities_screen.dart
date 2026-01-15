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
      context.read<ActivityProvider>().loadActivities(
        widget.city.id,
        widget.city.lat,
        widget.city.lon,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = context.watch<ActivityProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50], 
      appBar: AppBar(
        title: Text('Activities in ${widget.city.name}'),
        centerTitle: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1200,
          ), 
          child: activityProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 700 ? 2 : 1;

                    return GridView.builder(
                      padding: const EdgeInsets.all(24.0),
                      itemCount: activityProvider.activities.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20, 
                        childAspectRatio: constraints.maxWidth > 700
                            ? 0.85
                            : 1.1,
                      ),
                      itemBuilder: (context, index) {
                        final activity = activityProvider.activities[index];
                        return _buildActivityCard(activity);
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(dynamic activity) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Positioned.fill(child: ImageSlider(images: activity.images)),
                Positioned(
                  top: 10,
                  right: 10,
                  child: _buildPriceBadge(activity),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        activity.minDuration.isNotEmpty
                            ? activity.minDuration
                            : 'Flexible',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Text(activity.description,
                  maxLines: 7,
                  overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13)),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _launchBookingLink(activity.bookingLink),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Book Now',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBadge(dynamic activity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade600,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${activity.priceAmount} ${activity.priceCurrency}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _launchBookingLink(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid booking link')));
      return;
    }

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open booking link')),
      );
    }
  }
}
