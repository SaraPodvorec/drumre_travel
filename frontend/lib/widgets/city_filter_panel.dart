import 'package:flutter/material.dart';

class CityFilterPanel extends StatefulWidget {
  final Function(Map<String, dynamic>) onFiltersApplied;
  final VoidCallback onFiltersCleared;

  const CityFilterPanel({
    super.key,
    required this.onFiltersApplied,
    required this.onFiltersCleared,
  });

  @override
  State<CityFilterPanel> createState() => _CityFilterPanelState();
}

class _CityFilterPanelState extends State<CityFilterPanel> {
  String? selectedContinent;
  String? selectedCountry;
  String? selectedSortBy;
  String selectedOrder = 'asc';

  final List<String> continents = [
    'Europe',
    'Asia',
    'Africa',
    'North America',
    'South America',
    'Oceania',
  ];

  final Map<String, String> sortOptions = {
    'temperature': 'Temperature',
    'avgImpression': 'Rating',
    //'popularity': 'Popularity',
  };

  void _applyFilters() {
    final filters = <String, dynamic>{};
    
    if (selectedContinent != null) {
      filters['continent'] = selectedContinent;
    }
    
    if (selectedCountry != null && selectedCountry!.isNotEmpty) {
      filters['country'] = selectedCountry;
    }
    
    if (selectedSortBy != null) {
      filters['sort'] = selectedSortBy;
    }

    filters['order'] = selectedOrder;
    
    widget.onFiltersApplied(filters);
  }

  void _clearFilters() {
    setState(() {
      selectedContinent = null;
      selectedCountry = null;
      selectedSortBy = null;
      selectedOrder = 'asc';
    });
    widget.onFiltersCleared();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),
            
            // Continent Filter
            DropdownButtonFormField<String>(
              value: selectedContinent,
              decoration: const InputDecoration(
                labelText: 'Continent',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Continents'),
                ),
                ...continents.map((continent) {
                  return DropdownMenuItem(
                    value: continent,
                    child: Text(continent),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  selectedContinent = value;
                });
              },
            ),
            
            const SizedBox(height: 12),
            
            // Country Filter
            TextField(
              decoration: const InputDecoration(
                labelText: 'Country (e.g., Croatia, United States)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selectedCountry = value;
                });
              },
            ),
            
            const SizedBox(height: 12),
            
            // Sort By Filter
            DropdownButtonFormField<String>(
              value: selectedSortBy,
              decoration: const InputDecoration(
                labelText: 'Sort By',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Default'),
                ),
                ...sortOptions.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  selectedSortBy = value;
                });
              },
            ),
            
            const SizedBox(height: 12),
            
            // Sort Order
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Ascending'),
                    value: 'asc',
                    groupValue: selectedOrder,
                    onChanged: (value) {
                      setState(() {
                        selectedOrder = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Descending'),
                    value: 'desc',
                    groupValue: selectedOrder,
                    onChanged: (value) {
                      setState(() {
                        selectedOrder = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Icons.filter_alt),
                label: const Text('Apply Filters'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
