import 'package:flutter/material.dart';
import 'package:frontend/models/topsight.dart';
import 'package:frontend/services/sights_service.dart';
import 'package:frontend/widgets/sight_card.dart'; // Assuming you saved the service here

class HorizontalSightsList extends StatefulWidget {
  final String cityId;

  const HorizontalSightsList({super.key, required this.cityId});

  @override
  State<HorizontalSightsList> createState() => _HorizontalSightsListState();
}

class _HorizontalSightsListState extends State<HorizontalSightsList> {
  final SightsService _sightsService = SightsService();
  late Future<List<CityTopSight>> _sightsFuture;

  @override
  void initState() {
    super.initState();
    // Fetch data once when the widget initializes
    _sightsFuture = _sightsService.fetchTopSights(widget.cityId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            "Top Sights",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 280, // Set a fixed height for the horizontal list
          child: FutureBuilder<List<CityTopSight>>(
            future: _sightsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No sights found.'));
              }

              final sights = snapshot.data!;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                itemCount: sights.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 200, // Fixed width for each card
                    margin: const EdgeInsets.only(right: 8.0),
                    child: SightCard(sight: sights[index]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
