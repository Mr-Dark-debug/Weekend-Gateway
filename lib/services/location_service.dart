import 'package:logger/logger.dart';
import 'dart:math' as math;

class LocationService {
  final Logger _logger = Logger();
  
  // Mock coordinates for current location (default to a central position)
  // These can be customized for different demonstration purposes
  double _mockLatitude = 40.7128; // New York City
  double _mockLongitude = -74.0060;
  
  // Check permission and get current location
  // This is a mock implementation that doesn't require actual device permissions
  Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      // In a real implementation, we would check for permissions and get actual location
      // For now, we just return our mock coordinates
      return {
        'latitude': _mockLatitude,
        'longitude': _mockLongitude,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
    } catch (e, stackTrace) {
      _logger.e('Error getting current location', e, stackTrace);
      throw Exception('Failed to get current location: $e');
    }
  }
  
  // Set mock location for testing and demonstration
  void setMockLocation(double latitude, double longitude) {
    _mockLatitude = latitude;
    _mockLongitude = longitude;
    _logger.i('Mock location set to: $latitude, $longitude');
  }
  
  // Calculate distance between two points using Haversine formula
  double calculateDistance(
    double startLatitude, 
    double startLongitude,
    double endLatitude, 
    double endLongitude
  ) {
    // Radius of the Earth in kilometers
    const double earthRadius = 6371;
    
    // Convert latitude and longitude from degrees to radians
    final double startLatRad = _degreesToRadians(startLatitude);
    final double startLongRad = _degreesToRadians(startLongitude);
    final double endLatRad = _degreesToRadians(endLatitude);
    final double endLongRad = _degreesToRadians(endLongitude);
    
    // Haversine formula
    final double latDiff = endLatRad - startLatRad;
    final double longDiff = endLongRad - startLongRad;
    
    final double a = 
        _haversine(latDiff) + 
        _haversine(longDiff) * 
        math.cos(startLatRad) * 
        math.cos(endLatRad);
    
    final double c = 2 * math.asin(math.sqrt(a));
    
    // Calculate the distance
    return earthRadius * c;
  }
  
  // Helper method to convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
  
  // Helper method for haversine formula
  double _haversine(double value) {
    return math.sin(value / 2) * math.sin(value / 2);
  }
  
  // Check if a location is nearby (within specified radius)
  bool isLocationNearby(
    double targetLatitude,
    double targetLongitude,
    {double radiusKm = 100.0}
  ) {
    final double distance = calculateDistance(
      _mockLatitude,
      _mockLongitude,
      targetLatitude,
      targetLongitude
    );
    
    return distance <= radiusKm;
  }
} 