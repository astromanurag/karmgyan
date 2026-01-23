import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../core/utils/error_handler.dart';
import 'dart:async';

// Conditional import for Agora (not available on web)
import 'package:agora_rtc_engine/agora_rtc_engine.dart' if (dart.library.html) 'package:karmgyan/services/agora_stub.dart';

class VideoConsultationService {
  static RtcEngine? _engine;
  static bool _isInitialized = false;
  static bool _isJoined = false;
  static int? _localUid;
  static Function(int uid, int elapsed)? onUserJoined;
  static Function(int uid, UserOfflineReasonType reason)? onUserOffline;
  static Function(RtcConnection connection, int remoteUid, int elapsed)? onRemoteVideoStateChanged;

  // Get engine (for internal use)
  static RtcEngine? get engine => _engine;

  // Initialize Agora engine
  static Future<void> initialize() async {
    if (!AppConfig.hasAgoraConfig || _isInitialized) return;

    try {
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(
        appId: AppConfig.agoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      // Register event handlers
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            _isJoined = true;
            print('Joined channel successfully');
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            _localUid = remoteUid;
            onUserJoined?.call(remoteUid, elapsed);
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            onUserOffline?.call(remoteUid, reason);
          },
          onRemoteVideoStateChanged: (RtcConnection connection, int remoteUid, RemoteVideoState state, RemoteVideoStateReason reason, int elapsed) {
            onRemoteVideoStateChanged?.call(connection, remoteUid, elapsed);
          },
          onError: (ErrorCodeType err, String msg) {
            print('Agora error: $err - $msg');
          },
        ),
      );

      _isInitialized = true;
    } catch (e) {
      print('Agora initialization failed: $e');
      throw Exception('Video service initialization failed');
    }
  }

  // Join channel
  static Future<void> joinChannel({
    required String channelName,
    required int uid,
    String? token,
  }) async {
    if (AppConfig.useMockData || !AppConfig.hasAgoraConfig) {
      // Mock join
      await Future.delayed(const Duration(seconds: 1));
      _isJoined = true;
      _localUid = uid;
      return;
    }

    if (!_isInitialized) {
      await initialize();
    }

    if (_engine == null) {
      throw Exception('Video engine not initialized');
    }

    try {
      await _engine!.joinChannel(
        token: token ?? '',
        channelId: channelName,
        uid: uid,
        options: const ChannelMediaOptions(),
      );
    } catch (e) {
      throw Exception('Failed to join channel: $e');
    }
  }

  // Enable local video
  static Future<void> enableLocalVideo(bool enabled) async {
    if (AppConfig.useMockData || !_isInitialized || _engine == null) return;

    try {
      await _engine!.enableLocalVideo(enabled);
    } catch (e) {
      print('Failed to enable local video: $e');
    }
  }

  // Enable local audio
  static Future<void> enableLocalAudio(bool enabled) async {
    if (AppConfig.useMockData || !_isInitialized || _engine == null) return;

    try {
      await _engine!.enableLocalAudio(enabled);
    } catch (e) {
      print('Failed to enable local audio: $e');
    }
  }

  // Setup local video view
  // Note: In Agora RTC Engine 6.x, AgoraVideoView widget handles setup automatically
  // This method is kept for compatibility but may not be needed
  static Future<void> setupLocalVideo(VideoViewController viewController) async {
    if (AppConfig.useMockData || !_isInitialized || _engine == null) return;
    // AgoraVideoView widget handles the setup automatically when controller is provided
    // No manual setup needed in version 6.x
  }

  // Setup remote video view
  // Note: In Agora RTC Engine 6.x, AgoraVideoView widget handles setup automatically
  // This method is kept for compatibility but may not be needed
  static Future<void> setupRemoteVideo({
    required int uid,
    required VideoViewController viewController,
  }) async {
    if (AppConfig.useMockData || !_isInitialized || _engine == null) return;
    // AgoraVideoView widget handles the setup automatically when controller is provided
    // No manual setup needed in version 6.x
  }

  // Leave channel
  static Future<void> leaveChannel() async {
    if (AppConfig.useMockData || !_isInitialized || _engine == null) return;

    try {
      await _engine!.leaveChannel();
      _isJoined = false;
      _localUid = null;
    } catch (e) {
      print('Failed to leave channel: $e');
    }
  }

  // Dispose
  static Future<void> dispose() async {
    if (_engine != null) {
      await _engine!.leaveChannel();
      await _engine!.release();
      _engine = null;
      _isInitialized = false;
      _isJoined = false;
    }
  }

  // Get local UID
  static int? get localUid => _localUid;
  static bool get isJoined => _isJoined;
  static bool get isInitialized => _isInitialized;
}

