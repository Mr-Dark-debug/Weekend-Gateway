import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  
  // Filter states
  int _selectedDays = 0; // 0 means "Any"
  String _selectedRegion = 'Any';
  double _minRating = 0.0;
  
  final List<String> _regions = [
    'Any',
    'Europe',
    'Asia',
    'North America',
    'South America',
    'Africa',
    'Oceania',
  ];
  
  @override
  void initState() {
    super.initState();
    _searchController.text = '';
    _performSearch();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mock search results
    setState(() {
      _searchResults = [
        {
          'id': '1',
          'title': 'Weekend in Paris',
          'location': 'Paris, France',
          'region': 'Europe',
          'author': 'Maria C.',
          'days': 3,
          'rating': 4.8,
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
          'image': 'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?q=80&w=2070',
        },
      ];
      
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
                ? Center(
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
      decoration: BoxDecoration(
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
      decoration: BoxDecoration(
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
                    border: Border(
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
                                Icon(
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