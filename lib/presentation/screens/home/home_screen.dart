import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:weekend_gateway/config/app_routes.dart';
import 'package:weekend_gateway/config/supabase_config.dart';
import 'package:weekend_gateway/presentation/common/neo_button.dart';
import 'package:weekend_gateway/presentation/common/neo_card.dart';
import 'package:weekend_gateway/presentation/screens/search/search_screen.dart';
import 'package:weekend_gateway/presentation/screens/trip/create_trip_screen.dart';
import 'package:weekend_gateway/presentation/screens/profile/profile_screen.dart';
import 'package:weekend_gateway/presentation/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const _HomeContent(),
      const SearchScreen(),
      const CreateTripScreen(),
      const ProfileScreen(),
    ];
  }

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
        title: _buildAppBarTitle(),
        actions: _buildAppBarActions(),
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryAccent,
        unselectedItemColor: AppTheme.primaryForeground.withOpacity(0.7),
        backgroundColor: AppTheme.primaryBackground,
        selectedLabelStyle: const TextStyle(fontFamily: 'RobotoMono', fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontFamily: 'RobotoMono'),
      ),
    );
  }

  Widget _buildAppBarTitle() {
    String title;
    switch (_currentIndex) {
      case 0:
        title = 'WEEKEND GATEWAY';
        break;
      case 1:
        title = 'EXPLORE';
        break;
      case 2:
        title = 'CREATE ITINERARY';
        break;
      case 3:
        title = 'PROFILE';
        break;
      default:
        title = 'WEEKEND GATEWAY';
    }
    return Text(title, style: const TextStyle(fontFamily: 'RobotoMono', fontWeight: FontWeight.bold));
  }

  List<Widget>? _buildAppBarActions() {
    if (_currentIndex == 0) {
      return [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _currentIndex = 1;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.account_circle_outlined),
          onPressed: () {
            setState(() {
              _currentIndex = 3;
            });
          },
        ),
      ];
    }
    return null; 
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({Key? key}) : super(key: key);

  static final List<Map<String, dynamic>> _itineraries = [
    {
      'id': 'paris123',
      'title': 'Weekend in Paris',
      'author': 'Maria C.',
      'location': 'Paris, France',
      'days': 3,
      'rating': 4.8,
      'price': 'Medium',
      'price_level': 2, // 1=Budget, 2=Medium, 3=Luxury
      'image': 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?q=80&w=2073',
    },
    {
      'id': 'barca456',
      'title': 'Barcelona Food Tour',
      'author': 'Carlos M.',
      'location': 'Barcelona, Spain',
      'days': 2,
      'rating': 4.6,
      'price': 'Budget',
      'price_level': 1,
      'image': 'https://images.unsplash.com/photo-1583422409516-2895a77efded?q=80&w=2070',
    },
    {
      'id': 'tokyo789',
      'title': 'Tokyo Adventure',
      'author': 'Kenji T.',
      'location': 'Tokyo, Japan',
      'days': 4,
      'rating': 4.9,
      'price': 'Luxury',
      'price_level': 3,
      'image': 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?q=80&w=2187',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildWelcomeSection(context),
          const SizedBox(height: 24),
          _buildFeaturedItineraries(context),
          const SizedBox(height: 24),
          _buildPopularDestinations(context),
          const SizedBox(height: 24),
          _buildCreateItineraryButton(context),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
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
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontFamily: 'RobotoMono', color: AppTheme.primaryForeground),
          ),
          const SizedBox(height: 8),
          Text(
            'WHERE TO THIS WEEKEND?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontFamily: 'RobotoMono', color: AppTheme.primaryForeground),
          ),
          const SizedBox(height: 16),
          TextField(
            style: const TextStyle(fontFamily: 'RobotoMono'),
            decoration: InputDecoration(
              hintText: 'Search destinations',
              hintStyle: TextStyle(fontFamily: 'RobotoMono', color: AppTheme.primaryForeground.withOpacity(0.7)),
              prefixIcon: Icon(Icons.search, color: AppTheme.primaryForeground),
              filled: true,
              fillColor: AppTheme.primaryBackground,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.primaryForeground, width: AppTheme.borderWidth),
                borderRadius: BorderRadius.zero,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.primaryAccent, width: AppTheme.borderWidth),
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 300.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildFeaturedItineraries(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'FEATURED ITINERARIES',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'RobotoMono', fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.search);
              },
              child: Text('SEE ALL', style: TextStyle(fontFamily: 'RobotoMono', color: AppTheme.primaryAccent, fontWeight: FontWeight.bold)),
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
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontFamily: 'RobotoMono', fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: AppTheme.primaryForeground),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    itinerary['location'],
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: 'RobotoMono'),
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
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontFamily: 'RobotoMono',
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
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: 'RobotoMono'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'BY ${itinerary['author']}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'RobotoMono'),
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

  Widget _buildPopularDestinations(BuildContext context) {
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'RobotoMono', fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: destinations.map((destination) {
            return InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tapped on ${destination['name']}')),
                );
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
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontFamily: 'RobotoMono', fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${destination['count']} ITINERARIES',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'RobotoMono'),
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

  Widget _buildCreateItineraryButton(BuildContext context) {
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