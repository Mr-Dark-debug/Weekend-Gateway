import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:weekend_gateway/config/supabase_config.dart';
import 'package:weekend_gateway/models/trip_model.dart';
import 'package:weekend_gateway/models/trip_day_model.dart';
import 'package:weekend_gateway/models/trip_activity_model.dart';
import 'package:weekend_gateway/models/trip_comment_model.dart';
import 'package:weekend_gateway/models/user_model.dart';
import 'package:weekend_gateway/services/trip_service.dart';
import 'package:weekend_gateway/presentation/screens/profile/profile_screen.dart';
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
  bool _isLoading = true;
  TripModel? _trip;
  bool _isSaved = false;

  final TripService _tripService = TripService();
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

    try {
      // Load trip data from Supabase
      final trip = await _tripService.getTripById(widget.tripId);

      // Check if the current user has saved this trip
      final currentUserId = SupabaseConfig.client.auth.currentUser?.id;
      if (currentUserId != null) {
        _isSaved = trip.isSavedByCurrentUser;
      }

      // Set upvotes and downvotes (placeholder for now)
      _upvotes = 120;
      _downvotes = 8;

      setState(() {
        _trip = trip;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading trip: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleSaved() async {
    if (_trip == null) return;

    try {
      final currentUserId = SupabaseConfig.client.auth.currentUser?.id;
      if (currentUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to be logged in to save trips')),
        );
        return;
      }

      final result = await _tripService.toggleSaveTrip(_trip!.id, currentUserId);

      setState(() {
        _isSaved = result;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isSaved ? 'Saved to your itineraries' : 'Removed from your itineraries'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
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
    if (_trip == null) return;

    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    setState(() {
      _isPostingComment = true;
    });

    try {
      final currentUserId = SupabaseConfig.client.auth.currentUser?.id;
      if (currentUserId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You need to be logged in to comment')),
          );
        }
        setState(() {
          _isPostingComment = false;
        });
        return;
      }

      // Add comment to database
      final newComment = await _tripService.addComment(
        _trip!.id,
        currentUserId,
        comment,
      );

      // Update local trip model with new comment
      setState(() {
        _trip = _trip!.copyWith(
          comments: [newComment, ..._trip!.comments],
        );
        _commentController.clear();
        _isPostingComment = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error posting comment: $e')),
        );
        setState(() {
          _isPostingComment = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.primaryBackground,
        appBar: AppBar(
          title: const Text('TRIP DETAILS'),
        ),
        body: const Center(
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

    if (_trip == null) {
      return Scaffold(
        backgroundColor: AppTheme.primaryBackground,
        appBar: AppBar(
          title: const Text('TRIP DETAILS'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text(
                'Trip not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
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
              _trip!.coverImageUrl ?? 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?q=80&w=2073',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppTheme.primaryBackground,
                child: const Center(
                  child: Icon(Icons.image_not_supported, size: 48),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
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
          onPressed: () => _toggleSaved(),
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // Share functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sharing is not implemented yet')),
            );
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
          _trip!.title,
          style: Theme.of(context).textTheme.displaySmall,
        ).animate().fade(duration: 300.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, size: 16),
            const SizedBox(width: 4),
            Text(
              _trip!.location,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ).animate().fade(duration: 300.ms, delay: 100.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 16),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                if (_trip!.author != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(userId: _trip!.author!.id),
                    ),
                  );
                }
              },
              child: CircleAvatar(
                radius: 16,
                backgroundImage: _trip!.author?.avatarUrl != null
                    ? NetworkImage(_trip!.author!.avatarUrl!)
                    : null,
                child: _trip!.author?.avatarUrl == null
                    ? const Icon(Icons.person, size: 16)
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                if (_trip!.author != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(userId: _trip!.author!.id),
                    ),
                  );
                }
              },
              child: Text(
                'BY ${_trip!.author?.username ?? 'Unknown'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.star,
              color: AppTheme.secondaryAccent,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              _trip!.avgRating.toStringAsFixed(1),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(width: 8),
            Text(
              '(${_trip!.ratingCount})',
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
            '${_trip!.days} DAYS',
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
            _trip!.description ?? 'No description available.',
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
        if (_trip!.tripDays.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.primaryForeground,
                width: AppTheme.borderWidth,
              ),
            ),
            child: const Center(
              child: Text('No itinerary details available.'),
            ),
          )
        else
          ...List.generate(_trip!.tripDays.length, (index) {
            final day = _trip!.tripDays[index];
            return _buildDayCard(day, index);
          }),
      ],
    ).animate().fade(duration: 300.ms, delay: 500.ms);
  }

  Widget _buildDayCard(TripDayModel day, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: NeoCard(
        variant: NeoCardVariant.header,
        headerTitle: 'DAY ${day.dayNumber}: ${day.title}',
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: day.activities.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, activityIndex) {
            final activity = day.activities[activityIndex];
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
                          activity.time ?? 'N/A',
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
                              activity.title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            if (activity.description != null)
                              Text(
                                activity.description!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            if (activity.description != null)
                              const SizedBox(height: 4),
                            if (activity.location != null)
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 14),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      activity.location!,
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
            color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
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
          'COMMENTS (${_trip!.comments.length})',
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
        if (_trip!.comments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Be the first to comment!',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontStyle: FontStyle.italic,
                color: AppTheme.primaryForeground.withValues(alpha: 0.7),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _trip!.comments.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final comment = _trip!.comments[index];
              return _buildCommentItem(comment);
            },
          ),
      ],
    ).animate().fade(duration: 300.ms, delay: 800.ms);
  }

  Widget _buildCommentItem(TripCommentModel comment) {
    final DateTime timestamp = comment.createdAt;
    final String formattedDate = '${timestamp.day}/${timestamp.month}/${timestamp.year}';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryBackground,
        border: Border.all(
          color: AppTheme.primaryForeground.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (comment.user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(userId: comment.user!.id),
                      ),
                    );
                  }
                },
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: comment.user?.avatarUrl != null
                      ? NetworkImage(comment.user!.avatarUrl!)
                      : null,
                  child: comment.user?.avatarUrl == null
                      ? const Icon(Icons.person, size: 16)
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  if (comment.user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(userId: comment.user!.id),
                      ),
                    );
                  }
                },
                child: Text(
                  comment.user?.username ?? 'Unknown',
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                formattedDate,
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 12,
                  color: AppTheme.primaryForeground.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment.content,
            style: const TextStyle(fontFamily: 'RobotoMono'),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.thumb_up_outlined,
                size: 14,
                color: AppTheme.primaryForeground.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                '0', // Placeholder for likes count
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 12,
                  color: AppTheme.primaryForeground.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
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