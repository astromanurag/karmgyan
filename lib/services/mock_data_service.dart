import 'dart:convert';
import 'package:flutter/services.dart';
import '../config/app_config.dart';

class MockDataService {
  static Future<List<Map<String, dynamic>>> loadServices() async {
    try {
      final String jsonString = await rootBundle.loadString('${AppConfig.mockDataPath}/services.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      return jsonData.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> loadOrders() async {
    try {
      final String jsonString = await rootBundle.loadString('${AppConfig.mockDataPath}/orders.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      return jsonData.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> loadReports() async {
    try {
      final String jsonString = await rootBundle.loadString('${AppConfig.mockDataPath}/reports.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      return jsonData.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> loadClientProfiles() async {
    try {
      final String jsonString = await rootBundle.loadString('${AppConfig.mockDataPath}/client_profiles.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      return jsonData.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> loadPredictions() async {
    try {
      final String jsonString = await rootBundle.loadString('${AppConfig.mockDataPath}/predictions.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return jsonData;
    } catch (e) {
      return {};
    }
  }
}

