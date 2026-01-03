import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_theme.dart';
import '../../../services/ai_service.dart';

class AIReportsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? chartData;

  const AIReportsScreen({this.chartData, super.key});

  @override
  ConsumerState<AIReportsScreen> createState() => _AIReportsScreenState();
}

class _AIReportsScreenState extends ConsumerState<AIReportsScreen>
    with SingleTickerProviderStateMixin {
  final AIService _aiService = AIService();
  late TabController _tabController;

  int _credits = 0;
  List<SavedReport> _savedReports = [];
  bool _isLoadingReports = true;
  Map<String, dynamic>? _chartData;

  // Report generation state
  bool _isGenerating = false;
  String? _generatedReport;
  ReportType? _selectedReportType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _chartData = widget.chartData ?? _getMockChartData();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadCredits(),
      _loadSavedReports(),
    ]);
  }

  Future<void> _loadCredits() async {
    final info = await _aiService.getCredits();
    if (mounted) {
      setState(() => _credits = info.credits);
    }
  }

  Future<void> _loadSavedReports() async {
    final reports = await _aiService.getSavedReports();
    if (mounted) {
      setState(() {
        _savedReports = reports;
        _isLoadingReports = false;
      });
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
        'Sun': {'sign': 'Libra', 'house': 1, 'degree': 14.32},
        'Moon': {'sign': 'Taurus', 'house': 8, 'degree': 15.67},
        'Mars': {'sign': 'Virgo', 'house': 12, 'degree': 22.34},
        'Mercury': {'sign': 'Scorpio', 'house': 2, 'degree': 8.12},
        'Jupiter': {'sign': 'Aries', 'house': 7, 'degree': 28.90},
        'Venus': {'sign': 'Virgo', 'house': 12, 'degree': 12.45},
        'Saturn': {'sign': 'Scorpio', 'house': 2, 'degree': 23.67},
      },
      'current_dasha': {
        'mahadasha': 'Moon',
        'antardasha': 'Mars',
      },
    };
  }

  Future<void> _generateReport(ReportType type) async {
    if (_credits < type.creditCost) {
      _showInsufficientCreditsDialog(type.creditCost);
      return;
    }

    setState(() {
      _isGenerating = true;
      _selectedReportType = type;
      _generatedReport = null;
    });

    final response = await _aiService.generateReport(
      chartData: _chartData!,
      reportType: type,
    );

    if (response.success && response.content != null) {
      setState(() {
        _generatedReport = response.content;
        _credits = response.creditsRemaining ?? _credits - type.creditCost;
        _isGenerating = false;
      });

      // Switch to view tab and refresh saved reports
      _tabController.animateTo(1);
      _loadSavedReports();
    } else {
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ?? 'Failed to generate report'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showInsufficientCreditsDialog(int required) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: AppTheme.accentGold),
            const SizedBox(width: 12),
            const Text(
              'Insufficient Credits',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          'You need $required credits but only have $_credits. Would you like to buy more?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Show buy credits dialog
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGold,
              foregroundColor: Colors.black,
            ),
            child: const Text('Buy Credits'),
          ),
        ],
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
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGenerateTab(),
                    _buildSavedTab(),
                  ],
                ),
              ),
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
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.blue.shade800],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.description, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Reports',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Detailed astrological reports',
                  style: TextStyle(
                    color: Colors.white70,
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
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.accentGold,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(text: 'Generate New'),
          Tab(text: 'Saved Reports'),
        ],
      ),
    );
  }

  Widget _buildGenerateTab() {
    if (_isGenerating) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppTheme.accentGold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Generating ${_selectedReportType?.displayName ?? 'Report'}...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This may take a minute',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_generatedReport != null) {
      return _buildReportView(_generatedReport!, _selectedReportType!);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReportCard(
          ReportType.comprehensive,
          'Complete Life Reading',
          'Get a detailed analysis of all life areas including career, relationships, finances, health, and spiritual path.',
          Icons.auto_awesome,
          [Colors.purple.shade400, Colors.purple.shade700],
        ),
        const SizedBox(height: 16),
        _buildReportCard(
          ReportType.career,
          'Career Guidance',
          'Discover your ideal career path, business potential, and best timing for professional moves.',
          Icons.work,
          [Colors.blue.shade400, Colors.blue.shade700],
        ),
        const SizedBox(height: 16),
        _buildReportCard(
          ReportType.marriage,
          'Marriage & Relationships',
          'Learn about marriage timing, partner characteristics, and relationship compatibility factors.',
          Icons.favorite,
          [Colors.pink.shade400, Colors.pink.shade700],
        ),
        const SizedBox(height: 16),
        _buildReportCard(
          ReportType.yearly,
          '12-Month Forecast',
          'Get a detailed month-by-month prediction for the next year with key dates and opportunities.',
          Icons.calendar_month,
          [Colors.green.shade400, Colors.green.shade700],
        ),
      ],
    );
  }

  Widget _buildReportCard(
    ReportType type,
    String title,
    String description,
    IconData icon,
    List<Color> gradientColors,
  ) {
    final hasEnoughCredits = _credits >= type.creditCost;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.diamond, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${type.creditCost} credits',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: hasEnoughCredits
                        ? () => _generateReport(type)
                        : () => _showInsufficientCreditsDialog(type.creditCost),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasEnoughCredits
                          ? AppTheme.accentGold
                          : Colors.grey.shade700,
                      foregroundColor: hasEnoughCredits ? Colors.black : Colors.white70,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          hasEnoughCredits ? Icons.auto_awesome : Icons.lock,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          hasEnoughCredits
                              ? 'Generate Report'
                              : 'Need ${type.creditCost} Credits',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportView(String content, ReportType type) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${type.displayName} generated successfully!',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _generatedReport = null;
                    _selectedReportType = null;
                  });
                },
                child: const Text('New Report'),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description, color: AppTheme.accentGold),
                      const SizedBox(width: 12),
                      Text(
                        type.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: content));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Report copied!')),
                          );
                        },
                        icon: const Icon(Icons.copy, color: Colors.white70),
                      ),
                      IconButton(
                        onPressed: () {
                          // Share or download
                        },
                        icon: const Icon(Icons.share, color: Colors.white70),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 32),
                  SelectableText(
                    content,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSavedTab() {
    if (_isLoadingReports) {
      return Center(
        child: CircularProgressIndicator(color: AppTheme.accentGold),
      );
    }

    if (_savedReports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No saved reports yet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _tabController.animateTo(0),
              child: Text(
                'Generate your first report',
                style: TextStyle(color: AppTheme.accentGold),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _savedReports.length,
      itemBuilder: (context, index) {
        final report = _savedReports[index];
        return _buildSavedReportCard(report);
      },
    );
  }

  Widget _buildSavedReportCard(SavedReport report) {
    final typeColor = _getReportTypeColor(report.reportType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: typeColor.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getReportTypeIcon(report.reportType),
            color: typeColor,
          ),
        ),
        title: Text(
          _getReportTypeTitle(report.reportType),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              report.preview ?? 'Tap to view full report',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(report.createdAt),
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.white.withOpacity(0.5),
        ),
        onTap: () => _viewReport(report),
      ),
    );
  }

  void _viewReport(SavedReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1B263B), Color(0xFF0D1B2A)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      _getReportTypeIcon(report.reportType),
                      color: AppTheme.accentGold,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getReportTypeTitle(report.reportType),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: report.content));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied!')),
                        );
                      },
                      icon: const Icon(Icons.copy, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white24),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: SelectableText(
                    report.content,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getReportTypeColor(String type) {
    switch (type) {
      case 'comprehensive':
        return Colors.purple;
      case 'career':
        return Colors.blue;
      case 'marriage':
        return Colors.pink;
      case 'yearly':
        return Colors.green;
      default:
        return AppTheme.accentGold;
    }
  }

  IconData _getReportTypeIcon(String type) {
    switch (type) {
      case 'comprehensive':
        return Icons.auto_awesome;
      case 'career':
        return Icons.work;
      case 'marriage':
        return Icons.favorite;
      case 'yearly':
        return Icons.calendar_month;
      default:
        return Icons.description;
    }
  }

  String _getReportTypeTitle(String type) {
    switch (type) {
      case 'comprehensive':
        return 'Life Reading';
      case 'career':
        return 'Career Report';
      case 'marriage':
        return 'Marriage Report';
      case 'yearly':
        return 'Yearly Forecast';
      default:
        return 'Report';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

