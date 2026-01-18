import 'package:flutter/material.dart';
import 'package:frontend/models/city.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/screens/city_details_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/widgets/city_card.dart';
import 'package:provider/provider.dart';

class RecommendedCitiesList extends StatefulWidget {
  const RecommendedCitiesList({super.key, required this.userId});

  final String userId;

  @override
  State<RecommendedCitiesList> createState() => _RecommendedCitiesListState();
}

class _RecommendedCitiesListState extends State<RecommendedCitiesList> {
  late Future<List<City>> _citiesFuture;

  @override
  void initState() {
    super.initState();
    _citiesFuture = fetchRecommendedCities();
  }

  Future<List<City>> fetchRecommendedCities() async {
    final res = await Api.getRequest('/recommendations/${widget.userId}');
    return (res as List).map((cityJson) => City.fromJson(cityJson)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return FutureBuilder<List<City>>(
      future: _citiesFuture, // use the cached future
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final citiesData = snapshot.data ?? [];

        if (citiesData.isEmpty) {
          return const Center(child: Text("No recommended cities yet"));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 20),
          itemCount: citiesData.length,
          itemBuilder: (context, index) {
            final city = citiesData[index];
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: CityCard(
                    city: city,
                    onViewCityDetails: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CityDetailsScreen(city: city),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

