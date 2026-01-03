import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../core/services/local_storage_service.dart';

class SupabaseService {
  static SupabaseClient? _client;
  static bool _initialized = false;

  // Initialize Supabase
  static Future<void> initialize() async {
    if (!AppConfig.hasSupabaseConfig || _initialized) return;

    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      _initialized = true;
    } catch (e) {
      // If initialization fails, continue with mock data
      print('Supabase initialization failed: $e');
    }
  }

  // Get Supabase client
  static SupabaseClient? get client {
    if (!AppConfig.hasSupabaseConfig) return null;
    return _client ?? Supabase.instance.client;
  }

  // Check if Supabase is available
  static bool get isAvailable => AppConfig.hasSupabaseConfig && _initialized;

  // Generic query with offline support
  static Future<List<Map<String, dynamic>>> queryWithCache({
    required String table,
    String? cacheKey,
    Map<String, dynamic>? filters,
    int? limit,
    String? orderBy,
    bool ascending = true,
  }) async {
    // Try Supabase first if available
    if (isAvailable && client != null) {
      try {
        var query = client!.from(table).select();

        // Apply filters
        if (filters != null) {
          filters.forEach((key, value) {
            query = query.eq(key, value) as dynamic;
          });
        }

        // Apply ordering
        if (orderBy != null) {
          query = (query as dynamic).order(orderBy, ascending: ascending);
        }

        // Apply limit
        if (limit != null) {
          query = (query as dynamic).limit(limit);
        }

        final response = await (query as dynamic);
        final data = List<Map<String, dynamic>>.from(response);

        // Cache the result
        if (cacheKey != null) {
          await LocalStorageService.save(cacheKey, data);
        }

        return data;
      } catch (e) {
        print('Supabase query error: $e');
        // Fall back to cache or mock data
      }
    }

    // Try to load from cache
    if (cacheKey != null) {
      final cached = LocalStorageService.get(cacheKey);
      if (cached != null && cached is List) {
        return List<Map<String, dynamic>>.from(cached);
      }
    }

    // Return empty list if no data available
    return [];
  }

  // Insert with offline queue
  static Future<void> insertWithQueue({
    required String table,
    required Map<String, dynamic> data,
    String? queueKey,
  }) async {
    if (isAvailable && client != null) {
      try {
        await client!.from(table).insert(data);
        return;
      } catch (e) {
        print('Supabase insert error: $e');
        // Queue for later if offline
      }
    }

    // Queue for later sync
    if (queueKey != null) {
      final queue = LocalStorageService.get(queueKey) as List? ?? [];
      queue.add({
        'table': table,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
      await LocalStorageService.save(queueKey, queue);
    }
  }

  // Update with offline queue
  static Future<void> updateWithQueue({
    required String table,
    required String id,
    required Map<String, dynamic> data,
    String? queueKey,
  }) async {
    if (isAvailable && client != null) {
      try {
        await client!.from(table).update(data).eq('id', id);
        return;
      } catch (e) {
        print('Supabase update error: $e');
      }
    }

    // Queue for later sync
    if (queueKey != null) {
      final queue = LocalStorageService.get(queueKey) as List? ?? [];
      queue.add({
        'table': table,
        'id': id,
        'data': data,
        'type': 'update',
        'timestamp': DateTime.now().toIso8601String(),
      });
      await LocalStorageService.save(queueKey, queue);
    }
  }

  // Sync offline queue
  static Future<void> syncOfflineQueue(String queueKey) async {
    if (!isAvailable || client == null) return;

    final queue = LocalStorageService.get(queueKey) as List? ?? [];
    if (queue.isEmpty) return;

    final List<Map<String, dynamic>> failed = [];

    for (final item in queue) {
      try {
        if (item['type'] == 'update') {
          await client!.from(item['table']).update(item['data']).eq('id', item['id']);
        } else {
          await client!.from(item['table']).insert(item['data']);
        }
      } catch (e) {
        print('Failed to sync item: $e');
        failed.add(item);
      }
    }

    // Save failed items back to queue
    await LocalStorageService.save(queueKey, failed);
  }
}

