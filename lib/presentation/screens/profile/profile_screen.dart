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

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
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
  
  final List<Map<String, dynamic>> _myItineraries = [
    {
      'title': 'London Weekend',
      'location': 'London, UK',
      'days': 2,
      'image': 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?q=80&w=2070',
    },
    {
      'title': 'Berlin Art Tour',
      'location': 'Berlin, Germany',
      'days': 3,
      'image': 'https://images.unsplash.com/photo-1528728329032-2972f65dfb3f?q=80&w=2070',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 24),
                _buildStatistics(),
                const SizedBox(height: 24),
                _buildBio(),
                const SizedBox(height: 24),
                _buildMyItineraries(),
                const SizedBox(height: 24),
                _buildLogoutButton(),
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

  Widget _buildMyItineraries() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MY ITINERARIES',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                // View all itineraries
              },
              child: const Text('SEE ALL'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _myItineraries.length,
          itemBuilder: (context, index) {
            final itinerary = _myItineraries[index];
            return NeoCard(
              onTap: () {
                // Navigate to itinerary details
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 100,
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
                          style: Theme.of(context).textTheme.labelLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          itinerary['location'],
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${itinerary['days']} DAYS',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
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