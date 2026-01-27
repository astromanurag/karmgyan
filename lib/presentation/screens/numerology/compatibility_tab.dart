import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_theme.dart';
import '../../../services/numerology_service.dart';

class CompatibilityTab extends ConsumerStatefulWidget {
  final Map<String, dynamic>? sampleData;
  
  const CompatibilityTab({super.key, this.sampleData});

  @override
  ConsumerState<CompatibilityTab> createState() => _CompatibilityTabState();
}

class _CompatibilityTabState extends ConsumerState<CompatibilityTab> {
  int _number1 = 1;
  int _number2 = 1;
  String _selectedSystem = 'pythagorean';
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    // Use sample data if provided
    if (widget.sampleData != null) {
      _number1 = widget.sampleData!['number1'] ?? 1;
      _number2 = widget.sampleData!['number2'] ?? 1;
      _selectedSystem = widget.sampleData!['system'] ?? 'pythagorean';
    }
  }

  Future<void> _checkCompatibility() async {
    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final result = await NumerologyService().checkCompatibility(
        number1: _number1,
        number2: _number2,
        system: _selectedSystem,
      );

      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input Card
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Check Number Compatibility',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'See how two numbers harmonize together',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Number 1
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'First Number',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildNumberSelector(_number1, (value) {
                              setState(() => _number1 = value);
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.favorite, color: Colors.pink, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Second Number',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildNumberSelector(_number2, (value) {
                              setState(() => _number2 = value);
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // System Selection
                  DropdownButtonFormField<String>(
                    value: _selectedSystem,
                    decoration: InputDecoration(
                      labelText: 'System',
                      prefixIcon: const Icon(Icons.settings, color: AppTheme.accentGold),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'pythagorean',
                        child: Text('Pythagorean'),
                      ),
                      DropdownMenuItem(
                        value: 'chaldean',
                        child: Text('Chaldean'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedSystem = value!;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Check Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _checkCompatibility,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold,
                      foregroundColor: AppTheme.primaryNavy,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryNavy,
                              ),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite_border),
                              SizedBox(width: 8),
                              Text(
                                'Check Compatibility',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
          
          // Results
          if (_result != null) ...[
            const SizedBox(height: 20),
            _buildCompatibilityResult(_result!),
          ],
        ],
      ),
    );
  }

  Widget _buildNumberSelector(int currentValue, Function(int) onChanged) {
    final numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 22, 33];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<int>(
        value: currentValue,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        items: numbers.map((number) {
          final meaning = NumerologyService().getNumberMeaning(number);
          return DropdownMenuItem<int>(
            value: number,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(meaning['color'] as int),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      number.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(meaning['title'] as String),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }

  Widget _buildCompatibilityResult(Map<String, dynamic> result) {
    final score = result['score'] as int;
    final compatibility = result['compatibility'] as String;
    final description = result['description'] as String;
    final number1Info = result['number1_info'] as Map<String, dynamic>?;
    final number2Info = result['number2_info'] as Map<String, dynamic>?;
    
    Color scoreColor;
    IconData scoreIcon;
    if (score >= 70) {
      scoreColor = Colors.green;
      scoreIcon = Icons.favorite;
    } else if (score >= 50) {
      scoreColor = Colors.orange;
      scoreIcon = Icons.thumb_up;
    } else {
      scoreColor = Colors.red;
      scoreIcon = Icons.warning_amber;
    }
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              scoreColor.withOpacity(0.1),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Compatibility Score
            Icon(scoreIcon, size: 48, color: scoreColor),
            const SizedBox(height: 12),
            
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [scoreColor, scoreColor.withOpacity(0.6)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: scoreColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$score%',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      compatibility,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Description
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
            
            if (number1Info != null && number2Info != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              
              // Detailed Info
              Row(
                children: [
                  Expanded(
                    child: _buildNumberInfo(_number1, number1Info),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumberInfo(_number2, number2Info),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNumberInfo(int number, Map<String, dynamic> info) {
    final localMeaning = NumerologyService().getNumberMeaning(number);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(localMeaning['color'] as int).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Color(localMeaning['color'] as int),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            info['title'] as String? ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: 8),
          if (info['keywords'] != null)
            ...((info['keywords'] as List).take(2).map((keyword) => Text(
                  keyword,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ))),
        ],
      ),
    );
  }
}

