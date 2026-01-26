import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_theme.dart';
import '../../../services/matching_service.dart';

class KundliMilanScreen extends ConsumerStatefulWidget {
  const KundliMilanScreen({super.key});

  @override
  ConsumerState<KundliMilanScreen> createState() => _KundliMilanScreenState();
}

class _KundliMilanScreenState extends ConsumerState<KundliMilanScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Map<String, dynamic>? _compatibilityResult;

  // Person 1 fields
  final _p1DateController = TextEditingController();
  final _p1TimeController = TextEditingController();
  final _p1LatController = TextEditingController();
  final _p1LonController = TextEditingController();

  // Person 2 fields
  final _p2DateController = TextEditingController();
  final _p2TimeController = TextEditingController();
  final _p2LatController = TextEditingController();
  final _p2LonController = TextEditingController();

  DateTime? _p1Date, _p2Date;
  TimeOfDay? _p1Time, _p2Time;

  @override
  void dispose() {
    _p1DateController.dispose();
    _p1TimeController.dispose();
    _p1LatController.dispose();
    _p1LonController.dispose();
    _p2DateController.dispose();
    _p2TimeController.dispose();
    _p2LatController.dispose();
    _p2LonController.dispose();
    super.dispose();
  }

  Future<void> _computeCompatibility() async {
    if (!_formKey.currentState!.validate()) return;
    if (_p1Date == null || _p1Time == null || _p2Date == null || _p2Time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _compatibilityResult = null;
    });

    try {
      // Format date as YYYY-MM-DD (API expects this format)
      final p1DateStr = '${_p1Date!.year}-${_p1Date!.month.toString().padLeft(2, '0')}-${_p1Date!.day.toString().padLeft(2, '0')}';
      final p2DateStr = '${_p2Date!.year}-${_p2Date!.month.toString().padLeft(2, '0')}-${_p2Date!.day.toString().padLeft(2, '0')}';
      // Format time as HH:MM:SS (API expects this format)
      final p1TimeStr = '${_p1Time!.hour.toString().padLeft(2, '0')}:${_p1Time!.minute.toString().padLeft(2, '0')}:00';
      final p2TimeStr = '${_p2Time!.hour.toString().padLeft(2, '0')}:${_p2Time!.minute.toString().padLeft(2, '0')}:00';
      
      final person1 = {
        'date': p1DateStr,
        'time': p1TimeStr,
        'latitude': double.parse(_p1LatController.text),
        'longitude': double.parse(_p1LonController.text),
        'timezone': 'Asia/Kolkata',
      };

      final person2 = {
        'date': p2DateStr,
        'time': p2TimeStr,
        'latitude': double.parse(_p2LatController.text),
        'longitude': double.parse(_p2LonController.text),
        'timezone': 'Asia/Kolkata',
      };

      final result = await MatchingService().computeCompatibility(
        person1: person1,
        person2: person2,
      );

      setState(() {
        _compatibilityResult = result;
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
        title: const Text('Kundli Milan'),
      ),
      body: _compatibilityResult == null
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PersonFormSection(
                      title: 'Person 1 (Bride)',
                      dateController: _p1DateController,
                      timeController: _p1TimeController,
                      latController: _p1LatController,
                      lonController: _p1LonController,
                      onDateSelected: (date) => setState(() => _p1Date = date),
                      onTimeSelected: (time) => setState(() => _p1Time = time),
                    ),
                    const SizedBox(height: 32),
                    _PersonFormSection(
                      title: 'Person 2 (Groom)',
                      dateController: _p2DateController,
                      timeController: _p2TimeController,
                      latController: _p2LatController,
                      lonController: _p2LonController,
                      onDateSelected: (date) => setState(() => _p2Date = date),
                      onTimeSelected: (time) => setState(() => _p2Time = time),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _computeCompatibility,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Compute Compatibility'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : _CompatibilityResultView(result: _compatibilityResult!),
    );
  }
}

class _PersonFormSection extends StatelessWidget {
  final String title;
  final TextEditingController dateController;
  final TextEditingController timeController;
  final TextEditingController latController;
  final TextEditingController lonController;
  final Function(DateTime) onDateSelected;
  final Function(TimeOfDay) onTimeSelected;

