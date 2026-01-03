import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_theme.dart';

class ConsultationsScreen extends ConsumerStatefulWidget {
  const ConsultationsScreen({super.key});

  @override
  ConsumerState<ConsultationsScreen> createState() => _ConsultationsScreenState();
}

class _ConsultationsScreenState extends ConsumerState<ConsultationsScreen> {
  String _selectedType = 'video';
  String _selectedCategory = 'all';

  final List<Map<String, dynamic>> _advisors = [
    {
      'name': 'Dr. Priya Sharma',
      'specialization': 'Vedic Astrology Expert',
      'rating': 4.9,
      'reviews': 1250,
      'experience': '15+ years',
      'price': 999,
      'isAvailable': true,
      'languages': ['Hindi', 'English'],
      'expertise': ['Career', 'Marriage', 'Health'],
      'avatar': 'P',
      'gradient': [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    },
    {
      'name': 'Acharya Rajesh',
      'specialization': 'Numerology & Palmistry',
      'rating': 4.8,
      'reviews': 980,
      'experience': '12+ years',
      'price': 799,
      'isAvailable': true,
      'languages': ['Hindi', 'English', 'Sanskrit'],
      'expertise': ['Numerology', 'Vastu', 'Remedies'],
      'avatar': 'A',
      'gradient': [Color(0xFF4ECDC4), Color(0xFF556270)],
    },
    {
      'name': 'Swami Ananda',
      'specialization': 'Spiritual Guidance',
      'rating': 4.9,
      'reviews': 2100,
      'experience': '20+ years',
      'price': 1299,
      'isAvailable': false,
      'nextAvailable': '30 min',
      'languages': ['Hindi', 'English', 'Tamil'],
      'expertise': ['Meditation', 'Karma', 'Life Path'],
      'avatar': 'S',
      'gradient': [Color(0xFF667EEA), Color(0xFF764BA2)],
    },
    {
      'name': 'Pandit Mohan Ji',
      'specialization': 'Kundli & Matching Expert',
      'rating': 4.7,
      'reviews': 750,
      'experience': '18+ years',
      'price': 899,
      'isAvailable': true,
      'languages': ['Hindi'],
      'expertise': ['Marriage', 'Kundli', 'Muhurat'],
      'avatar': 'M',
      'gradient': [Color(0xFFF093FB), Color(0xFFF5576C)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1B2A),
              Color(0xFF1B263B),
              Color(0xFF415A77),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.headset_mic, color: AppTheme.accentGold, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Talk to Expert',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.wallet, color: AppTheme.accentGold, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                '₹500',
                                style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Get personalized guidance from verified astrologers',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),
              
              // Consultation Type Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildTypeChip('Video', Icons.videocam, 'video'),
                    const SizedBox(width: 10),
                    _buildTypeChip('Call', Icons.phone, 'audio'),
                    const SizedBox(width: 10),
                    _buildTypeChip('Chat', Icons.chat_bubble, 'chat'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Category Filter
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildCategoryChip('All', 'all'),
                    _buildCategoryChip('Career', 'career'),
                    _buildCategoryChip('Marriage', 'marriage'),
                    _buildCategoryChip('Health', 'health'),
                    _buildCategoryChip('Vastu', 'vastu'),
                    _buildCategoryChip('Remedies', 'remedies'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Online count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_advisors.where((a) => a['isAvailable'] == true).length} astrologers online',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.filter_list, color: AppTheme.accentGold, size: 18),
                      label: Text('Filter', style: TextStyle(color: AppTheme.accentGold)),
                    ),
                  ],
                ),
              ),
              
              // Advisor List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _advisors.length,
                  itemBuilder: (context, index) => _buildAdvisorCard(_advisors[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, IconData icon, String type) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(colors: [AppTheme.accentGold, AppTheme.accentGoldLight])
                : null,
            color: isSelected ? null : Color(0xFF1F2833),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppTheme.accentGold : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? AppTheme.primaryNavy : Colors.white70, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryNavy : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentGold.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.accentGold : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.accentGold : Colors.white70,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildAdvisorCard(Map<String, dynamic> advisor) {
    final bool isAvailable = advisor['isAvailable'] ?? false;
    final gradientColors = advisor['gradient'] as List<Color>;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Color(0xFF1F2833),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Stack(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradientColors),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          advisor['avatar'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: isAvailable ? Colors.green : Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Color(0xFF1F2833), width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              advisor['name'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: gradientColors),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '₹${advisor['price']}/hr',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        advisor['specialization'],
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      
                      // Rating & Experience
                      Row(
                        children: [
                          Icon(Icons.star, color: AppTheme.accentGold, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${advisor['rating']}',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          Text(
                            ' (${advisor['reviews']})',
                            style: TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.work_outline, color: Colors.white38, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            advisor['experience'],
                            style: TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Expertise Tags
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: (advisor['expertise'] as List<String>).map((e) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              e,
                              style: TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              children: [
                if (!isAvailable)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.access_time, color: Colors.orange, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Available in ${advisor['nextAvailable']}',
                            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.chat_bubble_outline, size: 16),
                            label: Text('Chat'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: BorderSide(color: Colors.white24),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _startConsultation(advisor['name']),
                            icon: Icon(Icons.videocam, size: 18),
                            label: Text('Consult'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentGold,
                              foregroundColor: AppTheme.primaryNavy,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startConsultation(String advisorName) {
    final consultationId = 'consultation_${DateTime.now().millisecondsSinceEpoch}';
    context.push(
      '/consultation-room/$consultationId?name=${Uri.encodeComponent(advisorName)}&type=$_selectedType&isConsultant=false',
    );
  }
}
