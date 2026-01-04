import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_theme.dart';
import '../../../services/numerology_service.dart';

class LoshuGridTab extends ConsumerStatefulWidget {
  const LoshuGridTab({super.key});

  @override
  ConsumerState<LoshuGridTab> createState() => _LoshuGridTabState();
}

class _LoshuGridTabState extends ConsumerState<LoshuGridTab> {
  DateTime? _selectedDate;
  bool _isLoading = false;
  Map<String, dynamic>? _gridData;

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _gridData = null;
      });
      _calculateGrid();
    }
  }

  Future<void> _calculateGrid() async {
    if (_selectedDate == null) return;

    setState(() {
      _isLoading = true;
      _gridData = null;
    });

    try {
      final result = await NumerologyService().getLoshuGrid(
        birthDate: _selectedDate!,
      );

      setState(() {
        _gridData = result;
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
                    'Loshu Grid (Magic Square)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Discover your numerology chart based on your date of birth',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Date Picker
                  InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppTheme.accentGold),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDate == null
                                ? 'Select Birth Date'
                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedDate == null ? Colors.grey : AppTheme.primaryNavy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Calculate Button
                  ElevatedButton(
                    onPressed: _selectedDate == null || _isLoading ? null : _calculateGrid,
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
                              Icon(Icons.grid_view),
                              SizedBox(width: 8),
                              Text(
                                'Calculate Grid',
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
          
          // Grid Display
          if (_gridData != null) ...[
            const SizedBox(height: 20),
            _buildGridDisplay(_gridData!),
          ],
        ],
      ),
    );
  }

  Widget _buildGridDisplay(Map<String, dynamic> data) {
    // Convert nested List<dynamic> to List<List<dynamic>>
    final gridRaw = data['grid'] as List;
    final grid = gridRaw.map((row) => (row as List).cast<dynamic>()).toList();
    
    final gridDetails = data['grid_details'] as List;
    final missingNumbers = data['missing_numbers'] as List;
    final strongNumbers = data['strong_numbers'] as List;
    final interpretation = data['interpretation'] as Map<String, dynamic>;
    final lifePathNumber = data['life_path_number'] as int;

    // Grid positions with meanings
    final gridPositions = {
      1: {'aspect': 'Self, Leadership', 'plane': 'Material', 'row': 2, 'col': 1},
      2: {'aspect': 'Emotions, Partnership', 'plane': 'Mental', 'row': 0, 'col': 2},
      3: {'aspect': 'Creativity, Expression', 'plane': 'Physical', 'row': 1, 'col': 0},
      4: {'aspect': 'Education, Knowledge', 'plane': 'Mental', 'row': 0, 'col': 0},
      5: {'aspect': 'Communication, Freedom', 'plane': 'Physical', 'row': 1, 'col': 1},
      6: {'aspect': 'Service, Responsibility', 'plane': 'Material', 'row': 2, 'col': 2},
      7: {'aspect': 'Intuition, Spirituality', 'plane': 'Physical', 'row': 1, 'col': 2},
      8: {'aspect': 'Authority, Success', 'plane': 'Material', 'row': 2, 'col': 0},
      9: {'aspect': 'Spirituality, Wisdom', 'plane': 'Mental', 'row': 0, 'col': 1},
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Life Path Number
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentGold.withOpacity(0.3),
                  Colors.white,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Life Path Number: ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      lifePathNumber.toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Loshu Grid
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Loshu Grid',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
                ),
                const SizedBox(height: 20),
                // Grid
                Table(
                  border: TableBorder.all(
                    color: AppTheme.primaryNavy,
                    width: 3,
                  ),
                  children: List.generate(3, (row) {
                    return TableRow(
                      children: List.generate(3, (col) {
                        final rowData = grid[row] as List;
                        final number = (rowData[col] as num).toInt();
                        final isEmpty = number == 0;
                        
                        // Find the number details
                        final numberDetails = gridDetails.firstWhere(
                          (detail) => detail['number'] == number && detail['row'] == row && detail['col'] == col,
                          orElse: () => null,
                        );
                        
                        final aspect = numberDetails != null 
                            ? numberDetails['aspect'] as String
                            : '';
                        
                        return Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: isEmpty 
                                ? Colors.grey[100]
                                : AppTheme.accentGold.withOpacity(0.2),
                            border: Border.all(
                              color: isEmpty 
                                  ? Colors.grey[300]!
                                  : AppTheme.accentGold,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!isEmpty)
                                Text(
                                  number.toString(),
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryNavy,
                                  ),
                                )
                              else
                                const Icon(
                                  Icons.remove,
                                  color: Colors.grey,
                                  size: 32,
                                ),
                              if (!isEmpty && aspect.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    aspect.split(',')[0],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[700],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Interpretation
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Interpretation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  interpretation['summary'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.primaryNavy,
                  ),
                ),
                if (strongNumbers.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          interpretation['strong'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (missingNumbers.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          interpretation['missing'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Grid Details
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Number Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
                ),
                const SizedBox(height: 12),
                ...gridDetails.map((detail) {
                  final number = detail['number'] as int;
                  final count = detail['count'] as int;
                  final present = detail['present'] as bool;
                  final aspect = detail['aspect'] as String;
                  final plane = detail['plane'] as String;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: present 
                          ? AppTheme.accentGold.withOpacity(0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: present 
                            ? AppTheme.accentGold
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: present 
                                ? AppTheme.accentGold
                                : Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              number.toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: present 
                                    ? AppTheme.primaryNavy
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                aspect,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: present 
                                      ? AppTheme.primaryNavy
                                      : Colors.grey[600],
                                ),
                              ),
                              Text(
                                plane,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (count > 1)
                                Text(
                                  'Appears $count times',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          present ? Icons.check_circle : Icons.cancel,
                          color: present ? Colors.green : Colors.grey,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

