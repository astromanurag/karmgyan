import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_theme.dart';
import '../../../core/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1B2A),
              Color(0xFF1B263B),
              Color(0xFF415A77),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/home');
                          }
                        },
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      ),
                      Expanded(
                        child: Text(
                          'My Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.edit_outlined, color: AppTheme.accentGold),
                      ),
                    ],
                  ),
                ),
                
                // Profile Avatar with Glow
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow effect
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentGold.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    // Avatar
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppTheme.accentGold, AppTheme.accentGoldLight],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Center(
                        child: Text(
                          user?.name?[0].toUpperCase() ?? 'U',
                          style: TextStyle(
                            color: AppTheme.primaryNavy,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Badge
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(Icons.check, color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Name and email
                Text(
                  user?.name ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Member badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.accentGold.withOpacity(0.3), AppTheme.accentGoldLight.withOpacity(0.2)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.accentGold.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: AppTheme.accentGold, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Premium Member',
                        style: TextStyle(
                          color: AppTheme.accentGold,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Stats Row
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2D3A4A), Color(0xFF1F2833)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('3', 'Charts\nGenerated'),
                      _buildStatDivider(),
                      _buildStatItem('2', 'Consultations\nCompleted'),
                      _buildStatDivider(),
                      _buildStatItem('5', 'Reports\nDownloaded'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Quick Actions
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildQuickAction(
                          icon: Icons.auto_graph,
                          label: 'My Charts',
                          color: Color(0xFFFF6B6B),
                          onTap: () => context.push('/chart-demo'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickAction(
                          icon: Icons.receipt_long,
                          label: 'Orders',
                          color: Color(0xFF4ECDC4),
                          onTap: () => context.push('/orders'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickAction(
                          icon: Icons.description,
                          label: 'Reports',
                          color: Color(0xFF667EEA),
                          onTap: () => context.push('/reports'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Menu Items
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFF1F2833),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        subtitle: 'Update your personal information',
                        onTap: () {},
                      ),
                      _buildMenuDivider(),
                      _buildMenuItem(
                        icon: Icons.calendar_today,
                        title: 'Birth Details',
                        subtitle: 'Date, time, and place of birth',
                        onTap: () {},
                      ),
                      _buildMenuDivider(),
                      _buildMenuItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: 'Panchang alerts, horoscope updates',
                        onTap: () {},
                      ),
                      _buildMenuDivider(),
                      _buildMenuItem(
                        icon: Icons.language,
                        title: 'Language',
                        subtitle: 'English',
                        onTap: () {},
                      ),
                      _buildMenuDivider(),
                      _buildMenuItem(
                        icon: Icons.dark_mode_outlined,
                        title: 'Theme',
                        subtitle: 'Dark mode',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Support Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFF1F2833),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        subtitle: 'FAQs, contact us',
                        onTap: () {},
                      ),
                      _buildMenuDivider(),
                      _buildMenuItem(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        subtitle: 'Read our privacy policy',
                        onTap: () {},
                      ),
                      _buildMenuDivider(),
                      _buildMenuItem(
                        icon: Icons.info_outline,
                        title: 'About karmgyan',
                        subtitle: 'Version 1.0.0',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Logout Button
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).signOut();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.2),
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.red.withOpacity(0.3)),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, size: 20),
                        const SizedBox(width: 8),
                        Text('Log Out', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppTheme.accentGold,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.white24,
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.accentGold.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.accentGold, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white54,
          fontSize: 12,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white38),
      onTap: onTap,
    );
  }

  Widget _buildMenuDivider() {
    return Divider(
      height: 1,
      indent: 76,
      endIndent: 20,
      color: Colors.white.withOpacity(0.1),
    );
  }
}

