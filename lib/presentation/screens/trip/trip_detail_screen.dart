import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:weekend_gateway/config/supabase_config.dart';
import 'package:weekend_gateway/presentation/theme/app_theme.dart';
import 'package:weekend_gateway/presentation/common/neo_card.dart';
import 'package:weekend_gateway/presentation/common/neo_button.dart';
import 'package:weekend_gateway/presentation/common/neo_text_field.dart';

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
  
  final TextEditingController _commentController = TextEditingController();
  bool _isPostingComment = false;
  int _upvotes = 0;
  int _downvotes = 0;
  String? _userVote;
  
  @override
  void initState() {
    super.initState();
    _loadTripData();
  }
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  
  Future<void> _loadTripData() async {
    setState(() {
      _isLoading = true;
    });
    
    await Future.delayed(const Duration(milliseconds: 800));
    
    _tripData = {
      'id': widget.tripId,
      'title': 'Weekend in Paris',
      'location': 'Paris, France',
      'author': 'Maria C.',
      'authorAvatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1287',
      'rating': 4.8,
      'reviews': 24,
      'days': 3,
      'upvotes': 120,
      'downvotes': 8,
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
      'comments': [
        {
          'id': 'comment1',
          'user': 'Alex B.',
          'avatar': 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=687',
          'text': 'I followed this itinerary last summer and it was perfect! The Seine River Cruise was definitely the highlight.',
          'timestamp': '2023-08-15T14:30:00Z',
          'likes': 15,
        },
        {
          'id': 'comment2',
          'user': 'Sarah K.',
          'avatar': 'https://images.unsplash.com/photo-1580489944761-15a19d654956?q=80&w=1961',
          'text': 'Great guide but I would suggest spending more time at the Louvre. Two hours is not enough to see even the highlights!',
          'timestamp': '2023-09-03T09:15:00Z',
          'likes': 8,
        },
        {
          'id': 'comment3',
          'user': 'Marcus J.',
          'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1974',
          'text': 'The lunch recommendation at Café de Flore was spot on. Expensive but worth it for the experience.',
          'timestamp': '2023-10-22T18:45:00Z',
          'likes': 4,
        },
      ]
    };
    
    _upvotes = _tripData['upvotes'];
    _downvotes = _tripData['downvotes'];
    
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
  
  void _handleVote(String vote) {
    if (_userVote == vote) {
      setState(() {
        if (vote == 'up') {
          _upvotes--;
        } else {
          _downvotes--;
        }
        _userVote = null;
      });
    } 
    else if (_userVote != null) {
      setState(() {
        if (vote == 'up') {
          _upvotes++;
          _downvotes--;
        } else {
          _upvotes--;
          _downvotes++;
        }
        _userVote = vote;
      });
    }
    else {
      setState(() {
        if (vote == 'up') {
          _upvotes++;
        } else {
          _downvotes++;
        }
        _userVote = vote;
      });
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_userVote == null 
          ? 'Vote removed' 
          : _userVote == 'up' 
            ? 'Upvoted itinerary' 
            : 'Downvoted itinerary'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
  
  Future<void> _postComment() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;
    
    setState(() {
      _isPostingComment = true;
    });
    
    await Future.delayed(const Duration(seconds: 1));
    
    final newComment = {
      'id': 'comment${_tripData['comments'].length + 1}',
      'user': SupabaseConfig.currentUser?.email?.split('@').first ?? 'Anonymous',
      'avatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=1780',
      'text': comment,
      'timestamp': DateTime.now().toIso8601String(),
      'likes': 0,
    };
    
    setState(() {
      _tripData['comments'] = [newComment, ..._tripData['comments']];
      _commentController.clear();
      _isPostingComment = false;
    });
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
                  const SizedBox(height: 16),
                  _buildVotingSection(),
                  const SizedBox(height: 24),
                  _buildDescription(),
                  const SizedBox(height: 24),
                  _buildDaysList(),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                  const SizedBox(height: 32),
                  _buildCommentsSection(),
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
  
  Widget _buildVotingSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildVoteButton(
          icon: Icons.arrow_upward,
          count: _upvotes,
          isSelected: _userVote == 'up',
          onTap: () => _handleVote('up'),
          color: AppTheme.primaryAccent,
        ),
        const SizedBox(width: 32),
        _buildVoteButton(
          icon: Icons.arrow_downward,
          count: _downvotes,
          isSelected: _userVote == 'down',
          onTap: () => _handleVote('down'),
          color: Colors.grey.shade700,
        ),
      ],
    ).animate().fade(duration: 300.ms, delay: 400.ms);
  }
  
  Widget _buildVoteButton({
    required IconData icon,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            border: Border.all(
              color: isSelected ? color : AppTheme.primaryForeground,
              width: 2,
            ),
          ),
          child: IconButton(
            icon: Icon(icon),
            color: isSelected ? color : AppTheme.primaryForeground,
            onPressed: onTap,
            iconSize: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : AppTheme.primaryForeground,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COMMENTS (${_tripData['comments'].length})',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontFamily: 'RobotoMono',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: NeoTextField(
                controller: _commentController,
                hintText: 'Add a comment...',
                maxLines: 3,
              ),
            ),
            const SizedBox(width: 12),
            NeoButton(
              onPressed: _isPostingComment ? null : _postComment,
              isLoading: _isPostingComment,
              padding: const EdgeInsets.all(12),
              child: const Icon(Icons.send),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (_tripData['comments'].isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Be the first to comment!',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontStyle: FontStyle.italic,
                color: AppTheme.primaryForeground.withOpacity(0.7),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _tripData['comments'].length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final comment = _tripData['comments'][index];
              return _buildCommentItem(comment);
            },
          ),
      ],
    ).animate().fade(duration: 300.ms, delay: 800.ms);
  }
  
  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final DateTime timestamp = DateTime.parse(comment['timestamp']);
    final String formattedDate = '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryBackground,
        border: Border.all(
          color: AppTheme.primaryForeground.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(comment['avatar']),
              ),
              const SizedBox(width: 8),
              Text(
                comment['user'],
                style: const TextStyle(
                  fontFamily: 'RobotoMono',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                formattedDate,
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 12,
                  color: AppTheme.primaryForeground.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment['text'],
            style: const TextStyle(fontFamily: 'RobotoMono'),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.thumb_up_outlined,
                size: 14,
                color: AppTheme.primaryForeground.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Text(
                comment['likes'].toString(),
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 12,
                  color: AppTheme.primaryForeground.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'REPLY',
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 