import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_theme.dart';
import 'analyze_name_tab.dart';
import 'compatibility_tab.dart';
import 'suggest_names_tab.dart';
import 'loshu_grid_tab.dart';

class NumerologyScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? sampleData;
  
  const NumerologyScreen({super.key, this.sampleData});

  @override
  ConsumerState<NumerologyScreen> createState() => _NumerologyScreenState();
}

class _NumerologyScreenState extends ConsumerState<NumerologyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Set initial tab based on sample data mode
    if (widget.sampleData != null) {
      final mode = widget.sampleData!['mode'] as String?;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mode == 'compatibility') {
          _tabController.index = 1;
        } else if (mode == 'suggestions') {
          _tabController.index = 2;
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryNavy,
              AppTheme.primaryBlue,
              AppTheme.primaryNavy.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.calculate,
                          color: AppTheme.accentGold,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Numerology',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Discover the power of numbers in your life',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppTheme.accentGold,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  labelColor: AppTheme.primaryNavy,
                  unselectedLabelColor: Colors.white.withOpacity(0.7),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                  ),
                  tabs: const [
                    Tab(text: 'Analyze'),
                    Tab(text: 'Compatibility'),
                    Tab(text: 'Suggest Names'),
                    Tab(text: 'Loshu Grid'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    AnalyzeNameTab(sampleData: widget.sampleData),
                    CompatibilityTab(sampleData: widget.sampleData),
                    SuggestNamesTab(sampleData: widget.sampleData),
                    const LoshuGridTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

