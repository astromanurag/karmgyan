import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_theme.dart';
import '../../../services/admin_service.dart';
import '../../../core/models/consultant_model.dart';

final consultantProvider = FutureProvider.family<ConsultantModel, String>((ref, id) async {
  return await AdminService.getConsultant(id);
});

class ConsultantDetailScreen extends ConsumerWidget {
  final String consultantId;

  const ConsultantDetailScreen({
    super.key,
    required this.consultantId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consultantAsync = ref.watch(consultantProvider(consultantId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultant Details'),
      ),
      body: consultantAsync.when(
        data: (consultant) => SingleChildScrollView(
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
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppTheme.primaryBlue,
                            child: Text(
                              consultant.name?.substring(0, 1).toUpperCase() ?? 'C',
                              style: const TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  consultant.name ?? 'Unknown',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 4),
                                Chip(
                                  label: Text(consultant.status.toUpperCase()),
                                  backgroundColor: _getStatusColor(consultant.status),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      _DetailRow('Specialization', consultant.specialization ?? 'N/A'),
                      _DetailRow('Experience', '${consultant.experienceYears ?? 0} years'),
                      _DetailRow('Hourly Rate', '₹${consultant.hourlyRate?.toStringAsFixed(0) ?? '0'}/hr'),
                      if (consultant.bio != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Bio',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(consultant.bio!),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (consultant.status == 'pending')
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await AdminService.approveConsultant(consultant.id);
                            if (context.mounted) {
                              ref.invalidate(consultantProvider(consultant.id));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Consultant approved')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          // Show reject dialog
                          final reason = await showDialog<String>(
                            context: context,
                            builder: (context) => _RejectDialog(),
                          );
                          if (reason != null) {
                            try {
                              await AdminService.rejectConsultant(
                                consultant.id,
                                reason,
                              );
                              if (context.mounted) {
                                ref.invalidate(consultantProvider(consultant.id));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Consultant rejected')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          }
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Reject'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _RejectDialog extends StatefulWidget {
  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reject Consultant'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Reason for rejection',
          hintText: 'Enter reason...',
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              Navigator.pop(context, _controller.text);
            }
          },
          child: const Text('Reject'),
        ),
      ],
    );
  }
}

