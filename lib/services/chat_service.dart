import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import 'supabase_service.dart';
import 'dart:async';

class ChatService {
  static RealtimeChannel? _channel;
  static final List<Map<String, dynamic>> _messages = [];
  static Function(Map<String, dynamic>)? onMessageReceived;

  // Join chat room
  static Future<void> joinChatRoom(String consultationId) async {
    if (AppConfig.useMockData || !SupabaseService.isAvailable) {
      // Mock chat - simulate messages
      return;
    }

    try {
      final client = SupabaseService.client;
      if (client == null) return;

      _channel = client.channel('consultation_$consultationId');

      _channel!.onBroadcast(
        event: 'message',
        callback: (payload, [ref]) {
          final message = payload['message'] as Map<String, dynamic>?;
          if (message != null) {
            _messages.add(message);
            onMessageReceived?.call(message);
          }
        },
      );

      await _channel!.subscribe();
    } catch (e) {
      print('Failed to join chat room: $e');
    }
  }

  // Send message
  static Future<void> sendMessage({
    required String consultationId,
    required String userId,
    required String message,
    required String userName,
  }) async {
    if (AppConfig.useMockData || !SupabaseService.isAvailable) {
      // Mock message
      final mockMessage = {
        'id': 'msg_${DateTime.now().millisecondsSinceEpoch}',
        'consultation_id': consultationId,
        'user_id': userId,
        'user_name': userName,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      };
      _messages.add(mockMessage);
      onMessageReceived?.call(mockMessage);
      return;
    }

    try {
      final client = SupabaseService.client;
      if (client == null || _channel == null) return;

      await _channel!.sendBroadcastMessage(
        event: 'message',
        payload: {
          'message': {
            'id': 'msg_${DateTime.now().millisecondsSinceEpoch}',
            'consultation_id': consultationId,
            'user_id': userId,
            'user_name': userName,
            'message': message,
            'timestamp': DateTime.now().toIso8601String(),
          },
        },
      );
    } catch (e) {
      print('Failed to send message: $e');
      rethrow;
    }
  }

  // Get messages
  static Future<List<Map<String, dynamic>>> getMessages(String consultationId) async {
    if (AppConfig.useMockData || !SupabaseService.isAvailable) {
      return _messages;
    }

    try {
      final client = SupabaseService.client;
      if (client == null) return _messages;

      final response = await client
          .from('chat_messages')
          .select()
          .eq('consultation_id', consultationId)
          .order('timestamp', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Failed to get messages: $e');
      return _messages;
    }
  }

  // Leave chat room
  static Future<void> leaveChatRoom() async {
    if (_channel != null) {
      await _channel!.unsubscribe();
      _channel = null;
    }
    _messages.clear();
  }

  // Clear messages
  static void clearMessages() {
    _messages.clear();
  }
}

