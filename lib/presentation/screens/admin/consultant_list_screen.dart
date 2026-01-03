import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_theme.dart';
import '../../../services/admin_service.dart';
import '../../../core/models/consultant_model.dart';
import 'consultant_detail_screen.dart';

final consultantsProvider = FutureProvider.family<List<ConsultantModel>, String?>((ref, status) async {
  return await AdminService.getConsultants(status: status);
});

class ConsultantListScreen extends ConsumerWidget {
  const ConsultantListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedStatus = ref.watch(_selectedStatusProvider);
    final consultantsAsync = ref.watch(consultantsProvider(selectedStatus));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Consultants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/admin/consultants/onboard'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _StatusFilterChip(
                  label: 'All',
                  value: null,
                  selected: selectedStatus == null,
                  onSelected: (value) {
                    ref.read(_selectedStatusProvider.notifier).state = null;
                  },
                ),
                const SizedBox(width: 8),
                _StatusFilterChip(
                  label: 'Pending',
                  value: 'pending',
                  selected: selectedStatus == 'pending',
                  onSelected: (value) {
                    ref.read(_selectedStatusProvider.notifier).state = 'pending';
                  },
                ),
                const SizedBox(width: 8),
                _StatusFilterChip(
                  label: 'Approved',
                  value: 'approved',
                  selected: selectedStatus == 'approved',
                  onSelected: (value) {
                    ref.read(_selectedStatusProvider.notifier).state = 'approved';
                  },
                ),
                const SizedBox(width: 8),
                _StatusFilterChip(
                  label: 'Rejected',
                  value: 'rejected',
                  selected: selectedStatus == 'rejected',
                  onSelected: (value) {
                    ref.read(_selectedStatusProvider.notifier).state = 'rejected';
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: consultantsAsync.when(
              data: (consultants) => consultants.isEmpty
                  ? const Center(child: Text('No consultants found'))
                  : ListView.builder(
                      itemCount: consultants.length,
                      itemBuilder: (context, index) {
                        final consultant = consultants[index];
                        return _ConsultantListItem(
                          consultant: consultant,
                          onTap: () => context.push(
                            '/admin/consultants/${consultant.id}',
                          ),
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

final _selectedStatusProvider = StateProvider<String?>((ref) => null);

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final String? value;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _StatusFilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
    );
  }
}

class _ConsultantListItem extends StatelessWidget {
  final ConsultantModel consultant;
  final VoidCallback onTap;

  const _ConsultantListItem({
    required this.consultant,
    required this.onTap,
  });

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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryBlue,
          child: Text(
            consultant.name?.substring(0, 1).toUpperCase() ?? 'C',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(consultant.name ?? 'Unknown'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (consultant.specialization != null)
              Text(consultant.specialization!),
            if (consultant.hourlyRate != null)
              Text('₹${consultant.hourlyRate!.toStringAsFixed(0)}/hr'),
          ],
        ),
        trailing: Chip(
          label: Text(
            consultant.status.toUpperCase(),
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
          backgroundColor: _getStatusColor(consultant.status),
        ),
        onTap: onTap,
      ),
    );
  }
}

