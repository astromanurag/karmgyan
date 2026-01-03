import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../services/consultant_service.dart';

final consultantDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await ConsultantService.getDashboardData();
});

class ConsultantDashboardScreen extends ConsumerWidget {
  const ConsultantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(consultantDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultant Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: dashboardAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Upcoming',
                      value: '${data['upcoming_consultations'] ?? 0}',
                      icon: Icons.event,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'Pending',
                      value: '${data['pending_requests'] ?? 0}',
                      icon: Icons.pending,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'This Month',
                      value: '₹${((data['earnings_summary']?['this_month'] ?? 0) as num).toStringAsFixed(0)}',
                      icon: Icons.currency_rupee,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'Total',
                      value: '₹${((data['earnings_summary']?['total'] ?? 0) as num).toStringAsFixed(0)}',
                      icon: Icons.account_balance_wallet,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Today\'s Schedule',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              if (data['today_schedule'] != null)
                ...(data['today_schedule'] as List).map((schedule) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryBlue,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(schedule['client_name'] ?? 'Unknown'),
                      subtitle: Text('${schedule['time']} - ${schedule['type']}'),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        // Navigate to consultation room
                      },
                    ),
                  );
                }).toList(),
              const SizedBox(height: 32),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _ActionCard(
                    title: 'Schedule',
                    icon: Icons.calendar_today,
                    onTap: () => context.push('/consultant/schedule'),
                  ),
                  _ActionCard(
                    title: 'Consultations',
                    icon: Icons.video_call,
                    onTap: () => context.push('/consultant/consultations'),
                  ),
                  _ActionCard(
                    title: 'Earnings',
                    icon: Icons.payments,
                    onTap: () => context.push('/consultant/earnings'),
                  ),
                  _ActionCard(
                    title: 'Profile',
                    icon: Icons.person,
                    onTap: () => context.push('/consultant/profile'),
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
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: AppTheme.primaryBlue),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

