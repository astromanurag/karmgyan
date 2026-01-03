import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_theme.dart';
import '../../../services/ai_service.dart';

class AIChatScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? chartData;

  const AIChatScreen({this.chartData, super.key});

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final AIService _aiService = AIService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  List<_ChatMessage> _messages = [];
  int _credits = 0;
  bool _isLoading = false;
  String? _conversationId;
  Map<String, dynamic>? _chartData;

  // Sample questions for quick access
  final List<String> _sampleQuestions = [
    'When will I get married?',
    'Which career is best for me?',
    'How is my financial future?',
    'What does my health look like?',
    'What does current dasha indicate?',
    'What are my lucky periods?',
  ];

  @override
  void initState() {
    super.initState();
    _chartData = widget.chartData ?? _getMockChartData();
    _loadCredits();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    final ascendant = _getAscendant();
    _messages.add(_ChatMessage(
      role: 'assistant',
      content: '''🙏 Namaste! I'm your AI Astrologer.

I've analyzed your birth chart with **$ascendant Ascendant**. You can ask me any question about your life, career, relationships, finances, or spiritual path.

**Example questions:**
• "When will I get married?"
• "Which career suits me best?"
• "What does my current dasha indicate?"

Each question costs **1 credit**. You currently have **$_credits credits**.

*Ask away!* 🌟''',
      isTyping: false,
    ));
  }

  String _getAscendant() {
    final asc = _chartData?['ascendant'];
    if (asc is Map) {
      return asc['sign'] ?? 'Unknown';
    } else if (asc is String) {
      return asc;
    }
    return 'Unknown';
  }

  Future<void> _loadCredits() async {
    final info = await _aiService.getCredits();
    if (mounted) {
      setState(() => _credits = info.credits);
    }
  }

  Map<String, dynamic> _getMockChartData() {
    return {
      'name': 'User',
      'date': '1987-10-31',
      'time': '06:35:00',
      'place': 'Meerut, India',
      'ascendant': {'sign': 'Libra', 'degree': 23.45},
      'planets': {
        'Sun': {'sign': 'Libra', 'house': 1, 'degree': 14.32, 'nakshatra': 'Swati'},
        'Moon': {'sign': 'Taurus', 'house': 8, 'degree': 15.67, 'nakshatra': 'Rohini'},
        'Mars': {'sign': 'Virgo', 'house': 12, 'degree': 22.34, 'nakshatra': 'Hasta'},
        'Mercury': {'sign': 'Scorpio', 'house': 2, 'degree': 8.12, 'nakshatra': 'Anuradha'},
        'Jupiter': {'sign': 'Aries', 'house': 7, 'degree': 28.90, 'nakshatra': 'Krittika'},
        'Venus': {'sign': 'Virgo', 'house': 12, 'degree': 12.45, 'nakshatra': 'Hasta'},
        'Saturn': {'sign': 'Scorpio', 'house': 2, 'degree': 23.67, 'nakshatra': 'Jyeshtha'},
        'Rahu': {'sign': 'Pisces', 'house': 6, 'degree': 15.23, 'nakshatra': 'Uttara Bhadrapada'},
        'Ketu': {'sign': 'Virgo', 'house': 12, 'degree': 15.23, 'nakshatra': 'Hasta'},
      },
      'current_dasha': {
        'mahadasha': 'Moon',
        'antardasha': 'Mars',
        'start_date': '2024-01-01',
        'end_date': '2024-08-15',
      },
      'yogas': ['Gaja Kesari Yoga', 'Budhaditya Yoga'],
    };
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    final question = text.trim();
    _messageController.clear();

    // Add user message
    setState(() {
      _messages.add(_ChatMessage(
        role: 'user',
        content: question,
      ));
      _isLoading = true;
    });
    _scrollToBottom();

    // Add typing indicator
    setState(() {
      _messages.add(_ChatMessage(
        role: 'assistant',
        content: '',
        isTyping: true,
      ));
    });

    // Call AI service
    final response = await _aiService.askQuestion(
      chartData: _chartData!,
      question: question,
      conversationId: _conversationId,
    );

    // Remove typing indicator
    setState(() {
      _messages.removeWhere((m) => m.isTyping);
    });

    if (response.success && response.answer != null) {
      setState(() {
        _messages.add(_ChatMessage(
          role: 'assistant',
          content: response.answer!,
          isMock: response.isMock,
        ));
        _credits = response.creditsRemaining ?? _credits - 1;
        _conversationId = response.conversationId;
        _isLoading = false;
      });
    } else {
      setState(() {
        _messages.add(_ChatMessage(
          role: 'assistant',
          content: '❌ ${response.error ?? 'Failed to get response. Please try again.'}',
          isError: true,
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _copyMessage(String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.accentGold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1B2A),
              Color(0xFF1B263B),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildChartSummary(),
              Expanded(child: _buildMessageList()),
              if (!_isLoading) _buildQuickQuestions(),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(color: AppTheme.accentGold.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.accentGold, Colors.orange.shade600],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Astrologer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Powered by GPT-4',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade600, Colors.purple.shade800],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.diamond, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$_credits',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showBuyCreditsDialog(),
            icon: Icon(Icons.add_circle, color: AppTheme.accentGold),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSummary() {
    final ascendant = _getAscendant();
    final dasha = _chartData?['current_dasha'];
    final mahadasha = dasha?['mahadasha'] ?? 'Unknown';

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_graph, color: AppTheme.accentGold, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Chart: $ascendant Ascendant',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Current Dasha: $mahadasha',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push('/birth-chart'),
            child: Text(
              'View Chart',
              style: TextStyle(color: AppTheme.accentGold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    final isUser = message.role == 'user';

    if (message.isTyping) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.accentGold,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'AI is thinking...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isUser
                    ? LinearGradient(
                        colors: [AppTheme.accentGold, Colors.orange.shade600],
                      )
                    : null,
                color: isUser ? null : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: message.isError
                    ? Border.all(color: Colors.red.withOpacity(0.5))
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: AppTheme.accentGold,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'AI Astrologer',
                          style: TextStyle(
                            color: AppTheme.accentGold,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (message.isMock)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'DEMO',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  if (!isUser) const SizedBox(height: 8),
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.white.withOpacity(0.9),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (!isUser && !message.isTyping && !message.isError)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _copyMessage(message.content),
                      icon: Icon(
                        Icons.copy,
                        size: 16,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      tooltip: 'Copy',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                    IconButton(
                      onPressed: () {
                        // Share functionality
                      },
                      icon: Icon(
                        Icons.share,
                        size: 16,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      tooltip: 'Share',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickQuestions() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _sampleQuestions.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(
                _sampleQuestions[index],
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: Colors.white.withOpacity(0.1),
              side: BorderSide(color: AppTheme.accentGold.withOpacity(0.3)),
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
              onPressed: () => _sendMessage(_sampleQuestions[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          top: BorderSide(color: AppTheme.accentGold.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              style: const TextStyle(color: Colors.white),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Ask about your chart...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.accentGold, Colors.orange.shade600],
              ),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _isLoading
                  ? null
                  : () => _sendMessage(_messageController.text),
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showBuyCreditsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BuyCreditsSheet(
        onPurchase: (packageId) async {
          // Simulate purchase
          final success = await _aiService.purchaseCredits(
            packageId: packageId,
            paymentId: 'demo_${DateTime.now().millisecondsSinceEpoch}',
          );
          if (success) {
            await _loadCredits();
            if (mounted) Navigator.pop(context);
          }
        },
      ),
    );
  }
}

class _ChatMessage {
  final String role;
  final String content;
  final bool isTyping;
  final bool isMock;
  final bool isError;

  _ChatMessage({
    required this.role,
    required this.content,
    this.isTyping = false,
    this.isMock = false,
    this.isError = false,
  });
}

class _BuyCreditsSheet extends StatefulWidget {
  final Function(String) onPurchase;

  const _BuyCreditsSheet({required this.onPurchase});

  @override
  State<_BuyCreditsSheet> createState() => _BuyCreditsSheetState();
}

class _BuyCreditsSheetState extends State<_BuyCreditsSheet> {
  final AIService _aiService = AIService();
  List<CreditPackage> _packages = [];
  String? _selectedPackage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    final packages = await _aiService.getCreditPackages();
    if (mounted) {
      setState(() {
        _packages = packages;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1B263B),
            Color(0xFF0D1B2A),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple.shade600, Colors.purple.shade800],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.diamond, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Buy AI Credits',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Unlock AI predictions',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ..._packages.map((pkg) => _buildPackageCard(pkg)),
                const SizedBox(height: 16),
                Text(
                  '1 credit = 1 question • 5 credits = Basic report',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(CreditPackage package) {
    final isSelected = _selectedPackage == package.id;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedPackage = package.id);
        widget.onPurchase(package.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentGold.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentGold
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${package.credits}',
                style: TextStyle(
                  color: AppTheme.accentGold,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${package.credits} Credits',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (package.isPopular)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'POPULAR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (package.savings != null)
                    Text(
                      'Save ${package.savings}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${package.priceInr.toInt()}',
                  style: TextStyle(
                    color: AppTheme.accentGold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${package.priceUsd.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

