import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../../config/app_theme.dart';
import '../../../services/video_consultation_service.dart';
import '../../../services/chat_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/empty_state_widget.dart';

class ConsultationRoomScreen extends ConsumerStatefulWidget {
  final String consultationId;
  final String consultantName;
  final String type; // 'video', 'audio', 'chat'
  final bool isConsultant;

  const ConsultationRoomScreen({
    super.key,
    required this.consultationId,
    required this.consultantName,
    required this.type,
    this.isConsultant = false,
  });

  @override
  ConsumerState<ConsultationRoomScreen> createState() =>
      _ConsultationRoomScreenState();
}

class _ConsultationRoomScreenState
    extends ConsumerState<ConsultationRoomScreen> {
  bool _isLoading = true;
  bool _isVideoEnabled = true;
  bool _isAudioEnabled = true;
  bool _isJoined = false;
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  VideoViewController? _localVideoController;
  VideoViewController? _remoteVideoController;

  @override
  void initState() {
    super.initState();
    _initializeConsultation();
  }

  Future<void> _initializeConsultation() async {
    setState(() => _isLoading = true);

    try {
      // Initialize chat
      ChatService.onMessageReceived = (message) {
        setState(() {
          _messages.add(message);
        });
        _scrollToBottom();
      };

      await ChatService.joinChatRoom(widget.consultationId);
      final existingMessages = await ChatService.getMessages(widget.consultationId);
      setState(() {
        _messages.addAll(existingMessages);
      });

      // Initialize video/audio if needed
      if (widget.type == 'video' || widget.type == 'audio') {
        await VideoConsultationService.initialize();
        final uid = DateTime.now().millisecondsSinceEpoch % 100000;
        await VideoConsultationService.joinChannel(
          channelName: widget.consultationId,
          uid: uid,
        );

        if (widget.type == 'video') {
          final engine = VideoConsultationService.engine;
          if (engine != null) {
            _localVideoController = VideoViewController(
              rtcEngine: engine,
              canvas: const VideoCanvas(uid: 0),
            );
            // Setup will be done when the view is rendered
          }
        }
      }

      setState(() {
        _isJoined = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      await ChatService.sendMessage(
        consultationId: widget.consultationId,
        userId: 'user_001', // Get from auth
        message: _messageController.text.trim(),
        userName: widget.isConsultant ? widget.consultantName : 'You',
      );

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    }
  }

  Future<void> _toggleVideo() async {
    try {
      await VideoConsultationService.enableLocalVideo(!_isVideoEnabled);
      setState(() => _isVideoEnabled = !_isVideoEnabled);
    } catch (e) {
      ErrorHandler.showError(context, e);
    }
  }

  Future<void> _toggleAudio() async {
    try {
      await VideoConsultationService.enableLocalAudio(!_isAudioEnabled);
      setState(() => _isAudioEnabled = !_isAudioEnabled);
    } catch (e) {
      ErrorHandler.showError(context, e);
    }
  }

  Future<void> _endConsultation() async {
    try {
      await VideoConsultationService.leaveChannel();
      await ChatService.leaveChatRoom();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ErrorHandler.showError(context, e);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    VideoConsultationService.dispose();
    ChatService.leaveChatRoom();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Joining Consultation...')),
        body: const LoadingWidget(message: 'Connecting...'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.consultantName),
        actions: [
          if (widget.type == 'video' || widget.type == 'audio')
            IconButton(
              icon: Icon(_isVideoEnabled ? Icons.videocam : Icons.videocam_off),
              onPressed: _toggleVideo,
            ),
          if (widget.type == 'video' || widget.type == 'audio')
            IconButton(
              icon: Icon(_isAudioEnabled ? Icons.mic : Icons.mic_off),
              onPressed: _toggleAudio,
            ),
          IconButton(
            icon: const Icon(Icons.call_end),
            onPressed: _endConsultation,
            color: Colors.red,
          ),
        ],
      ),
      body: widget.type == 'chat'
          ? _buildChatView()
          : widget.type == 'video'
              ? _buildVideoView()
              : _buildAudioView(),
    );
  }

  Widget _buildChatView() {
    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.chat_bubble_outline,
                  title: 'No messages yet',
                  message: 'Start the conversation',
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isMe = message['user_id'] == 'user_001';
                    return _ChatBubble(message: message, isMe: isMe);
                  },
                ),
        ),
        _ChatInput(
          controller: _messageController,
          onSend: _sendMessage,
        ),
      ],
    );
  }

  Widget _buildVideoView() {
    return Stack(
      children: [
        // Remote video (full screen)
        if (_remoteVideoController != null)
          AgoraVideoView(controller: _remoteVideoController!)
        else
          Container(
            color: Colors.black,
            child: const Center(
              child: Text(
                'Waiting for consultant...',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        // Local video (picture-in-picture)
        if (_localVideoController != null)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: AgoraVideoView(controller: _localVideoController!),
              ),
            ),
          ),
        // Chat overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _ChatBubble(
                        message: message,
                        isMe: message['user_id'] == 'user_001',
                        compact: true,
                      );
                    },
                  ),
                ),
                _ChatInput(
                  controller: _messageController,
                  onSend: _sendMessage,
                  compact: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioView() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppTheme.primaryBlue,
                  child: Text(
                    widget.consultantName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.consultantName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Audio Call',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
        _ChatInput(
          controller: _messageController,
          onSend: _sendMessage,
        ),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMe;
  final bool compact;

  const _ChatBubble({
    required this.message,
    required this.isMe,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: compact ? 2 : 4,
          horizontal: compact ? 4 : 8,
        ),
        padding: EdgeInsets.all(compact ? 6 : 12),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primaryBlue : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * (compact ? 0.6 : 0.7),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe && !compact)
              Text(
                message['user_name'] ?? 'User',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isMe ? Colors.white70 : Colors.black87,
                ),
              ),
            Text(
              message['message'] ?? '',
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: compact ? 12 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool compact;

  const _ChatInput({
    required this.controller,
    required this.onSend,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 4 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: compact ? 12 : 16,
                  vertical: compact ? 8 : 12,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: onSend,
            color: AppTheme.primaryBlue,
          ),
        ],
      ),
    );
  }
}

