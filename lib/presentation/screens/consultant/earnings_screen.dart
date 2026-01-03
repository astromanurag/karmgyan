import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_theme.dart';
import '../../../services/consultant_service.dart';

final earningsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await ConsultantService.getEarnings();
});

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earningsAsync = ref.watch(earningsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
      ),
      body: earningsAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: AppTheme.primaryBlue,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Total Earnings',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${((data['total'] ?? 0) as num).toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Pending Payout',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
                                    ),
                              ),
                              Text(
                                '₹${((data['pending_payout'] ?? 0) as num).toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Earnings History',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              if (data['earnings'] != null)
                ...(data['earnings'] as List).map((earning) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: const Icon(Icons.currency_rupee, color: Colors.white),
                      ),
                      title: Text(earning['client_name'] ?? 'Unknown'),
                      subtitle: Text(
                        DateTime.parse(earning['date']).toString().split(' ')[0],
                      ),
                      trailing: Text(
                        '₹${((earning['amount'] ?? 0) as num).toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                      ),
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

