import 'package:flutter/material.dart'; // Ensure Material is imported
import 'package:weekend_gateway/presentation/common/neo_button.dart';
import 'package:weekend_gateway/presentation/common/neo_text_field.dart';
import 'package:weekend_gateway/presentation/theme/app_theme.dart';
import 'package:weekend_gateway/services/ai_service.dart';
import 'package:weekend_gateway/models/trip_model.dart';
import 'package:weekend_gateway/services/trip_service.dart'; // For saving the trip
import 'package:weekend_gateway/config/supabase_config.dart'; // For current user ID
import 'package:weekend_gateway/presentation/screens/trip/trip_detail_screen.dart'; // For navigation
import 'package:weekend_gateway/presentation/common/neo_card.dart'; // For displaying trip details

class AIItineraryGeneratorScreen extends StatefulWidget {
  const AIItineraryGeneratorScreen({Key? key}) : super(key: key);

  @override
  State<AIItineraryGeneratorScreen> createState() => _AIItineraryGeneratorScreenState();
}

class _AIItineraryGeneratorScreenState extends State<AIItineraryGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();
  final _durationController = TextEditingController();
  final _interestsController = TextEditingController();
  String? _selectedBudget = 'mid-range';

  bool _isLoading = false;
  TripModel? _generatedTrip;
  final AIService _aiService = AIService();
  final TripService _tripService = TripService(); // For saving

  final List<String> _budgetOptions = ['budget', 'mid-range', 'luxury'];

  @override
  void dispose() {
    _destinationController.dispose();
    _durationController.dispose();
    _interestsController.dispose();
    super.dispose();
  }

  Future<void> _generateItinerary() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _generatedTrip = null;
      });

      final preferences = {
        'destination': _destinationController.text,
        'duration': int.tryParse(_durationController.text),
        'interests': _interestsController.text,
        'budget': _selectedBudget,
      };

      try {
        final rawResponse = await _aiService.generateItineraryRaw(preferences);
        final currentUserId = SupabaseConfig.client.auth.currentUser?.id;

        if (currentUserId == null) {
          throw Exception("User not logged in. Cannot save itinerary.");
        }
        
        final trip = _aiService.parseApiResponse(rawResponse, currentUserId);

        setState(() {
          _generatedTrip = trip;
          _isLoading = false;
        });

        if (trip == null) {
          if (!context.mounted) return;
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to parse AI response. Please try again.')),
          );
        }

      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating itinerary: $e')),
        );
      }
    }
  }

  Future<void> _saveGeneratedItinerary() async {
    if (_generatedTrip == null) return;

    final currentUserId = SupabaseConfig.client.auth.currentUser?.id;
    if (currentUserId == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to save itineraries.')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Use isLoading for saving process as well
    });

    try {
      // The AIService.parseApiResponse already sets the currentUserId to the TripModel
      // Prepare days data in the format createTripManual expects
      final List<Map<String, dynamic>> daysData = _generatedTrip!.tripDays.map((day) {
        return {
          'title': day.title, // Assuming TripDayModel has a title
          'day_number': day.dayNumber,
          'activities': day.activities.map((activity) {
            return {
              'title': activity.title,
              'description': activity.description,
              'location': activity.location, // This is location_name from AI
              'time': activity.time,
              // 'latitude': activity.latitude, // TODO: Fix this
              // 'longitude': activity.longitude, // TODO: Fix this
              // photo_urls will be empty by default from parseApiResponse
            };
          }).toList(),
        };
      }).toList();
      
      final savedTripId = await _tripService.createTripManual(_generatedTrip!, daysData);

      setState(() {
        _isLoading = false;
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI Itinerary saved successfully!')),
      );
      // Navigate to the new trip's detail screen
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TripDetailScreen(tripId: savedTripId)),
      );

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving itinerary: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('AI ITINERARY GENERATOR'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Let AI craft your next adventure!',
                 style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontFamily: 'RobotoMono'),
              ),
              const SizedBox(height: 24),
              NeoTextField(
                controller: _destinationController,
                hintText: 'E.g., Paris, Tokyo, Bali',
                decoration: const InputDecoration(labelText: 'Destination*'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a destination';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              NeoTextField(
                controller: _durationController,
                hintText: 'E.g., 3, 5, 7',
                decoration: const InputDecoration(labelText: 'Duration (days)*'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the duration';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid number of days';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              NeoTextField(
                controller: _interestsController,
                hintText: 'E.g., food, history, hiking, art',
                decoration: const InputDecoration(labelText: 'Interests*'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your interests';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                 decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.primaryForeground, width: AppTheme.borderWidth),
                  color: AppTheme.primaryBackground,
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedBudget,
                  decoration: const InputDecoration(
                    labelText: 'Budget*',
                    border: InputBorder.none, // Remove default underline
                    contentPadding: EdgeInsets.zero,
                  ),
                  items: _budgetOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value[0].toUpperCase() + value.substring(1)), // Capitalize first letter
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedBudget = newValue;
                    });
                  },
                  icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryForeground),
                  dropdownColor: AppTheme.primaryBackground,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontFamily: 'RobotoMono'),
                ),
              ),
              const SizedBox(height: 32),
              NeoButton(
                onPressed: _isLoading ? null : _generateItinerary,
                isLoading: _isLoading && _generatedTrip == null, // Show loading only during generation
                child: const Text('GENERATE ITINERARY'),
              ),
              const SizedBox(height: 24),
              if (_isLoading && _generatedTrip == null)
                const Center(child: CircularProgressIndicator()),
              if (_generatedTrip != null)
                _buildGeneratedItineraryReview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratedItineraryReview() {
    if (_generatedTrip == null) return const SizedBox.shrink();

    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REVIEW YOUR AI ITINERARY',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'RobotoMono'),
          ),
          const SizedBox(height: 16),
          Text('Title: ${_generatedTrip!.title}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Location: ${_generatedTrip!.location}', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text('Duration: ${_generatedTrip!.days} days', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text('Description: ${_generatedTrip!.description ?? "No description provided."}', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          // if (_generatedTrip!.latitude != null && _generatedTrip!.longitude != null) // TODO: Fix this
          //   Text('Coordinates: ${_generatedTrip!.latitude}, ${_generatedTrip!.longitude}', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
           Text('Price Level: ${_budgetOptions.firstWhere((b) => _getMockPriceLevel(b) == _generatedTrip!.priceLevel, orElse: () => "N/A").toUpperCase()}', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          Text('Itinerary Details:', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _generatedTrip!.tripDays.length,
            itemBuilder: (context, dayIndex) {
              final day = _generatedTrip!.tripDays[dayIndex];
              return ExpansionTile(
                initiallyExpanded: true,
                title: Text('Day ${day.dayNumber}: ${day.title}', style: Theme.of(context).textTheme.titleSmall),
                children: day.activities.map((activity) {
                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text(activity.title, style: Theme.of(context).textTheme.bodyLarge),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (activity.description != null) Text(activity.description!),
                        if (activity.location != null) Text('Location: ${activity.location}', style: Theme.of(context).textTheme.bodySmall),
                        if (activity.time != null) Text('Time: ${activity.time}', style: Theme.of(context).textTheme.bodySmall),
                         // if (activity.latitude != null && activity.longitude != null) // TODO: Fix this
                         //   Text('Coords: ${activity.latitude!.toStringAsFixed(4)}, ${activity.longitude!.toStringAsFixed(4)}', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 24),
          NeoButton(
            onPressed: _isLoading ? null : _saveGeneratedItinerary,
            isLoading: _isLoading && _generatedTrip != null, // Show loading for saving
            color: AppTheme.primaryAccent,
            child: const Text('SAVE ITINERARY'),
          ),
        ],
      ),
    );
  }
  
  // Helper from AIService to map budget string to price level integer for display
  int _getMockPriceLevel(String? budget) {
    switch (budget?.toLowerCase()) {
      case 'budget': return 1;
      case 'luxury': return 3;
      case 'mid-range': default: return 2;
    }
  }
}
