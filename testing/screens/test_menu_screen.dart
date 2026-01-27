import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../lib/config/app_theme.dart';
import '../constants/test_data.dart';
import '../../lib/core/services/local_storage_service.dart' as storage;

/// Test Menu Screen for Local UI Testing
/// Provides quick access to all major screens with pre-filled sample data
/// 
/// NOTE: This screen is for local development/testing only.
/// It should NOT be included in production builds.
class TestMenuScreen extends StatelessWidget {
  const TestMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Menu - Local UI Testing'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: AppTheme.accentGold.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.primaryBlue),
                        const SizedBox(width: 8),
                        Text(
                          'Test Menu',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This menu provides quick access to all screens with pre-filled sample data for local testing.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Astrology',
              Icons.stars,
              [
                _TestButton(
                  label: 'Birth Chart',
                  icon: Icons.account_circle,
                  onTap: () => _navigateToBirthChart(context),
                  requiresBackend: true,
                ),
                _TestButton(
                  label: 'Dasha Predictions',
                  icon: Icons.timeline,
                  onTap: () => context.push('/predictions/dasha'),
                  requiresBackend: true,
                ),
                _TestButton(
                  label: 'Panchang (Calendar)',
                  icon: Icons.calendar_today,
                  onTap: () => _navigateToPanchang(context),
                  requiresBackend: true,
                ),
                _TestButton(
                  label: 'Kundli Milan (Compatibility)',
                  icon: Icons.favorite,
                  onTap: () => _navigateToKundliMilan(context),
                  requiresBackend: true,
                ),
                _TestButton(
                  label: 'Divisional Charts',
                  icon: Icons.pie_chart,
                  onTap: () => context.push('/divisional-charts'),
                  requiresBackend: true,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Numerology',
              Icons.numbers,
              [
                _TestButton(
                  label: 'Name Analysis',
                  icon: Icons.person,
                  onTap: () => _navigateToNumerology(context),
                  requiresBackend: false,
                ),
                _TestButton(
                  label: 'Number Compatibility',
                  icon: Icons.compare_arrows,
                  onTap: () => _navigateToNumerologyCompatibility(context),
                  requiresBackend: false,
                ),
                _TestButton(
                  label: 'Name Suggestions',
                  icon: Icons.lightbulb,
                  onTap: () => _navigateToNumerologySuggestions(context),
                  requiresBackend: false,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Services',
              Icons.shopping_bag,
              [
                _TestButton(
                  label: 'Services Catalog',
                  icon: Icons.store,
                  onTap: () => context.push('/services'),
                  requiresBackend: false,
                ),
                _TestButton(
                  label: 'Orders',
                  icon: Icons.receipt,
                  onTap: () => context.push('/orders'),
                  requiresBackend: false,
                ),
                _TestButton(
                  label: 'Reports',
                  icon: Icons.description,
                  onTap: () => context.push('/reports'),
                  requiresBackend: false,
                ),
                _TestButton(
                  label: 'Consultations',
                  icon: Icons.video_call,
                  onTap: () => context.push('/consultations'),
                  requiresBackend: false,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'AI & Predictions',
              Icons.psychology,
              [
                _TestButton(
                  label: 'AI Hub',
                  icon: Icons.smart_toy,
                  onTap: () => context.push('/ai'),
                  requiresBackend: true,
                ),
                _TestButton(
                  label: 'Daily Horoscope',
                  icon: Icons.wb_sunny,
                  onTap: () => context.push('/horoscope?sign=Aries'),
                  requiresBackend: true,
                ),
                _TestButton(
                  label: 'Yearly Forecast',
                  icon: Icons.calendar_view_year,
                  onTap: () => context.push('/predictions/yearly'),
                  requiresBackend: true,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Authentication',
              Icons.lock,
              [
                _TestButton(
                  label: 'Login',
                  icon: Icons.login,
                  onTap: () => context.push('/login'),
                  requiresBackend: false,
                ),
                _TestButton(
                  label: 'Sign Up',
                  icon: Icons.person_add,
                  onTap: () => context.push('/signup'),
                  requiresBackend: false,
                ),
                _TestButton(
                  label: 'Profile',
                  icon: Icons.account_circle,
                  onTap: () => context.push('/profile'),
                  requiresBackend: false,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _clearAllData(context),
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear All Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<_TestButton> buttons,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryBlue, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...buttons.map((button) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: button,
            )),
      ],
    );
  }

  void _navigateToBirthChart(BuildContext context) {
    final data = TestData.birthChartData;
    context.push('/birth-chart', extra: data);
  }

  void _navigateToPanchang(BuildContext context) {
    final data = TestData.panchangData;
    context.push('/calendar', extra: data);
  }

  void _navigateToKundliMilan(BuildContext context) {
    final person1 = TestData.kundliMilanPerson1;
    final person2 = TestData.kundliMilanPerson2;
    context.push('/kundli-milan', extra: {
      'person1': person1,
      'person2': person2,
    });
  }

  void _navigateToNumerology(BuildContext context) {
    final data = TestData.numerologyNameData;
    context.push('/numerology', extra: data);
  }

  void _navigateToNumerologyCompatibility(BuildContext context) {
    final data = TestData.numerologyCompatibilityData;
    context.push('/numerology', extra: {'mode': 'compatibility', ...data});
  }

  void _navigateToNumerologySuggestions(BuildContext context) {
    final data = TestData.numerologySuggestionsData;
    context.push('/numerology', extra: {'mode': 'suggestions', ...data});
  }

  void _clearAllData(BuildContext context) {
    // Clear local storage data
    storage.LocalStorageService.clear();
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All local data cleared'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _TestButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool requiresBackend;

  const _TestButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.requiresBackend = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryBlue),
        title: Text(label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (requiresBackend)
              Tooltip(
                message: 'Requires backend API',
                child: Icon(
                  Icons.cloud,
                  size: 16,
                  color: Colors.orange,
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

