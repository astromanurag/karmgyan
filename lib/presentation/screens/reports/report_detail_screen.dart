import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_theme.dart';
import '../../../services/report_service.dart';

class ReportDetailScreen extends ConsumerStatefulWidget {
  final String reportType;
  final Map<String, dynamic>? birthData;

  const ReportDetailScreen({
    super.key,
    required this.reportType,
    this.birthData,
  });

  @override
  ConsumerState<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen> {
  bool _isGenerating = false;
  Map<String, dynamic>? _reportData;

  Future<void> _generateReport() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final report = await ReportService.generateReport(
        reportType: widget.reportType,
        birthData: widget.birthData ?? {},
      );
      setState(() {
        _reportData = report;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _exportPDF() async {
    if (_reportData == null) return;

    try {
      await ReportService.generatePDFReport(
        title: 'Astrological Report',
        chartData: {},
        reportData: _reportData!,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF export failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        actions: [
          if (_reportData != null)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _exportPDF,
              tooltip: 'Export PDF',
            ),
        ],
      ),
      body: _reportData == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description,
                    size: 64,
                    color: AppTheme.primaryBlue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Generate Report',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isGenerating ? null : _generateReport,
                    child: _isGenerating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Generate Report'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
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
                            'Report Content',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _reportData!['content'] ?? 'No content available',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _exportPDF,
                      icon: const Icon(Icons.download),
                      label: const Text('Download PDF'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

