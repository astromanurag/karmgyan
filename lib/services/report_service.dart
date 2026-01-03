import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../config/app_config.dart';

class ReportService {
  static String get _baseUrl => AppConfig.backendUrl;

  // Generate PDF report
  static Future<void> generatePDFReport({
    required String title,
    required Map<String, dynamic> chartData,
    required Map<String, dynamic> reportData,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Birth Details',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            _buildReportSection(pdf, reportData),
            pw.SizedBox(height: 20),
            pw.Text(
              'Planetary Positions',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            _buildPlanetsTable(pdf, chartData['planets'] ?? {}),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.Widget _buildReportSection(
    pw.Document pdf,
    Map<String, dynamic> data,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: data.entries.map((entry) {
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Row(
            children: [
              pw.Text(
                '${entry.key}: ',
                style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(entry.value.toString()),
            ],
          ),
        );
      }).toList(),
    );
  }

  static pw.Widget _buildPlanetsTable(
    pw.Document pdf,
    Map<String, dynamic> planets,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Planet', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('House', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Sign', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        ...planets.entries.map((entry) {
          final planetData = entry.value as Map<String, dynamic>? ?? {};
          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(entry.key),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('${planetData['house'] ?? 'N/A'}'),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('${planetData['sign'] ?? 'N/A'}'),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  // Get available report types
  static Future<List<Map<String, dynamic>>> getReportTypes() async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return [
        {
          'id': 'birth_chart',
          'name': 'Birth Chart Report',
          'description': 'Detailed birth chart analysis',
          'price': 499,
        },
        {
          'id': 'dasha',
          'name': 'Dasha Report',
          'description': 'Planetary period predictions',
          'price': 599,
        },
        {
          'id': 'compatibility',
          'name': 'Compatibility Report',
          'description': 'Marriage compatibility analysis',
          'price': 799,
        },
      ];
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/reports/types'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['reports']);
    } else {
      throw Exception('Failed to fetch report types: ${response.body}');
    }
  }

  // Generate report
  static Future<Map<String, dynamic>> generateReport({
    required String reportType,
    required Map<String, dynamic> birthData,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(seconds: 2));
      return {
        'report_id': 'report_${DateTime.now().millisecondsSinceEpoch}',
        'type': reportType,
        'content': 'This is a sample report content...',
        'generated_at': DateTime.now().toIso8601String(),
      };
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/reports/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'type': reportType,
        'birth_data': birthData,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate report: ${response.body}');
    }
  }
}

