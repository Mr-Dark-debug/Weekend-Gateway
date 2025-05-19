import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:weekend_gateway/presentation/common/neo_button.dart';
import 'package:weekend_gateway/presentation/common/neo_card.dart';
import 'package:weekend_gateway/presentation/theme/app_theme.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({Key? key}) : super(key: key);

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _selectedDays = 1;
  bool _isPublic = true;
  bool _isLoading = false;
  
  final List<Map<String, dynamic>> _activities = [];
  
  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  void _addActivity() {
    setState(() {
      _activities.add({
        'day': 1,
        'time': '09:00',
        'title': '',
        'description': '',
        'location': '',
      });
    });
  }
  
  void _removeActivity(int index) {
    setState(() {
      _activities.removeAt(index);
    });
  }
  
  void _updateActivity(int index, String field, dynamic value) {
    setState(() {
      _activities[index][field] = value;
    });
  }
  
  Future<void> _createTrip() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Itinerary created successfully!')),
        );
        
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('CREATE ITINERARY'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildBasicInfo(),
              const SizedBox(height: 24),
              _buildDaySelection(),
              const SizedBox(height: 24),
              _buildActivities(),
              const SizedBox(height: 24),
              _buildPrivacySettings(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBasicInfo() {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BASIC INFORMATION',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'e.g., Weekend in Paris',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location',
              hintText: 'e.g., Paris, France',
              prefixIcon: Icon(Icons.location_on),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a location';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Describe your itinerary...',
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
        ],
      ),
    ).animate().fade(duration: 300.ms).slideY(begin: 0.2, end: 0);
  }
  
  Widget _buildDaySelection() {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOW MANY DAYS?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(7, (index) {
              final day = index + 1;
              final isSelected = _selectedDays == day;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDays = day;
                  });
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.secondaryAccent : AppTheme.primaryBackground,
                    border: Border.all(
                      color: AppTheme.primaryForeground,
                      width: AppTheme.borderWidth,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      day.toString(),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    ).animate().fade(duration: 300.ms, delay: 100.ms).slideY(begin: 0.2, end: 0);
  }
  
  Widget _buildActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ACTIVITIES',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            NeoButton(
              onPressed: _addActivity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add),
                  const SizedBox(width: 4),
                  Text(
                    'ADD',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_activities.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.primaryForeground,
                width: AppTheme.borderWidth,
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.add_circle_outline, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'NO ACTIVITIES YET',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add some activities to your itinerary',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ...List.generate(_activities.length, (index) {
          return _buildActivityCard(index);
        }),
      ],
    ).animate().fade(duration: 300.ms, delay: 200.ms).slideY(begin: 0.2, end: 0);
  }
  
  Widget _buildActivityCard(int index) {
    final activity = _activities[index];
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: NeoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'ACTIVITY ${index + 1}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: AppTheme.primaryAccent,
                  onPressed: () => _removeActivity(index),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<int>(
                    value: activity['day'],
                    decoration: const InputDecoration(
                      labelText: 'Day',
                    ),
                    items: List.generate(_selectedDays, (i) {
                      return DropdownMenuItem(
                        value: i + 1,
                        child: Text('Day ${i + 1}'),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        _updateActivity(index, 'day', value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue: activity['time'],
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      hintText: 'e.g., 09:00',
                    ),
                    onChanged: (value) => _updateActivity(index, 'time', value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: activity['title'],
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g., Visit Eiffel Tower',
              ),
              onChanged: (value) => _updateActivity(index, 'title', value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: activity['description'],
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe the activity...',
              ),
              maxLines: 2,
              onChanged: (value) => _updateActivity(index, 'description', value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: activity['location'],
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'e.g., Champ de Mars, 5 Avenue Anatole France',
                prefixIcon: Icon(Icons.location_on),
              ),
              onChanged: (value) => _updateActivity(index, 'location', value),
            ),
          ],
        ),
      ),
    ).animate().fade(
      duration: 300.ms, 
      delay: (100 * index + 300).ms
    );
  }
  
  Widget _buildPrivacySettings() {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRIVACY SETTINGS',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isPublic = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isPublic ? AppTheme.secondaryAccent : AppTheme.primaryBackground,
                      border: Border.all(
                        color: AppTheme.primaryForeground,
                        width: AppTheme.borderWidth,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.public),
                        const SizedBox(height: 8),
                        Text(
                          'PUBLIC',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Everyone can see',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isPublic = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: !_isPublic ? AppTheme.secondaryAccent : AppTheme.primaryBackground,
                      border: Border.all(
                        color: AppTheme.primaryForeground,
                        width: AppTheme.borderWidth,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.lock),
                        const SizedBox(height: 8),
                        Text(
                          'PRIVATE',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Only you can see',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fade(duration: 300.ms, delay: 300.ms).slideY(begin: 0.2, end: 0);
  }
  
  Widget _buildSubmitButton() {
    return NeoButton(
      onPressed: _isLoading ? null : () => _createTrip(),
      color: AppTheme.primaryAccent,
      isLoading: _isLoading,
      child: Text(
        'CREATE ITINERARY',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white,
        ),
      ),
    ).animate().fade(duration: 300.ms, delay: 400.ms).slideY(begin: 0.2, end: 0);
  }
} 