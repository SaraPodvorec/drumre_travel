import 'package:flutter/material.dart';
import 'package:frontend/models/city.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/widgets/city_card.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class RecommendedCitiesScreen extends StatelessWidget {
  const RecommendedCitiesScreen({super.key});

  Future<List<City>> fetchRecommendedCities(String userId) async {
    final res = await Api.getRequest('/recommendations/$userId');
    return (res as List).map((cityJson) => City.fromJson(cityJson)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    if (userProvider.isLoading && !userProvider.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userId = userProvider.currentUserId;

    return Scaffold(
      appBar: AppBar(title: const Text('Explore Cities'), centerTitle: true),
      body: userId == null
          ? const Center(child: Text("User not logged in"))
          : FutureBuilder<List<City>>(
              future: fetchRecommendedCities(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final citiesData = snapshot.data ?? [];

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  itemCount: citiesData.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: CityCard(city: citiesData[index]),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
