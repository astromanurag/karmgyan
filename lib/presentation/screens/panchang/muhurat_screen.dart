import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_theme.dart';
import '../../../services/panchang_service.dart';

class MuhuratScreen extends ConsumerStatefulWidget {
  const MuhuratScreen({super.key});

  @override
  ConsumerState<MuhuratScreen> createState() => _MuhuratScreenState();
}

class _MuhuratScreenState extends ConsumerState<MuhuratScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedEventType = 'general';
  bool _isLoading = false;
  Map<String, dynamic>? _muhuratData;

  final List<Map<String, String>> _eventTypes = [
    {'value': 'general', 'label': 'General'},
    {'value': 'marriage', 'label': 'Marriage'},
    {'value': 'business', 'label': 'Business'},
    {'value': 'travel', 'label': 'Travel'},
    {'value': 'house_warming', 'label': 'House Warming'},
  ];

  Future<void> _findMuhurat() async {
    setState(() => _isLoading = true);

    try {
      final result = await PanchangService().getMuhurat(
        date: _selectedDate,
        latitude: 28.6139, // Default to Delhi
        longitude: 77.2090,
        eventType: _selectedEventType,
      );

      setState(() {
        _muhuratData = result;
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muhurat Finder'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Event Type',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _eventTypes.map((type) {
                        final isSelected = _selectedEventType == type['value'];
                        return FilterChip(
                          label: Text(type['label']!),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedEventType = type['value']!);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select Date',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 12),
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _findMuhurat,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Find Muhurat'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_muhuratData != null) ...[
              const SizedBox(height: 24),
              Text(
                'Auspicious Timings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              if (_muhuratData!['muhurats'] != null)
                ...(_muhuratData!['muhurats'] as List).map((muhurat) {
                  return _MuhuratCard(muhurat: muhurat);
                }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}

class _MuhuratCard extends StatelessWidget {
  final Map<String, dynamic> muhurat;

  const _MuhuratCard({required this.muhurat});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: const Icon(Icons.access_time, color: Colors.white),
        ),
        title: Text(
          muhurat['time'] ?? 'N/A',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(muhurat['description'] ?? ''),
        trailing: Chip(
          label: Text(
            muhurat['quality']?.toUpperCase() ?? 'GOOD',
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
          backgroundColor: muhurat['quality'] == 'excellent'
              ? Colors.green
              : Colors.blue,
        ),
      ),
    );
  }
}

