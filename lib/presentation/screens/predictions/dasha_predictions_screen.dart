import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_theme.dart';
import '../../../services/computation_service.dart';
import '../../../core/services/local_storage_service.dart';

class DashaPredictionsScreen extends ConsumerStatefulWidget {
  const DashaPredictionsScreen({super.key});

  @override
  ConsumerState<DashaPredictionsScreen> createState() =>
      _DashaPredictionsScreenState();
}

class _DashaPredictionsScreenState
    extends ConsumerState<DashaPredictionsScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _dashaData;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadStoredData();
  }

  Future<void> _loadStoredData() async {
    final birthData = LocalStorageService.get('birth_data');
    if (birthData != null && birthData is Map<String, dynamic>) {
      final dateStr = birthData['date'] as String? ?? '';
      if (dateStr.isNotEmpty) {
        final dateParts = dateStr.split('-');
        if (dateParts.length == 3) {
          setState(() {
            _selectedDate = DateTime(
              int.parse(dateParts[0]),
              int.parse(dateParts[1]),
              int.parse(dateParts[2]),
            );
          });
          _generateDasha();
        }
      }
    }
  }

  Future<void> _generateDasha() async {
    if (_selectedDate == null) return;

    setState(() => _isLoading = true);

    try {
      final birthData = LocalStorageService.get('birth_data');
      final lat = (birthData?['latitude'] as num?)?.toDouble() ?? 28.6139;
      final lon = (birthData?['longitude'] as num?)?.toDouble() ?? 77.2090;

      final result = await ComputationService().generateDasha(
        date: _selectedDate!,
        latitude: lat,
        longitude: lon,
      );

      setState(() {
        _dashaData = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dasha Predictions'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dashaData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timeline, size: 64, color: AppTheme.primaryBlue),
                      const SizedBox(height: 16),
                      const Text('No dasha data available'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _generateDasha,
                        child: const Text('Generate Dasha'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dasha Periods',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      if (_dashaData!['dasha_periods'] != null)
                        ...(_dashaData!['dasha_periods'] as List).map((period) {
                          return _DashaPeriodCard(period: period);
                        }).toList(),
                    ],
                  ),
                ),
    );
  }
}

class _DashaPeriodCard extends StatelessWidget {
  final Map<String, dynamic> period;

  const _DashaPeriodCard({required this.period});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    period['planet'] ?? 'Unknown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${period['duration_years'] ?? 0} years',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${period['start_date'] ?? ''} - ${period['end_date'] ?? ''}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Text(
              period['description'] ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

