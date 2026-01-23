import 'dart:convert';
import 'package:flutter/services.dart';
import '../config/app_config.dart';

class PlacePrediction {
  final String placeId;
  final String description;
  final String? mainText;
  final String? secondaryText;

  PlacePrediction({
    required this.placeId,
    required this.description,
    this.mainText,
    this.secondaryText,
  });

  factory PlacePrediction.fromLocalData(Map<String, dynamic> data) {
    final name = data['n'] as String; // name
    final asciiname = data['a'] as String; // asciiname
    final state = data['s'] as String? ?? ''; // state
    final district = data['d'] as String? ?? ''; // district
    
    // Build description with location hierarchy
    String description = name;
    if (district.isNotEmpty) {
      description += ', $district';
    }
    if (state.isNotEmpty) {
      description += ', ${_getStateName(state)}';
    }
    
    return PlacePrediction(
      placeId: data['id'] as String? ?? '',
      description: description,
      mainText: name,
      secondaryText: district.isNotEmpty || state.isNotEmpty 
          ? '${district.isNotEmpty ? district : ''}${district.isNotEmpty && state.isNotEmpty ? ', ' : ''}${state.isNotEmpty ? _getStateName(state) : ''}'
          : null,
    );
  }
  
  static String _getStateName(String stateCode) {
    // Common Indian state codes mapping (can be expanded)
    const stateMap = {
      '36': 'Uttar Pradesh',
      '10': 'Delhi',
      '09': 'Uttarakhand',
      '05': 'Himachal Pradesh',
      '20': 'Jharkhand',
      '38': 'Andhra Pradesh',
      '37': 'Telangana',
      '29': 'Karnataka',
      '32': 'Kerala',
      '33': 'Tamil Nadu',
      '28': 'West Bengal',
      '27': 'Maharashtra',
      '24': 'Gujarat',
      '23': 'Madhya Pradesh',
      '22': 'Chhattisgarh',
      '21': 'Odisha',
      '26': 'Rajasthan',
      '25': 'Punjab',
      '03': 'Assam',
      '30': 'Arunachal Pradesh',
      '12': 'Jammu and Kashmir',
      '18': 'Manipur',
      '17': 'Meghalaya',
      '15': 'Mizoram',
      '13': 'Nagaland',
      '16': 'Tripura',
      '07': 'Haryana',
      '06': 'Bihar',
      '19': 'Goa',
      '11': 'Sikkim',
    };
    return stateMap[stateCode] ?? stateCode;
  }
}

class PlaceDetails {
  final String placeId;
  final String name;
  final String formattedAddress;
  final double latitude;
  final double longitude;
  final String? timezone;

  PlaceDetails({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    this.timezone,
  });

  factory PlaceDetails.fromLocalData(Map<String, dynamic> data) {
    final name = data['n'] as String;
    final state = data['s'] as String? ?? '';
    final district = data['d'] as String? ?? '';
    
    String formattedAddress = name;
    if (district.isNotEmpty) {
      formattedAddress += ', $district';
    }
    if (state.isNotEmpty) {
      formattedAddress += ', ${PlacePrediction._getStateName(state)}';
    }
    formattedAddress += ', India';
    
    final placeId = data['id'] as String? ?? '${data['lat']}_${data['lon']}';
    
    return PlaceDetails(
      placeId: placeId,
      name: name,
      formattedAddress: formattedAddress,
      latitude: (data['lat'] as num).toDouble(),
      longitude: (data['lon'] as num).toDouble(),
      timezone: 'Asia/Kolkata', // Default for India
    );
  }
}

class LocationService {
  static List<Map<String, dynamic>>? _locationsCache;
  static bool _isLoading = false;

  // Load India locations from asset
  static Future<void> _loadLocations() async {
    if (_locationsCache != null || _isLoading) return;
    
    _isLoading = true;
    try {
      final String jsonString = await rootBundle.loadString('assets/locations/india_locations_optimized.json');
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      _locationsCache = jsonList.map<Map<String, dynamic>>((item) {
        final itemMap = item as Map<String, dynamic>;
        return {
          'id': '${itemMap['lat']}_${itemMap['lon']}', // Use lat_lon as ID
          ...itemMap,
        };
      }).toList();
      print('✅ Loaded ${_locationsCache!.length} India locations from local database');
    } catch (e) {
      print('❌ Error loading India locations: $e');
      _locationsCache = [];
    } finally {
      _isLoading = false;
    }
  }

