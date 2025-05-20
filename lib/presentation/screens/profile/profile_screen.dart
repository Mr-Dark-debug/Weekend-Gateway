import 'package:flutter/material.dart';
import 'package:weekend_gateway/presentation/common/neo_button.dart';
import 'package:weekend_gateway/presentation/common/neo_card.dart';
import 'package:weekend_gateway/presentation/common/neo_text_field.dart';
import 'package:weekend_gateway/presentation/theme/app_theme.dart';
import 'package:weekend_gateway/config/supabase_config.dart';
import 'package:weekend_gateway/models/user_model.dart';
import 'package:weekend_gateway/models/trip_model.dart';
import 'package:weekend_gateway/services/user_service.dart';
import 'package:weekend_gateway/services/trip_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late TabController _tabController;
  int _selectedTabIndex = 0;

  final UserService _userService = UserService();
  final TripService _tripService = TripService();

  UserModel? _user;
  List<TripModel> _createdTrips = [];
  List<TripModel> _savedTrips = [];
  bool _isCurrentUser = false;
  bool _isFollowing = false;

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
    setState(() {
      _isLoading = true;
    });

    try {
      // Determine if we're viewing the current user's profile or someone else's
      final currentUserId = SupabaseConfig.client.auth.currentUser?.id;
      final targetUserId = widget.userId ?? currentUserId;

      if (targetUserId == null) {
        // Not logged in and no user ID provided
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      _isCurrentUser = targetUserId == currentUserId;

      // Load user data
      _user = await _userService.getUserById(targetUserId);

      if (_user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not found')),
          );
          Navigator.pop(context);
        }
        return;
      }

      // Check if current user is following this user
      if (!_isCurrentUser && currentUserId != null) {
        _isFollowing = await _userService.isFollowing(currentUserId, targetUserId);
      }

      // Load user's trips
      _createdTrips = await _tripService.getTripsCreatedByUser(targetUserId);
      _savedTrips = await _tripService.getTripsSavedByUser(targetUserId);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
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
        ? const Center(
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
        GestureDetector(
          onTap: _isCurrentUser ? _uploadProfileImage : null,
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.primaryForeground,
                    width: AppTheme.borderWidth,
                  ),
                  image: _user?.avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(_user!.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _user?.avatarUrl == null
                    ? const Center(child: Icon(Icons.person, size: 40))
                    : null,
              ),
              if (_isCurrentUser)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryAccent,
                      border: Border.all(
                        color: AppTheme.primaryForeground,
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _user?.fullName ?? 'User',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '@${_user?.username ?? 'username'}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              if (_user?.location != null)
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _user!.location!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              if (_isCurrentUser)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: NeoButton(
                    onPressed: _showEditProfileDialog,
                    color: AppTheme.primaryBackground,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.edit,
                          color: AppTheme.primaryForeground,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'EDIT PROFILE',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              if (!_isCurrentUser)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: NeoButton(
                    onPressed: _toggleFollow,
                    color: _isFollowing ? AppTheme.primaryBackground : AppTheme.primaryAccent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isFollowing ? Icons.person_remove : Icons.person_add,
                          color: _isFollowing ? AppTheme.primaryForeground : Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isFollowing ? 'UNFOLLOW' : 'FOLLOW',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: _isFollowing ? AppTheme.primaryForeground : Colors.white,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _toggleFollow() async {
    if (_user == null) return;

    final currentUserId = SupabaseConfig.client.auth.currentUser?.id;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to follow users')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isFollowing) {
        await _userService.unfollowUser(currentUserId, _user!.id);
      } else {
        await _userService.followUser(currentUserId, _user!.id);
      }

      setState(() {
        _isFollowing = !_isFollowing;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildStatistics() {
    final stats = [
      {'label': 'TRIPS', 'value': _createdTrips.length},
      {'label': 'FOLLOWERS', 'value': _user?.followerCount ?? 0},
      {'label': 'FOLLOWING', 'value': _user?.followingCount ?? 0},
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
                  stat['label'] as String,
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
            _user?.bio ?? 'No bio available.',
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
          ? _createdTrips.length
          : _savedTrips.length) * 150.0,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildItinerariesList(_createdTrips),
          _buildItinerariesList(_savedTrips),
        ],
      ),
    );
  }

  Widget _buildItinerariesList(List<TripModel> trips) {
    if (trips.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _selectedTabIndex == 0
                ? 'No created itineraries yet'
                : 'No saved itineraries yet',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: NeoCard(
            onTap: () {
              // Navigate to trip details
              Navigator.pushNamed(
                context,
                '/trip-detail',
                arguments: trip.id,
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
                    image: trip.coverImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(trip.coverImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: trip.coverImageUrl == null
                      ? const Center(child: Icon(Icons.image, size: 40))
                      : null,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.title,
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
                                trip.location,
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
                                '${trip.days} DAYS',
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
                                  trip.avgRating.toStringAsFixed(1),
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

  Future<void> _uploadProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      setState(() {
        _isLoading = true;
      });

      final File imageFile = File(image.path);
      final String fileExt = image.path.split('.').last;

      // Upload the image
      await _userService.uploadAvatar(imageFile, fileExt);

      // Refresh user data
      await _loadUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showEditProfileDialog() async {
    if (_user == null) return;

    final TextEditingController usernameController = TextEditingController(text: _user!.username);
    final TextEditingController fullNameController = TextEditingController(text: _user!.fullName ?? '');
    final TextEditingController bioController = TextEditingController(text: _user!.bio ?? '');
    final TextEditingController locationController = TextEditingController(text: _user!.location ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryBackground,
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Username', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  NeoTextField(
                    controller: usernameController,
                    hintText: 'Enter your username',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  NeoTextField(
                    controller: fullNameController,
                    hintText: 'Enter your full name',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bio', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  NeoTextField(
                    controller: bioController,
                    hintText: 'Tell us about yourself',
                    maxLines: 3,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  NeoTextField(
                    controller: locationController,
                    hintText: 'Where are you based?',
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          NeoButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateProfile(
                username: usernameController.text,
                fullName: fullNameController.text,
                bio: bioController.text,
                location: locationController.text,
              );
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );

    // Dispose controllers
    usernameController.dispose();
    fullNameController.dispose();
    bioController.dispose();
    locationController.dispose();
  }

  Future<void> _updateProfile({
    required String username,
    required String fullName,
    required String bio,
    required String location,
  }) async {
    if (_user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _userService.updateUserProfile({
        'username': username,
        'full_name': fullName,
        'bio': bio,
        'location': location,
      });

      // Refresh user data
      await _loadUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}