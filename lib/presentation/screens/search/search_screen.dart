import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
// Remove geolocator and permission_handler imports for now
import 'package:weekend_gateway/presentation/common/neo_button.dart';
import 'package:weekend_gateway/presentation/common/neo_card.dart';
import 'package:weekend_gateway/presentation/theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _searchResults = [];
  
  // Location variables
  // Remove Position type
  bool _isLoadingLocation = false;
  String? _locationError;
  
  // Filter states
  int _selectedDays = 0; // 0 means "Any"
  String _selectedRegion = 'Any';
  double _minRating = 0.0;
  String _selectedPriceRange = 'Any';
  bool _nearbyOnly = false;
  
  final List<String> _regions = [
    'Any',
    'Europe',
    'Asia',
    'North America',
    'South America',
    'Africa',
    'Oceania',
  ];
  
  final List<String> _priceRanges = [
    'Any',
    'Budget',
    'Medium',
    'Luxury',
  ];
  
  @override
  void initState() {
    super.initState();
    _searchController.text = '';
    // Remove _getLocationPermission call
    _performSearch();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  // Simplified location handling - mock implementation for now
  Future<void> _getLocationPermission() async {
    // Mock implementation until we can install the proper packages
    setState(() {
      _locationError = 'Location services will be available in a future update';
    });
  }
  
  // Mock current location function
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });
    
    try {
      // Mock getting the position
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        // Mock position set
        _isLoadingLocation = false;
      });
      
      // Refresh search with location data if 'nearby only' is enabled
      if (_nearbyOnly) {
        _performSearch();
      }
    } catch (e) {
      setState(() {
        _locationError = 'Failed to get location: $e';
        _isLoadingLocation = false;
      });
    }
  }
  
  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mock search results with sample coordinates
    final List<Map<String, dynamic>> results = [
      {
        'id': '1',
        'title': 'Weekend in Paris',
        'location': 'Paris, France',
        'region': 'Europe',
        'author': 'Maria C.',
        'days': 3,
        'rating': 4.8,
        'price': 'Medium',
        'price_level': 2,
        'lat': 48.8566, // Paris coordinates
        'lng': 2.3522,
        'distance': 350, // Mocked distance in km
        'image': 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?q=80&w=2073',
      },
      {
        'id': '2',
        'title': 'Barcelona Food Tour',
        'location': 'Barcelona, Spain',
        'region': 'Europe',
        'author': 'Carlos M.',
        'days': 2,
        'rating': 4.6,
        'price': 'Budget',
        'price_level': 1,
        'lat': 41.3851, // Barcelona coordinates
        'lng': 2.1734,
        'distance': 980, // Mocked distance in km
        'image': 'https://images.unsplash.com/photo-1583422409516-2895a77efded?q=80&w=2070',
      },
      {
        'id': '3',
        'title': 'Tokyo Adventure',
        'location': 'Tokyo, Japan',
        'region': 'Asia',
        'author': 'Kenji T.',
        'days': 4,
        'rating': 4.9,
        'price': 'Luxury',
        'price_level': 3,
        'lat': 35.6762, // Tokyo coordinates
        'lng': 139.6503,
        'distance': 9500, // Mocked distance in km
        'image': 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?q=80&w=2187',
      },
      {
        'id': '4',
        'title': 'New York City Break',
        'location': 'New York, USA',
        'region': 'North America',
        'author': 'Alex S.',
        'days': 3,
        'rating': 4.7,
        'price': 'Medium',
        'price_level': 2,
        'lat': 40.7128, // New York coordinates
        'lng': -74.0060,
        'distance': 5800, // Mocked distance in km
        'image': 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?q=80&w=2070',
      },
      {
        'id': '5',
        'title': 'Sydney Weekend',
        'location': 'Sydney, Australia',
        'region': 'Oceania',
        'author': 'Emma T.',
        'days': 2,
        'rating': 4.5,
        'price': 'Luxury',
        'price_level': 3,
        'lat': -33.8688, // Sydney coordinates
        'lng': 151.2093,
        'distance': 12000, // Mocked distance in km
        'image': 'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?q=80&w=2070',
      },
      {
        'id': '6',
        'title': 'Local City Tour',
        'location': 'Chicago, USA',
        'region': 'North America',
        'author': 'Local Guide',
        'days': 1,
        'rating': 4.2,
        'price': 'Budget',
        'price_level': 1,
        'lat': 41.8781, // Chicago coordinates
        'lng': -87.6298,
        'distance': 50, // Mocked as nearby
        'image': 'https://images.unsplash.com/photo-1494522855154-9297ac14b55f?q=80&w=2070',
      },
    ];
    
    setState(() {
      _searchResults = results;
      
      // Apply filters
      if (_selectedDays > 0) {
        _searchResults = _searchResults.where((item) => item['days'] == _selectedDays).toList();
      }
      
      if (_selectedRegion != 'Any') {
        _searchResults = _searchResults.where((item) => item['region'] == _selectedRegion).toList();
      }
      
      if (_minRating > 0) {
        _searchResults = _searchResults.where((item) => (item['rating'] as double) >= _minRating).toList();
      }
      
      // Apply price range filter
      if (_selectedPriceRange != 'Any') {
        _searchResults = _searchResults.where((item) => item['price'] == _selectedPriceRange).toList();
      }
      
      // Apply nearby filter (within 100km)
      if (_nearbyOnly) {
        _searchResults = _searchResults.where((item) => (item['distance'] as int) <= 100).toList();
        
        // Show message if location services not available
        if (_locationError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_locationError ?? 'Location not available. Please enable location services.'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
      
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        _searchResults = _searchResults.where((item) {
          return item['title'].toString().toLowerCase().contains(query) ||
                 item['location'].toString().toLowerCase().contains(query);
        }).toList();
      }
      
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('SEARCH'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildFilters(),
            Expanded(
              child: _isLoading 
                ? const Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryAccent,
                        strokeWidth: 6,
                      ),
                    ),
                  )
                : _searchResults.isEmpty
                  ? _buildNoResults()
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.primaryBackground,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryForeground,
            width: AppTheme.borderWidth,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search destinations, activities...',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          const SizedBox(width: 12),
          NeoButton(
            onPressed: _performSearch,
            color: AppTheme.primaryAccent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: const Text(
              'SEARCH',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.primaryBackground,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryForeground,
            width: AppTheme.borderWidth,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FILTERS',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedDays = 0;
                    _selectedRegion = 'Any';
                    _minRating = 0.0;
                    _selectedPriceRange = 'Any';
                    _nearbyOnly = false;
                  });
                  _performSearch();
                },
                child: const Text('RESET'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildDaysFilter(),
                const SizedBox(width: 12),
                _buildRegionFilter(),
                const SizedBox(width: 12),
                _buildRatingFilter(),
                const SizedBox(width: 12),
                _buildPriceFilter(),
                const SizedBox(width: 12),
                _buildNearbyFilter(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDaysFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DAYS',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.primaryForeground,
              width: AppTheme.borderWidth,
            ),
          ),
          child: DropdownButton<int>(
            value: _selectedDays,
            underline: const SizedBox(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            items: [
              const DropdownMenuItem(value: 0, child: Text('Any')),
              ...List.generate(7, (index) => 
                DropdownMenuItem(value: index + 1, child: Text('${index + 1} days')),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedDays = value;
                });
                _performSearch();
              }
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildRegionFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REGION',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.primaryForeground,
              width: AppTheme.borderWidth,
            ),
          ),
          child: DropdownButton<String>(
            value: _selectedRegion,
            underline: const SizedBox(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            items: _regions.map((region) => 
              DropdownMenuItem(value: region, child: Text(region)),
            ).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedRegion = value;
                });
                _performSearch();
              }
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildRatingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MIN RATING',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.primaryForeground,
              width: AppTheme.borderWidth,
            ),
          ),
          child: DropdownButton<double>(
            value: _minRating,
            underline: const SizedBox(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            items: [
              const DropdownMenuItem(value: 0.0, child: Text('Any')),
              ...List.generate(5, (index) {
                final rating = index + 1.0;
                return DropdownMenuItem(
                  value: rating,
                  child: Row(
                    children: [
                      Text('$rating'),
                      const SizedBox(width: 4),
                      const Icon(Icons.star, size: 16),
                    ],
                  ),
                );
              }),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _minRating = value;
                });
                _performSearch();
              }
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRICE',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.primaryForeground,
              width: AppTheme.borderWidth,
            ),
          ),
          child: DropdownButton<String>(
            value: _selectedPriceRange,
            underline: const SizedBox(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            items: _priceRanges.map((price) => 
              DropdownMenuItem(value: price, child: Text(price)),
            ).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedPriceRange = value;
                });
                _performSearch();
              }
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildNearbyFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LOCATION',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(
              color: _nearbyOnly ? AppTheme.primaryAccent : AppTheme.primaryForeground,
              width: AppTheme.borderWidth,
            ),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _nearbyOnly = !_nearbyOnly;
                
                // If enabling nearby filter, show message
                if (_nearbyOnly) {
                  _getLocationPermission();
                }
              });
              _performSearch();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _isLoadingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primaryAccent,
                        ),
                      )
                    : Icon(
                        Icons.location_on,
                        size: 16,
                        color: _nearbyOnly ? AppTheme.primaryAccent : null,
                      ),
                  const SizedBox(width: 8),
                  Text(
                    'NEARBY ONLY',
                    style: TextStyle(
                      color: _nearbyOnly ? AppTheme.primaryAccent : null,
                      fontWeight: _nearbyOnly ? FontWeight.bold : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _nearbyOnly ? Icons.check_box : Icons.check_box_outline_blank,
                    size: 16,
                    color: _nearbyOnly ? AppTheme.primaryAccent : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64),
          const SizedBox(height: 16),
          Text(
            'NO RESULTS FOUND',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: NeoCard(
            onTap: () {
              Navigator.pushNamed(
                context, 
                '/trip-detail',
                arguments: result['id'],
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    border: const Border(
                      right: BorderSide(
                        color: AppTheme.primaryForeground,
                        width: AppTheme.borderWidth,
                      ),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(result['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result['title'],
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                result['location'],
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              color: AppTheme.secondaryAccent,
                              child: Text(
                                '${result['days']} DAYS',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: AppTheme.secondaryAccent,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  result['rating'].toString(),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Display price
                            Row(
                              children: [
                                const Icon(
                                  Icons.payments_outlined,
                                  size: 14,
                                  color: AppTheme.primaryForeground,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  result['price'],
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            // Display distance if less than 1000km
                            if ((result['distance'] as int) < 1000)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.near_me,
                                    size: 14,
                                    color: AppTheme.primaryAccent,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${result['distance']} km',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.primaryAccent,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'BY ${result['author']}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fade(
            duration: 300.ms, 
            delay: (100 * index).ms
          ).slideY(
            begin: 0.1, 
            end: 0,
            delay: (100 * index).ms
          ),
        );
      },
    );
  }
} 