  const _PersonFormSection({
    required this.title,
    required this.dateController,
    required this.timeController,
    required this.latController,
    required this.lonController,
    required this.onDateSelected,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: dateController,
              readOnly: true,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  dateController.text =
                      '${picked.day}/${picked.month}/${picked.year}';
                  onDateSelected(picked);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Date of Birth',
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: timeController,
              readOnly: true,
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  timeController.text =
                      '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';
                  onTimeSelected(picked);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Time of Birth',
                prefixIcon: Icon(Icons.access_time),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: latController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      prefixIcon: Icon(Icons.my_location),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      final lat = double.tryParse(value!);
                      if (lat == null || lat < -90 || lat > 90) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: lonController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      prefixIcon: Icon(Icons.explore),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      final lon = double.tryParse(value!);
                      if (lon == null || lon < -180 || lon > 180) {
                        return 'Invalid';
                      }
                      return null;
                    },
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

class _CompatibilityResultView extends StatelessWidget {
  final Map<String, dynamic> result;

  const _CompatibilityResultView({required this.result});

  @override
  Widget build(BuildContext context) {
    final gunaMilan = result['guna_milan'] as Map<String, dynamic>? ?? {};
    final doshas = result['doshas'] as Map<String, dynamic>? ?? {};
    // Handle both int and double for total_points
    final totalPointsValue = gunaMilan['total_points'];
    final totalPoints = (totalPointsValue is num) ? totalPointsValue.toDouble() : 
                        (totalPointsValue != null ? double.tryParse(totalPointsValue.toString()) ?? 0.0 : 0.0);
    final maxPointsValue = gunaMilan['out_of'];
    final maxPoints = (maxPointsValue is num) ? maxPointsValue.toDouble() : 
                      (maxPointsValue != null ? double.tryParse(maxPointsValue.toString()) ?? 36.0 : 36.0);
    // Use API percentage if available, otherwise calculate
    final percentageValue = gunaMilan['percentage'];
    final percentage = (percentageValue != null) ? 
                       (percentageValue is num ? percentageValue.toStringAsFixed(1) : percentageValue.toString()) :
                       ((totalPoints / maxPoints) * 100).toStringAsFixed(1);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: AppTheme.primaryBlue,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Compatibility Score',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${totalPoints.toStringAsFixed(totalPoints % 1 == 0 ? 0 : 1)} / ${maxPoints.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '36-Point Guna Milan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          if (gunaMilan['details'] != null) {
            final detailsList = gunaMilan['details'];
            if (detailsList is List) {
              ...detailsList.map((guna) {
                if (guna is Map<String, dynamic>) {
                  return _GunaCard(guna: guna);
                }
                return const SizedBox.shrink();
              }).toList(),
            }
          }
          const SizedBox(height: 24),
          Text(
            'Dosha Analysis',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _DoshaCard(doshas: doshas),
          const SizedBox(height: 24),
          Card(
            color: AppTheme.accentGold.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommendation',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result['recommendation'] ?? 'No recommendation available',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GunaCard extends StatelessWidget {
  final Map<String, dynamic> guna;

  const _GunaCard({required this.guna});

  @override
  Widget build(BuildContext context) {
    // Handle both int and double for points
    final pointsValue = guna['points'];
    final points = (pointsValue is num) ? pointsValue.toDouble() : 
                   (pointsValue != null ? double.tryParse(pointsValue.toString()) ?? 0.0 : 0.0);
    final maxPointsValue = guna['max_points'];
    final maxPoints = (maxPointsValue is num) ? maxPointsValue.toDouble() : 
                      (maxPointsValue != null ? double.tryParse(maxPointsValue.toString()) ?? 0.0 : 0.0);
    final percentage = maxPoints > 0 ? (points / maxPoints * 100) : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          guna['guna'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(guna['description'] ?? ''),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${points.toStringAsFixed(points % 1 == 0 ? 0 : 1)} / ${maxPoints.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                color: percentage >= 70
                    ? Colors.green
                    : percentage >= 50
                        ? Colors.orange
                        : Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoshaCard extends StatelessWidget {
  final Map<String, dynamic> doshas;

  const _DoshaCard({required this.doshas});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          if (doshas['mangal_dosha'] != null)
            _DoshaItem(
              title: 'Mangal Dosha',
              dosha: doshas['mangal_dosha'],
            ),
          if (doshas['nadi_dosha'] != null)
            _DoshaItem(
              title: 'Nadi Dosha',
              dosha: doshas['nadi_dosha'],
            ),
          if (doshas['bhakut_dosha'] != null)
            _DoshaItem(
              title: 'Bhakut Dosha',
              dosha: doshas['bhakut_dosha'],
            ),
        ],
      ),
    );
  }
}

class _DoshaItem extends StatelessWidget {
  final String title;
  final Map<String, dynamic> dosha;

  const _DoshaItem({required this.title, required this.dosha});

  @override
  Widget build(BuildContext context) {
    final present = dosha['present'] ?? false;
    final compatible = dosha['compatible'] ?? true;

    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(present ? 'Present' : 'Not Present'),
      trailing: Icon(
        compatible ? Icons.check_circle : Icons.cancel,
        color: compatible ? Colors.green : Colors.red,
      ),
    );
  }
}

