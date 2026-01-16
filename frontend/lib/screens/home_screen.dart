import 'package:flutter/material.dart';
import 'package:frontend/providers/city_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/widgets/city_card.dart';
import 'package:provider/provider.dart';
import 'package:frontend/widgets/main_app_bar.dart';
import 'package:frontend/widgets/city_filter_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _searchQuery; 
  bool _showFilters = false;
  Map<String, dynamic> _activeFilters = {};

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
      int _calculateColumns(double width) {
      if (width >= 1900) return 5; // ultrawide
      if (width >= 1500) return 4; // 27"
      if (width >= 1200) return 3; // 24"
      if (width >= 600) return 2; // tablet
      return 1; // mobile
    }

  @override
  Widget build(BuildContext context) {
    final cityProvider = context.watch<CityProvider>();
    final userProvider = context.watch<UserProvider>();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final columns = _calculateColumns(screenWidth);

    var filteredCities = cityProvider.cities
        .where((city) => !userProvider.deletedCities.contains(city.id))
        .toList();

    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      filteredCities = filteredCities
          .where(
            (city) =>
                city.name.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
                city.country.toLowerCase().contains(
                  _searchQuery!.toLowerCase(),
                ),
          )
          .toList();
    }
      final horizontalPadding = screenWidth >= 1600
          ? 120.0
          : screenWidth >= 1200
              ? 80.0
              : screenWidth >= 800
                  ? 40.0
                  : 16.0;
    return Scaffold(
      appBar: const MainAppBar(title: 'Traveler Cities'),
      body:

      Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          0,
          horizontalPadding,
          25,
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
                          final city = await context
                              .read<CityProvider>()
                              .searchCity(value);
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
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                      label: const Text('Search'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showFilters = !_showFilters;
                        });
                      },
                      icon: Icon(
                        _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
                      ),
                      label: Text(
                        _showFilters ? 'Hide Filters' : 'Show Filters',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _activeFilters.isEmpty
                            ? null
                            : Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Panel
            if (_showFilters)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: CityFilterPanel(
                  onFiltersApplied: (filters) async {
                    setState(() {
                      _activeFilters = filters;
                    });
                    await context.read<CityProvider>().loadCitiesWithFilters(
                      filters,
                    );
                  },
                  onFiltersCleared: () async {
                    setState(() {
                      _activeFilters = {};
                    });
                    await context.read<CityProvider>().loadCities();
                  },
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
                      behavior: ScrollConfiguration.of(
                        context,
                      ).copyWith(scrollbars: false),
                      child: GridView.builder(
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              crossAxisSpacing: 15.0,
                              mainAxisSpacing: 15.0,
                              // mainAxisExtent: 430,
                              childAspectRatio: 0.8

                            ),
                        itemCount: filteredCities.length,
                        itemBuilder: (context, index) {
                          final city = filteredCities[index];

                          return CityCard(
                            city: city,
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
                              final isWishlisted = userProvider.wishlistCities
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
                                const SnackBar(content: Text('City hidden')),
                              );
                            },
                            onViewCityDetails: () {
                              context.read<CityProvider>().setSelectedCity(
                                city,
                              );
                              Navigator.pushNamed(context, '/city-details');
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
