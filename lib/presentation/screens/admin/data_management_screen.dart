import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../config/app_theme.dart';
import '../../../services/admin_service.dart';

class DataManagementScreen extends StatelessWidget {
  const DataManagementScreen({super.key});

  Future<void> _uploadServices(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        // In production, parse and upload JSON
        await AdminService.uploadServices([]);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Services uploaded successfully')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _uploadReports(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        // In production, parse and upload JSON
        await AdminService.uploadReports([]);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reports uploaded successfully')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
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
        title: const Text('Data Management'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.business_center, size: 40),
              title: const Text('Upload Services'),
              subtitle: const Text('Bulk upload services from JSON file'),
              trailing: const Icon(Icons.upload),
              onTap: () => _uploadServices(context),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.description, size: 40),
              title: const Text('Upload Reports'),
              subtitle: const Text('Bulk upload report templates from JSON file'),
              trailing: const Icon(Icons.upload),
              onTap: () => _uploadReports(context),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today, size: 40),
              title: const Text('Manage Panchang Data'),
              subtitle: const Text('Update Panchang calculation parameters'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to Panchang management
              },
            ),
          ),
        ],
      ),
    );
  }
}

