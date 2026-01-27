import 'package:flutter/material.dart';

/// Test data constants for local UI testing
/// Contains sample data for all major features of the app
/// 
/// NOTE: This file is for local development/testing only.
/// It should NOT be included in production builds.
class TestData {
  // Birth Chart Sample Data
  static final Map<String, dynamic> birthChartData = {
    'name': 'Rahul Kumar',
    'date': DateTime(1990, 5, 15),
    'time': const TimeOfDay(hour: 6, minute: 35),
    'latitude': 28.6139,
    'longitude': 77.2090,
    'location': 'New Delhi, India',
    'timezone': 'Asia/Kolkata',
  };

  // Compatibility Matching - Person 1
  static final Map<String, dynamic> compatibilityPerson1 = {
    'name': 'Rahul Kumar',
    'date': DateTime(1990, 5, 15),
    'time': const TimeOfDay(hour: 6, minute: 35),
    'latitude': 28.6139,
    'longitude': 77.2090,
    'location': 'New Delhi, India',
    'timezone': 'Asia/Kolkata',
  };

  // Compatibility Matching - Person 2
  static final Map<String, dynamic> compatibilityPerson2 = {
    'name': 'Priya Sharma',
    'date': DateTime(1992, 8, 20),
    'time': const TimeOfDay(hour: 10, minute: 15),
    'latitude': 19.0760,
    'longitude': 72.8777,
    'location': 'Mumbai, India',
    'timezone': 'Asia/Kolkata',
  };

  // Panchang Sample Data
  static final Map<String, dynamic> panchangData = {
    'date': DateTime.now(),
    'latitude': 28.6139,
    'longitude': 77.2090,
    'location': 'New Delhi, India',
    'timezone': 'Asia/Kolkata',
  };

  // Numerology - Name Analysis
  static final Map<String, dynamic> numerologyNameData = {
    'name': 'Rahul Kumar',
    'birthDate': DateTime(1990, 5, 15),
    'system': 'pythagorean',
  };

  // Numerology - Compatibility
  static final Map<String, dynamic> numerologyCompatibilityData = {
    'number1': 5,
    'number2': 8,
    'system': 'pythagorean',
  };

  // Numerology - Name Suggestions
  static final Map<String, dynamic> numerologySuggestionsData = {
    'name': 'Rahul',
    'targetNumber': 8,
    'system': 'pythagorean',
  };

  // Kundli Milan (Matching) Sample Data
  static final Map<String, dynamic> kundliMilanPerson1 = {
    'name': 'Rahul Kumar',
    'date': DateTime(1990, 5, 15),
    'time': const TimeOfDay(hour: 6, minute: 35),
    'latitude': 28.6139,
    'longitude': 77.2090,
    'location': 'New Delhi, India',
  };

  static final Map<String, dynamic> kundliMilanPerson2 = {
    'name': 'Priya Sharma',
    'date': DateTime(1992, 8, 20),
    'time': const TimeOfDay(hour: 10, minute: 15),
    'latitude': 19.0760,
    'longitude': 72.8777,
    'location': 'Mumbai, India',
  };

  // Additional Sample Birth Data Sets
  static final Map<String, dynamic> birthData2 = {
    'name': 'Amit Patel',
    'date': DateTime(1988, 3, 10),
    'time': const TimeOfDay(hour: 14, minute: 30),
    'latitude': 23.0225,
    'longitude': 72.5714,
    'location': 'Ahmedabad, India',
    'timezone': 'Asia/Kolkata',
  };

  static final Map<String, dynamic> birthData3 = {
    'name': 'Sneha Reddy',
    'date': DateTime(1995, 11, 25),
    'time': const TimeOfDay(hour: 8, minute: 0),
    'latitude': 17.3850,
    'longitude': 78.4867,
    'location': 'Hyderabad, India',
    'timezone': 'Asia/Kolkata',
  };

  // Sample User Credentials (for mock auth testing)
  static final Map<String, String> testCredentials = {
    'email': 'test@test.com',
    'password': 'password123',
    'phone': '+919876543210',
    'otp': '123456',
  };

  // Sample Numerology Names
  static final List<String> sampleNames = [
    'Rahul Kumar',
    'Priya Sharma',
    'Amit Patel',
    'Sneha Reddy',
    'Vikram Singh',
    'Anjali Mehta',
    'Rajesh Iyer',
    'Kavita Nair',
  ];

  // Sample Locations (Indian cities)
  static final List<Map<String, dynamic>> sampleLocations = [
    {
      'name': 'New Delhi',
      'latitude': 28.6139,
      'longitude': 77.2090,
      'state': 'Delhi',
    },
    {
      'name': 'Mumbai',
      'latitude': 19.0760,
      'longitude': 72.8777,
      'state': 'Maharashtra',
    },
    {
      'name': 'Bangalore',
      'latitude': 12.9716,
      'longitude': 77.5946,
      'state': 'Karnataka',
    },
    {
      'name': 'Chennai',
      'latitude': 13.0827,
      'longitude': 80.2707,
      'state': 'Tamil Nadu',
    },
    {
      'name': 'Kolkata',
      'latitude': 22.5726,
      'longitude': 88.3639,
      'state': 'West Bengal',
    },
    {
      'name': 'Hyderabad',
      'latitude': 17.3850,
      'longitude': 78.4867,
      'state': 'Telangana',
    },
  ];
}

