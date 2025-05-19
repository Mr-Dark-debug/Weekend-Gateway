import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:weekend_gateway/config/app_routes.dart';
import 'package:weekend_gateway/config/supabase_config.dart';
import 'package:weekend_gateway/presentation/common/neo_button.dart';
import 'package:weekend_gateway/presentation/common/neo_card.dart';
import 'package:weekend_gateway/presentation/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _itineraries = [
    {
      'id': 'paris123',
      'title': 'Weekend in Paris',
      'author': 'Maria C.',
      'location': 'Paris, France',
      'days': 3,
      'rating': 4.8,
      'image': 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?q=80&w=2073',
    },
    {
      'id': 'barca456',
      'title': 'Barcelona Food Tour',
      'author': 'Carlos M.',
      'location': 'Barcelona, Spain',
      'days': 2,
      'rating': 4.6,
      'image': 'https://images.unsplash.com/photo-1583422409516-2895a77efded?q=80&w=2070',
    },
    {
      'id': 'tokyo789',
      'title': 'Tokyo Adventure',
      'author': 'Kenji T.',
      'location': 'Tokyo, Japan',
      'days': 4,
      'rating': 4.9,
      'image': 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?q=80&w=2187',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('WEEKEND GATEWAY'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.search);
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 24),
            _buildFeaturedItineraries(),
            const SizedBox(height: 24),
            _buildPopularDestinations(),
            const SizedBox(height: 24),
            _buildCreateItineraryButton(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              // Already on Home, or Navigator.pushNamed(context, AppRoutes.home);
              break;
            case 1: // Explore
              Navigator.pushNamed(context, AppRoutes.search);
              break;
            case 2: // Saved
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved screen coming soon!')),
              );
              break;
            case 3: // Settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings screen coming soon!')),
              );
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryAccent,
        unselectedItemColor: AppTheme.primaryForeground.withOpacity(0.6),
        backgroundColor: AppTheme.primaryBackground,
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final userName = SupabaseConfig.currentUser?.email?.split('@').first ?? 'Traveler';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryAccent,
        border: Border.all(
          color: AppTheme.primaryForeground,
          width: AppTheme.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HI, ${userName.toUpperCase()}!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'WHERE TO THIS WEEKEND?',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search destinations',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fade(duration: 300.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildFeaturedItineraries() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'FEATURED ITINERARIES',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.search);
              },
              child: const Text('SEE ALL'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _itineraries.length,
            itemBuilder: (context, index) {
              final itinerary = _itineraries[index];
              return Container(
                width: 260,
                margin: const EdgeInsets.only(right: 16),
                child: NeoCard(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.tripDetail,
                      arguments: itinerary['id'],
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppTheme.primaryForeground,
                              width: AppTheme.borderWidth,
                            ),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(itinerary['image']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              itinerary['title'],
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
                                    itinerary['location'],
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
                                Text(
                                  '${itinerary['days']} DAYS',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.star, 
                                      color: AppTheme.secondaryAccent,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      itinerary['rating'].toString(),
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'BY ${itinerary['author']}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fade(
                duration: 400.ms, 
                delay: (100 * index).ms
              ).slideX(
                begin: 0.2, 
                end: 0,
                delay: (100 * index).ms
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularDestinations() {
    final destinations = [
      {'name': 'New York', 'count': 24},
      {'name': 'Tokyo', 'count': 18},
      {'name': 'London', 'count': 15},
      {'name': 'Bali', 'count': 12},
      {'name': 'Paris', 'count': 10},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'POPULAR DESTINATIONS',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: destinations.map((destination) {
            return InkWell(
              onTap: () {
                // Navigate to destination
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBackground,
                  border: Border.all(
                    color: AppTheme.primaryForeground,
                    width: AppTheme.borderWidth,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination['name'] as String,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${destination['count']} ITINERARIES',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCreateItineraryButton() {
    return NeoButton(
      onPressed: () {
        Navigator.pushNamed(context, AppRoutes.createTrip);
      },
      color: AppTheme.primaryAccent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add),
          const SizedBox(width: 8),
          Text(
            'CREATE ITINERARY',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
} 