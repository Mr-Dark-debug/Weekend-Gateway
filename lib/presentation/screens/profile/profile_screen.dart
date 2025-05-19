import 'package:flutter/material.dart';
import 'package:weekend_gateway/presentation/common/neo_button.dart';
import 'package:weekend_gateway/presentation/common/neo_card.dart';
import 'package:weekend_gateway/presentation/theme/app_theme.dart';
import 'package:weekend_gateway/config/supabase_config.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  
  const ProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late TabController _tabController;
  int _selectedTabIndex = 0;
  
  final Map<String, dynamic> _userData = {
    'name': 'Jane Traveler',
    'username': '@jane_travels',
    'location': 'New York, USA',
    'bio': 'Travel enthusiast and weekend explorer. Passionate about finding hidden gems in cities around the world.',
    'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1287',
    'trips': 12,
    'followers': 234,
    'following': 156,
  };
  
  final List<Map<String, dynamic>> _myCreatedItineraries = [
    {
      'title': 'London Weekend',
      'location': 'London, UK',
      'days': 2,
      'rating': 4.7,
      'image': 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?q=80&w=2070',
    },
    {
      'title': 'Berlin Art Tour',
      'location': 'Berlin, Germany',
      'days': 3,
      'rating': 4.5,
      'image': 'https://images.unsplash.com/photo-1528728329032-2972f65dfb3f?q=80&w=2070',
    },
  ];
  
  final List<Map<String, dynamic>> _mySavedItineraries = [
    {
      'title': 'Weekend in Paris',
      'location': 'Paris, France',
      'days': 3,
      'rating': 4.8,
      'image': 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?q=80&w=2073',
    },
    {
      'title': 'Barcelona Food Tour',
      'location': 'Barcelona, Spain',
      'days': 2,
      'rating': 4.6,
      'image': 'https://images.unsplash.com/photo-1583422409516-2895a77efded?q=80&w=2070',
    },
    {
      'title': 'Tokyo Adventure',
      'location': 'Tokyo, Japan',
      'days': 4,
      'rating': 4.9,
      'image': 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?q=80&w=2187',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    _loadUserData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    // Simulate loading data
    // In a real app, you would fetch user data from Supabase here
    setState(() {
      _isLoading = true;
    });
    
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _signOut() async {
    try {
      await SupabaseConfig.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('PROFILE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: _isLoading 
        ? Center(
            child: SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                color: AppTheme.primaryAccent,
                strokeWidth: 6,
              ),
            ),
          )
        : SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 24),
                      _buildStatistics(),
                      const SizedBox(height: 24),
                      _buildBio(),
                      const SizedBox(height: 24),
                      _buildItinerariesTabBar(),
                      const SizedBox(height: 16),
                      _buildItinerariesTabView(),
                      const SizedBox(height: 24),
                      _buildLogoutButton(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.primaryForeground,
              width: AppTheme.borderWidth,
            ),
            image: DecorationImage(
              image: NetworkImage(_userData['avatar']),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userData['name'],
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                _userData['username'],
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _userData['location'],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    final stats = [
      {'label': 'TRIPS', 'value': _userData['trips']},
      {'label': 'FOLLOWERS', 'value': _userData['followers']},
      {'label': 'FOLLOWING', 'value': _userData['following']},
    ];
    
    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.primaryForeground,
                width: AppTheme.borderWidth,
              ),
            ),
            child: Column(
              children: [
                Text(
                  stat['value'].toString(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  stat['label'],
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBio() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.primaryForeground,
          width: AppTheme.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BIO',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _userData['bio'],
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildItinerariesTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.primaryForeground,
          width: AppTheme.borderWidth,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryAccent,
        unselectedLabelColor: AppTheme.primaryForeground,
        indicatorColor: AppTheme.primaryAccent,
        indicatorWeight: AppTheme.borderWidth,
        tabs: const [
          Tab(text: 'CREATED'),
          Tab(text: 'SAVED'),
        ],
      ),
    );
  }
  
  Widget _buildItinerariesTabView() {
    return SizedBox(
      height: (_selectedTabIndex == 0 
          ? _myCreatedItineraries.length 
          : _mySavedItineraries.length) * 150.0,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildItinerariesList(_myCreatedItineraries),
          _buildItinerariesList(_mySavedItineraries),
        ],
      ),
    );
  }
  
  Widget _buildItinerariesList(List<Map<String, dynamic>> itineraries) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itineraries.length,
      itemBuilder: (context, index) {
        final itinerary = itineraries[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: NeoCard(
            onTap: () {
              // Navigate to itinerary details
              Navigator.pushNamed(
                context,
                '/trip-detail',
                arguments: itinerary['id'] ?? 'sample_id',
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
                      image: NetworkImage(itinerary['image']),
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              color: AppTheme.secondaryAccent,
                              child: Text(
                                '${itinerary['days']} DAYS',
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
                                  itinerary['rating'].toString(),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return NeoButton(
      onPressed: _signOut,
      color: AppTheme.primaryAccent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.logout, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            'LOG OUT',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
} 