  // Search for places (local search)
  static Future<List<PlacePrediction>> searchPlaces(String query) async {
    if (query.isEmpty) return [];

    try {
      // Load locations if not already loaded
      await _loadLocations();
      
      if (_locationsCache == null || _locationsCache!.isEmpty) {
        return [];
      }

      final queryLower = query.toLowerCase().trim();
      final queryWords = queryLower.split(' ').where((w) => w.isNotEmpty).toList();
      
      if (queryWords.isEmpty) return [];

      // Score and filter locations
      final matches = <Map<String, dynamic>>[];
      
      for (final location in _locationsCache!) {
        final name = (location['n'] as String? ?? '').toLowerCase();
        final asciiname = (location['a'] as String? ?? '').toLowerCase();
        final searchTerms = (location['t'] as List<dynamic>? ?? [])
            .map((t) => t.toString().toLowerCase())
            .toList();
        
        int score = 0;
        bool matchesAll = true;
        
        // Check if all query words are found
        for (final word in queryWords) {
          bool wordFound = false;
          
          if (name.contains(word)) {
            score += 10;
            wordFound = true;
          }
          if (asciiname.contains(word)) {
            score += 8;
            wordFound = true;
          }
          for (final term in searchTerms) {
            if (term.contains(word)) {
              score += 5;
              wordFound = true;
              break;
            }
          }
          
          if (!wordFound) {
            matchesAll = false;
            break;
          }
        }
        
        if (matchesAll && score > 0) {
          // Boost score for exact matches and population
          if (name == queryLower || asciiname == queryLower) {
            score += 50;
          }
          if (name.startsWith(queryLower) || asciiname.startsWith(queryLower)) {
            score += 20;
          }
          
          final population = location['p'] as int? ?? 0;
          score += (population / 10000).round().clamp(0, 50); // Boost by population
          
          matches.add({
            ...location,
            '_score': score,
          });
        }
      }
      
      // Sort by score (descending) and population (descending)
      matches.sort((a, b) {
        final scoreDiff = (b['_score'] as int) - (a['_score'] as int);
        if (scoreDiff != 0) return scoreDiff;
        return (b['p'] as int? ?? 0) - (a['p'] as int? ?? 0);
      });
      
      // Return top 20 results
      final topMatches = matches.take(20).toList();
      
      return topMatches.map((loc) {
        final name = loc['n'] as String;
        final asciiname = loc['a'] as String;
        final state = loc['s'] as String? ?? '';
        final district = loc['d'] as String? ?? '';
        
        String description = name;
        if (district.isNotEmpty) {
          description += ', $district';
        }
        if (state.isNotEmpty) {
          description += ', ${PlacePrediction._getStateName(state)}';
        }
        
        return PlacePrediction(
          placeId: '${loc['lat']}_${loc['lon']}', // Use lat_lon as ID
          description: description,
          mainText: name,
          secondaryText: district.isNotEmpty || state.isNotEmpty 
              ? '${district.isNotEmpty ? district : ''}${district.isNotEmpty && state.isNotEmpty ? ', ' : ''}${state.isNotEmpty ? PlacePrediction._getStateName(state) : ''}'
              : null,
        );
      }).toList();
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }

  // Get place details by coordinates (find nearest)
  static Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      // placeId format: "lat_lon"
      final parts = placeId.split('_');
      if (parts.length != 2) return null;
      
      final lat = double.tryParse(parts[0]);
      final lon = double.tryParse(parts[1]);
      
      if (lat == null || lon == null) return null;
      
      return await reverseGeocode(lat, lon);
    } catch (e) {
      print('Error getting place details: $e');
      return null;
    }
  }

  // Reverse geocode: Get address from coordinates (find nearest location)
  static Future<PlaceDetails?> reverseGeocode(double latitude, double longitude) async {
    try {
      await _loadLocations();
      
      if (_locationsCache == null || _locationsCache!.isEmpty) {
        return null;
      }

      // Find nearest location using distance calculation
      Map<String, dynamic>? nearest;
      double minDistance = double.infinity;

      for (final location in _locationsCache!) {
        final locLat = (location['lat'] as num).toDouble();
        final locLon = (location['lon'] as num).toDouble();
        
        // Calculate distance using Haversine formula (simplified)
        final latDiff = (latitude - locLat).abs();
        final lonDiff = (longitude - locLon).abs();
        final distance = latDiff * latDiff + lonDiff * lonDiff; // Simplified distance
        
        if (distance < minDistance) {
          minDistance = distance;
          nearest = location;
        }
      }

      if (nearest != null) {
        return PlaceDetails.fromLocalData({
          'id': '${nearest['lat']}_${nearest['lon']}',
          ...nearest,
        });
      }

      return null;
    } catch (e) {
      print('Error reverse geocoding: $e');
      return null;
    }
  }
}
