import '../config/app_config.dart';
import 'mock_data_service.dart';
import 'enhanced_data_service.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  // Delegate to enhanced service for better error handling and offline support
  Future<List<Map<String, dynamic>>> getServices() async {
    return await EnhancedDataService().getServices();
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    return await EnhancedDataService().getOrders();
  }

  Future<List<Map<String, dynamic>>> getReports() async {
    return await EnhancedDataService().getReports();
  }

  Future<List<Map<String, dynamic>>> getClientProfiles() async {
    return await EnhancedDataService().getClientProfiles();
  }

  Future<Map<String, dynamic>> getPredictions() async {
    return await EnhancedDataService().getPredictions();
  }
}

