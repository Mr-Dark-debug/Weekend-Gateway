import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:weekend_gateway/presentation/theme/app_theme.dart';
import 'package:weekend_gateway/presentation/common/neo_card.dart';
import 'package:weekend_gateway/presentation/common/neo_button.dart';

class TripDetailScreen extends StatefulWidget {
  final String tripId;
  
  const TripDetailScreen({Key? key, required this.tripId}) : super(key: key);

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  bool _isLoading = false;
  late final Map<String, dynamic> _tripData;
  bool _isSaved = false;
  
  @override
  void initState() {
    super.initState();
    _loadTripData();
  }
  
  Future<void> _loadTripData() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate loading from API
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mock data
    _tripData = {
      'id': widget.tripId,
      'title': 'Weekend in Paris',
      'location': 'Paris, France',
      'author': 'Maria C.',
      'authorAvatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1287',
      'rating': 4.8,
      'reviews': 24,
      'days': 3,
      'coverImage': 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?q=80&w=2073',
      'description': 'A perfect 3-day itinerary to explore the best of Paris. From iconic landmarks to hidden gems, this guide will help you make the most of your weekend in the City of Light.',
      'days_details': [
        {
          'day': 1,
          'title': 'Classic Paris',
          'activities': [
            {
              'time': '09:00',
              'title': 'Eiffel Tower',
              'description': 'Start your day with a visit to the iconic Eiffel Tower. Get there early to avoid crowds.',
              'location': 'Champ de Mars, 5 Avenue Anatole France',
            },
            {
              'time': '12:30',
              'title': 'Lunch at Café de Flore',
              'description': 'Enjoy a classic French lunch at this historic café.',
              'location': '172 Bd Saint-Germain',
            },
            {
              'time': '14:00',
              'title': 'Louvre Museum',
              'description': 'Spend your afternoon exploring the world\'s largest art museum.',
              'location': 'Rue de Rivoli',
            },
            {
              'time': '19:00',
              'title': 'Seine River Cruise',
              'description': 'End your first day with a relaxing cruise along the Seine River.',
              'location': 'Pont de l\'Alma',
            },
          ],
        },
        {
          'day': 2,
          'title': 'Historic Paris',
          'activities': [
            {
              'time': '10:00',
              'title': 'Notre-Dame Cathedral',
              'description': 'Visit the famous Gothic cathedral (view from outside during reconstruction).',
              'location': '6 Parvis Notre-Dame - Pl. Jean-Paul II',
            },
            {
              'time': '12:00',
              'title': 'Lunch in Le Marais',
              'description': 'Try some traditional French food in this historic district.',
              'location': 'Le Marais district',
            },
            {
              'time': '14:00',
              'title': 'Musée d\'Orsay',
              'description': 'Explore this museum housed in a former railway station.',
              'location': '1 Rue de la Légion d\'Honneur',
            },
            {
              'time': '18:00',
              'title': 'Montmartre & Sacré-Cœur',
              'description': 'End your day with a visit to the artistic neighborhood and basilica.',
              'location': 'Montmartre',
            },
          ],
        },
        {
          'day': 3,
          'title': 'Hidden Gems',
          'activities': [
            {
              'time': '09:30',
              'title': 'Luxembourg Gardens',
              'description': 'Start your day with a peaceful walk through these beautiful gardens.',
              'location': '75006 Paris',
            },
            {
              'time': '11:30',
              'title': 'Saint-Germain-des-Prés',
              'description': 'Explore this charming neighborhood known for its cafés and boutiques.',
              'location': 'Saint-Germain-des-Prés',
            },
            {
              'time': '13:00',
              'title': 'Lunch at Marché des Enfants Rouges',
              'description': 'Have lunch at Paris\'s oldest food market.',
              'location': '39 Rue de Bretagne',
            },
            {
              'time': '15:00',
              'title': 'Centre Pompidou',
              'description': 'Visit this modern art museum with its distinctive architecture.',
              'location': 'Place Georges-Pompidou',
            },
          ],
        },
      ],
    };
    
