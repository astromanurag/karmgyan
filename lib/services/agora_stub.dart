// Stub for Agora RTC Engine on web
import 'dart:async';
import 'package:flutter/material.dart';

class RtcEngine {
  Future<void> initialize(dynamic context) => Future.value();
  Future<void> registerEventHandler(dynamic handler) => Future.value();
  Future<void> joinChannel({String? token, String? channelId, int? uid, dynamic options}) => Future.value();
  Future<void> leaveChannel() => Future.value();
  Future<void> release() => Future.value();
  Future<void> enableLocalVideo(bool enabled) => Future.value();
  Future<void> enableLocalAudio(bool enabled) => Future.value();
}

RtcEngine? createAgoraRtcEngine() => null;

class RtcEngineContext {
  final String? appId;
  final dynamic channelProfile;
  RtcEngineContext({this.appId, this.channelProfile});
}

class RtcEngineEventHandler {
  final Function? onJoinChannelSuccess;
  final Function? onUserJoined;
  final Function? onUserOffline;
  final Function? onRemoteVideoStateChanged;
  final Function? onError;
  RtcEngineEventHandler({
    this.onJoinChannelSuccess,
    this.onUserJoined,
    this.onUserOffline,
    this.onRemoteVideoStateChanged,
    this.onError,
  });
}

class ChannelProfileType {
  static const channelProfileCommunication = null;
}

class ChannelMediaOptions {
  const ChannelMediaOptions();
}

class VideoViewController {
  final RtcEngine? rtcEngine;
  final VideoCanvas? canvas;
  
  VideoViewController({this.rtcEngine, this.canvas});
}

class VideoCanvas {
  final int uid;
  final int? viewId;
  final int? sourceType;
  
  const VideoCanvas({
    required this.uid,
    this.viewId,
    this.sourceType,
  });
}

// AgoraVideoView widget stub for web
class AgoraVideoView extends StatelessWidget {
  final VideoViewController? controller;
  final bool? useAndroidSurfaceView;
  final bool? useFlutterTexture;
  final bool? useAndroidTextureView;
  
  const AgoraVideoView({
    Key? key,
    this.controller,
    this.useAndroidSurfaceView,
    this.useFlutterTexture,
    this.useAndroidTextureView,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Text(
          'Video not available on web',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

enum UserOfflineReasonType {
  quit,
  dropped,
  becameAudience,
}

enum ErrorCodeType {
  ok,
  failed,
}

enum RemoteVideoState {
  starting,
  started,
  stopping,
  stopped,
}

enum RemoteVideoStateReason {
  remoteMuted,
  remoteUnmuted,
  audioFallback,
  audioFallbackRecovery,
}

class RtcConnection {
  // Stub for RTC connection
}

