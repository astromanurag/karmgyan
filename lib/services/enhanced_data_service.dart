import '../config/app_config.dart';
import 'mock_data_service.dart';
import 'supabase_service.dart';
import '../core/utils/error_handler.dart';
import '../core/services/local_storage_service.dart';
import 'dart:async';

class EnhancedDataService {
  static final EnhancedDataService _instance = EnhancedDataService._internal();
  factory EnhancedDataService() => _instance;
  EnhancedDataService._internal();

  // Get services with error handling and offline support
  Future<List<Map<String, dynamic>>> getServices() async {
    try {
      // Check connectivity
      final hasConnection = await ErrorHandler.checkConnectivity();

      if (AppConfig.useMockData || !SupabaseService.isAvailable) {
        return await MockDataService.loadServices();
      }

      // Try Supabase with cache fallback
      final services = await SupabaseService.queryWithCache(
        table: 'services',
        cacheKey: 'cached_services',
        filters: {'is_active': true},
        orderBy: 'created_at',
        ascending: false,
      );

      if (services.isEmpty && !hasConnection) {
        // Return cached data if available
        final cached = await MockDataService.loadServices();
        return cached;
      }

      return services;
    } catch (e) {
      // Fallback to mock data on error
      return await MockDataService.loadServices();
    }
  }

  // Get orders with error handling
  Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      if (AppConfig.useMockData || !SupabaseService.isAvailable) {
        return await MockDataService.loadOrders();
      }

      final orders = await SupabaseService.queryWithCache(
        table: 'orders',
        cacheKey: 'cached_orders',
        orderBy: 'created_at',
        ascending: false,
      );

      return orders;
    } catch (e) {
      return await MockDataService.loadOrders();
    }
  }

  // Get reports with error handling
  Future<List<Map<String, dynamic>>> getReports() async {
    try {
      if (AppConfig.useMockData || !SupabaseService.isAvailable) {
        return await MockDataService.loadReports();
      }

      final reports = await SupabaseService.queryWithCache(
        table: 'reports',
        cacheKey: 'cached_reports',
        orderBy: 'created_at',
        ascending: false,
      );

      return reports;
    } catch (e) {
      return await MockDataService.loadReports();
    }
  }

  // Get client profiles with error handling
  Future<List<Map<String, dynamic>>> getClientProfiles() async {
    try {
      if (AppConfig.useMockData || !SupabaseService.isAvailable) {
        return await MockDataService.loadClientProfiles();
      }

      final profiles = await SupabaseService.queryWithCache(
        table: 'client_profiles',
        cacheKey: 'cached_profiles',
        orderBy: 'created_at',
        ascending: false,
      );

      return profiles;
    } catch (e) {
      return await MockDataService.loadClientProfiles();
    }
  }

  // Get predictions with error handling
  Future<Map<String, dynamic>> getPredictions() async {
    try {
      if (AppConfig.useMockData || !SupabaseService.isAvailable) {
        return await MockDataService.loadPredictions();
      }

      // Predictions might be computed, so use cache
      final cached = LocalStorageService.get('cached_predictions');
      if (cached != null && cached is Map) {
        return Map<String, dynamic>.from(cached);
      }

      return await MockDataService.loadPredictions();
    } catch (e) {
      return await MockDataService.loadPredictions();
    }
  }

  // Create order with offline support
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      if (AppConfig.useMockData || !SupabaseService.isAvailable) {
        // Mock order creation
        await Future.delayed(const Duration(seconds: 1));
        return {
          ...orderData,
          'id': 'order_${DateTime.now().millisecondsSinceEpoch}',
          'status': 'pending',
          'created_at': DateTime.now().toIso8601String(),
        };
      }

      // Insert with offline queue
      await SupabaseService.insertWithQueue(
        table: 'orders',
        data: {
          ...orderData,
          'created_at': DateTime.now().toIso8601String(),
        },
        queueKey: 'order_queue',
      );

      return orderData;
    } catch (e) {
      rethrow;
    }
  }
}

