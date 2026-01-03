import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_theme.dart';
import '../../../services/matching_service.dart';

class MatchingScreen extends ConsumerStatefulWidget {
  const MatchingScreen({super.key});

  @override
  ConsumerState<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends ConsumerState<MatchingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _person1DateController = TextEditingController();
  final _person1TimeController = TextEditingController();
  final _person1LatController = TextEditingController();
  final _person1LonController = TextEditingController();
  final _person2DateController = TextEditingController();
  final _person2TimeController = TextEditingController();
  final _person2LatController = TextEditingController();
  final _person2LonController = TextEditingController();

  DateTime? _person1Date;
  TimeOfDay? _person1Time;
  DateTime? _person2Date;
  TimeOfDay? _person2Time;
  bool _isLoading = false;
  Map<String, dynamic>? _compatibilityResult;

  @override
  void dispose() {
    _person1DateController.dispose();
    _person1TimeController.dispose();
    _person1LatController.dispose();
    _person1LonController.dispose();
    _person2DateController.dispose();
    _person2TimeController.dispose();
    _person2LatController.dispose();
    _person2LonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(int person) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (person == 1) {
          _person1Date = picked;
          _person1DateController.text = '${picked.day}/${picked.month}/${picked.year}';
        } else {
          _person2Date = picked;
          _person2DateController.text = '${picked.day}/${picked.month}/${picked.year}';
        }
      });
    }
  }

  Future<void> _selectTime(int person) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (person == 1) {
          _person1Time = picked;
          _person1TimeController.text = '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';
        } else {
          _person2Time = picked;
          _person2TimeController.text = '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';
        }
      });
    }
  }

  Future<void> _computeCompatibility() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _compatibilityResult = null;
    });

    try {
      final person1 = {
        'date': '${_person1Date!.year}-${_person1Date!.month.toString().padLeft(2, '0')}-${_person1Date!.day.toString().padLeft(2, '0')}',
        'time': '${_person1Time!.hour.toString().padLeft(2, '0')}:${_person1Time!.minute.toString().padLeft(2, '0')}:00',
        'latitude': double.parse(_person1LatController.text),
        'longitude': double.parse(_person1LonController.text),
      };

      final person2 = {
        'date': '${_person2Date!.year}-${_person2Date!.month.toString().padLeft(2, '0')}-${_person2Date!.day.toString().padLeft(2, '0')}',
        'time': '${_person2Time!.hour.toString().padLeft(2, '0')}:${_person2Time!.minute.toString().padLeft(2, '0')}:00',
        'latitude': double.parse(_person2LatController.text),
        'longitude': double.parse(_person2LonController.text),
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
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compatibility Matching'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.creamLight,
              Colors.white,
            ],
          ),
        ),
        child: _compatibilityResult == null
            ? _buildForm()
            : _buildResultView(),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Person 1 Section
            _buildPersonSection('Person 1', 1),
            const SizedBox(height: 32),
            // Person 2 Section
            _buildPersonSection('Person 2', 2),
            const SizedBox(height: 32),
            // Compute Button
            Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentGold,
                    AppTheme.accentGoldLight,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentGold.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _computeCompatibility,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryNavy),
                        ),
                      )
                    : const Text(
                        'Compute Compatibility',
                        style: TextStyle(
                          color: AppTheme.primaryNavy,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonSection(String title, int person) {
    final dateController = person == 1 ? _person1DateController : _person2DateController;
    final timeController = person == 1 ? _person1TimeController : _person2TimeController;
    final latController = person == 1 ? _person1LatController : _person2LatController;
    final lonController = person == 1 ? _person1LonController : _person2LonController;
    final selectedDate = person == 1 ? _person1Date : _person2Date;
    final selectedTime = person == 1 ? _person1Time : _person2Time;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              AppTheme.accentGold.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.accentGold,
                        AppTheme.accentGoldLight,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: dateController,
              readOnly: true,
              onTap: () {
                FocusScope.of(context).unfocus();
                _selectDate(person);
              },
              decoration: const InputDecoration(
                labelText: 'Date of Birth *',
                prefixIcon: Icon(Icons.calendar_today_rounded),
              ),
              validator: (value) {
                if (selectedDate == null) return 'Please select date';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: timeController,
              readOnly: true,
              onTap: () {
                FocusScope.of(context).unfocus();
                _selectTime(person);
              },
              decoration: const InputDecoration(
                labelText: 'Time of Birth *',
                prefixIcon: Icon(Icons.access_time_rounded),
              ),
              validator: (value) {
                if (selectedTime == null) return 'Please select time';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: latController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Latitude *',
                      prefixIcon: Icon(Icons.my_location_rounded),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      final lat = double.tryParse(value!);
                      if (lat == null || lat < -90 || lat > 90) {
                        return 'Invalid latitude';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: lonController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Longitude *',
                      prefixIcon: Icon(Icons.explore_rounded),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      final lon = double.tryParse(value!);
                      if (lon == null || lon < -180 || lon > 180) {
                        return 'Invalid longitude';
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

  Widget _buildResultView() {
    final score = _compatibilityResult!['score'] as num? ?? 0;
    final details = _compatibilityResult!['details'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Overall Score
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.accentGold,
                    AppTheme.accentGoldLight,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Compatibility Score',
                    style: TextStyle(
                      color: AppTheme.primaryNavy,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${score.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: AppTheme.primaryNavy,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryNavy),
                    minHeight: 8,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Details
          ...details.entries.map((entry) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.accentGold,
                        AppTheme.accentGoldLight,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    color: AppTheme.primaryNavy,
                  ),
                ),
                title: Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(entry.value.toString()),
              ),
            );
          }),
        ],
      ),
    );
  }
}

