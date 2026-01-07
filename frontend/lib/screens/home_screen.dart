import 'package:flutter/material.dart';
import 'package:frontend/providers/city_provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/widgets/city_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _searchQuery; // Add this line

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CityProvider>().loadCities();
      context.read<UserProvider>().loadUserData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cityProvider = context.watch<CityProvider>();
    final authProvider = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();

    // update filteredCities to include search filtering
    var filteredCities = cityProvider.cities
        .where((city) => !userProvider.deletedCities.contains(city.id))
        .toList();

    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      filteredCities = filteredCities
          .where((city) =>
              city.name.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
              city.country.toLowerCase().contains(_searchQuery!.toLowerCase()))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Traveler Cities',
        ),
        actions: [
          if (authProvider.isAuthenticated && authProvider.userData != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Row(
                  children: [
                    if (authProvider.userData!['picture'] != null)
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          Api.getProxyImageUrl(
                            authProvider.userData!['picture'],
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Text(
                      authProvider.userData!['name'] ?? 'User',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    PopupMenuButton(
                      child: const Icon(Icons.more_vert, color: Colors.white),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Text('Profile'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },
                        ),
                        PopupMenuItem(
                          child: const Text('Logout'),
                          onTap: () async {
                            await authProvider.signOut();
                            if (context.mounted) {
                              Navigator.of(context)
                                  .pushReplacementNamed('/login');
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 100.0,
          right: 100.0,
          bottom: 25.0,
        ),
        child: Column(
          children: [
            // Search Box
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for a city...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = null;
                                    _searchController.clear();
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.isEmpty ? null : value;
                        });
                      },
                      onSubmitted: (value) async {
                        if (value.isNotEmpty) {
                          final city =
                              await context.read<CityProvider>().searchCity(value);
                          if (city != null) {
                            setState(() {
                              _searchQuery = value;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${city.name} added to list!'),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  cityProvider.error ?? 'Failed to find city',
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (_searchController.text.isNotEmpty) {
                          final city = await context
                              .read<CityProvider>()
                              .searchCity(_searchController.text);
                          if (city != null) {
                            setState(() {
                              _searchQuery = _searchController.text;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${city.name} added to list!'),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  cityProvider.error ?? 'Failed to find city',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      icon: cityProvider.isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.search),
                      label: const Text('Search'),
                    ),
                  ),
                ],
              ),
            ),
            // Cities Grid
            Expanded(
              child: cityProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredCities.isEmpty
                      ? const Center(
                          child: Text('No cities available. Try searching!'),
                        )
                      : ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context)
                              .copyWith(scrollbars: false),
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 15.0,
                              mainAxisSpacing: 15.0,
                              mainAxisExtent: 360,
                            ),
                            itemCount: filteredCities.length,
                            itemBuilder: (context, index) {
                              final city = filteredCities[index];

                              return CityCard(
                                city: city,
                                imageHeight: 220,
                                cardHeight: 340,
                                onFavoriteToggle: () {
                                  final isFavorite = userProvider.favoriteCities
                                      .contains(city.id);
                                  if (isFavorite) {
                                    userProvider.removeFavorite(city.id);
                                  } else {
                                    userProvider.addFavorite(city.id);
                                  }
                                },
                                onBookmarkToggle: () {
                                  final isWishlisted = userProvider
                                      .wishlistedCities
                                      .contains(city.id);
                                  if (isWishlisted) {
                                    userProvider.removeWishlist(city.id);
                                  } else {
                                    userProvider.addWishlist(city.id);
                                  }
                                },
                                onDelete: () {
                                  userProvider.deleteCity(city.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('City hidden')),
                                  );
                                },
                                onViewActivities: () {
                                  context.read<CityProvider>().setSelectedCity(
                                      city);
                                  Navigator.pushNamed(context,
                                      '/city-activities');
                                },
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}