    setState(() {
      _isLoading = false;
    });
  }
  
  void _toggleSaved() {
    setState(() {
      _isSaved = !_isSaved;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isSaved ? 'Saved to your itineraries' : 'Removed from your itineraries'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.primaryBackground,
        appBar: AppBar(
          title: const Text('TRIP DETAILS'),
        ),
        body: Center(
          child: SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: AppTheme.primaryAccent,
              strokeWidth: 6,
            ),
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTripHeader(),
                  const SizedBox(height: 24),
                  _buildDescription(),
                  const SizedBox(height: 24),
                  _buildDaysList(),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      pinned: true,
      backgroundColor: AppTheme.primaryBackground,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              _tripData['coverImage'],
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.primaryForeground,
                    width: AppTheme.borderWidth,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: _isSaved ? AppTheme.secondaryAccent : null,
          ),
          onPressed: _toggleSaved,
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // Share functionality
          },
        ),
      ],
    );
  }
  
  Widget _buildTripHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _tripData['title'],
          style: Theme.of(context).textTheme.displaySmall,
        ).animate().fade(duration: 300.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, size: 16),
            const SizedBox(width: 4),
            Text(
              _tripData['location'],
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ).animate().fade(duration: 300.ms, delay: 100.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 16),
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(_tripData['authorAvatar']),
            ),
            const SizedBox(width: 8),
            Text(
              'BY ${_tripData['author']}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            Icon(
              Icons.star,
              color: AppTheme.secondaryAccent,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              _tripData['rating'].toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(width: 8),
            Text(
              '(${_tripData['reviews']})',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ).animate().fade(duration: 300.ms, delay: 200.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.secondaryAccent,
            border: Border.all(
              color: AppTheme.primaryForeground,
              width: AppTheme.borderWidth,
            ),
          ),
          child: Text(
            '${_tripData['days']} DAYS',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ).animate().fade(duration: 300.ms, delay: 300.ms).slideY(begin: 0.2, end: 0),
      ],
    );
  }
  
  Widget _buildDescription() {
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
            'ABOUT THIS TRIP',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            _tripData['description'],
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    ).animate().fade(duration: 300.ms, delay: 400.ms);
  }
  
  Widget _buildDaysList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ITINERARY',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ...List.generate(_tripData['days_details'].length, (index) {
          final day = _tripData['days_details'][index];
          return _buildDayCard(day, index);
        }),
      ],
    ).animate().fade(duration: 300.ms, delay: 500.ms);
  }
  
  Widget _buildDayCard(Map<String, dynamic> day, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: NeoCard(
        variant: NeoCardVariant.header,
        headerTitle: 'DAY ${day['day']}: ${day['title']}',
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: day['activities'].length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, activityIndex) {
            final activity = day['activities'][activityIndex];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        color: AppTheme.primaryAccent,
                        child: Text(
                          activity['time'],
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity['title'],
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activity['description'],
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    activity['location'],
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ).animate().fade(
      duration: 400.ms, 
      delay: (100 * index + 600).ms
    ).slideY(
      begin: 0.2,
      end: 0,
      delay: (100 * index + 600).ms
    );
  }
  
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: NeoButton(
            onPressed: () {
              // Save for later
              _toggleSaved();
            },
            color: _isSaved ? AppTheme.secondaryAccent : AppTheme.primaryBackground,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: _isSaved ? AppTheme.primaryForeground : AppTheme.primaryForeground,
                ),
                const SizedBox(width: 8),
                Text(
                  _isSaved ? 'SAVED' : 'SAVE',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: NeoButton(
            onPressed: () {
              // Start trip
            },
            color: AppTheme.primaryAccent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.directions_walk, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'START TRIP',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fade(duration: 300.ms, delay: 700.ms);
  }
} 