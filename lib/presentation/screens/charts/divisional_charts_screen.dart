import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_theme.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../services/computation_service.dart';
import '../../widgets/divisional_chart_grid.dart';

class DivisionalChartsScreen extends ConsumerStatefulWidget {
  const DivisionalChartsScreen({super.key});

  @override
  ConsumerState<DivisionalChartsScreen> createState() => _DivisionalChartsScreenState();
}

class _DivisionalChartsScreenState extends ConsumerState<DivisionalChartsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  Map<String, dynamic>? _storedBirthData;
  Map<String, dynamic>? _chartsData;

  @override
  void initState() {
    super.initState();
    _loadStoredBirthData();
  }

  Future<void> _loadStoredBirthData() async {
    final birthData = LocalStorageService.get('birth_data');
    if (birthData != null && birthData is Map<String, dynamic>) {
      setState(() {
        _storedBirthData = birthData;
        final dateStr = birthData['date'] as String? ?? '';
        final timeStr = birthData['time'] as String? ?? '';
        
        if (dateStr.isNotEmpty) {
          final dateParts = dateStr.split('-');
          if (dateParts.length == 3) {
            _selectedDate = DateTime(
              int.parse(dateParts[0]),
              int.parse(dateParts[1]),
              int.parse(dateParts[2]),
            );
            _dateController.text = '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
          }
        }
        
        if (timeStr.isNotEmpty) {
          final timeParts = timeStr.split(':');
          if (timeParts.length >= 2) {
            _selectedTime = TimeOfDay(
              hour: int.parse(timeParts[0]),
              minute: int.parse(timeParts[1]),
            );
            _timeController.text = '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
          }
        }
        
        _latitudeController.text = (birthData['latitude'] as num?)?.toString() ?? '';
        _longitudeController.text = (birthData['longitude'] as num?)?.toString() ?? '';
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _generateCharts() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _chartsData = null;
    });

    try {
      final lat = double.parse(_latitudeController.text);
      final lon = double.parse(_longitudeController.text);
      
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final result = await ComputationService().generateDivisionalCharts(
        date: dateTime,
        latitude: lat,
        longitude: lon,
      );

      setState(() {
        _chartsData = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Divisional Charts'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _chartsData == null
            ? Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
              if (_storedBirthData != null)
                Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  color: AppTheme.accentGold.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.accentGold),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Using birth data from your birth chart. You can modify if needed.',
                            style: TextStyle(
                              color: AppTheme.primaryNavy,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: () {
                  FocusScope.of(context).unfocus();
                  _selectDate();
                },
                decoration: const InputDecoration(
                  labelText: 'Date of Birth *',
                  prefixIcon: Icon(Icons.calendar_today_rounded),
                ),
                validator: (value) {
                  if (_selectedDate == null) return 'Please select date';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeController,
                readOnly: true,
                onTap: () {
                  FocusScope.of(context).unfocus();
                  _selectTime();
                },
                decoration: const InputDecoration(
                  labelText: 'Time of Birth *',
                  prefixIcon: Icon(Icons.access_time_rounded),
                ),
                validator: (value) {
                  if (_selectedTime == null) return 'Please select time';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
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
                      controller: _longitudeController,
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _generateCharts,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Generate Divisional Charts'),
              ),
                  ],
                ),
              )
            : _buildChartsView(),
      ),
    );
  }

  Widget _buildChartsView() {
    final charts = _chartsData!['charts'] as Map<String, dynamic>? ?? {};
    final hasError = _chartsData!['success'] == false;
    final errorMessage = _chartsData!['error'] as String?;

    if (hasError) {
      return Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error Generating Charts',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage ?? 'Unknown error occurred',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _chartsData = null;
                  });
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Divisional Charts (D1-D16)',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: DivisionalChartGrid(charts: charts),
        ),
      ],
    );
  }
}

