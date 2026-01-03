import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_theme.dart';
import '../../../services/data_service.dart';

class YearlyForecastScreen extends ConsumerStatefulWidget {
  const YearlyForecastScreen({super.key});

  @override
  ConsumerState<YearlyForecastScreen> createState() =>
      _YearlyForecastScreenState();
}

class _YearlyForecastScreenState extends ConsumerState<YearlyForecastScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _forecastData;

  @override
  void initState() {
    super.initState();
    _loadForecast();
  }

  Future<void> _loadForecast() async {
    setState(() => _isLoading = true);

    try {
      // Load from mock data
      final dataService = DataService();
      final predictions = await dataService.getPredictions();
      setState(() {
        _forecastData = predictions['yearly_forecast'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yearly Forecast'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _forecastData == null
              ? const Center(child: Text('No forecast data available'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        color: AppTheme.primaryBlue,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Year ${_forecastData!['year'] ?? DateTime.now().year}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _forecastData!['overview'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Predictions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      if (_forecastData!['predictions'] != null)
                        ...(_forecastData!['predictions'] as Map<String, dynamic>)
                            .entries
                            .map((entry) {
                          return _PredictionCard(
                            category: entry.key,
                            prediction: entry.value as String,
                          );
                        }).toList(),
                      const SizedBox(height: 24),
                      Text(
                        'Important Dates',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      if (_forecastData!['important_dates'] != null)
                        ...(_forecastData!['important_dates'] as List).map((date) {
                          return _ImportantDateCard(date: date);
                        }).toList(),
                    ],
                  ),
                ),
    );
  }
}

class _PredictionCard extends StatelessWidget {
  final String category;
  final String prediction;

  const _PredictionCard({
    required this.category,
    required this.prediction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.accentGold,
          child: Text(
            category[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          category.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(prediction),
      ),
    );
  }
}

class _ImportantDateCard extends StatelessWidget {
  final Map<String, dynamic> date;

  const _ImportantDateCard({required this.date});

  Color _getColorForType(String? type) {
    switch (type) {
      case 'auspicious':
        return Colors.green;
      case 'caution':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          date['type'] == 'auspicious' ? Icons.check_circle : Icons.warning,
          color: _getColorForType(date['type']),
        ),
        title: Text(date['date'] ?? ''),
        subtitle: Text(date['event'] ?? ''),
        trailing: Chip(
          label: Text(
            date['type']?.toUpperCase() ?? '',
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
          backgroundColor: _getColorForType(date['type']),
        ),
      ),
    );
  }
}

