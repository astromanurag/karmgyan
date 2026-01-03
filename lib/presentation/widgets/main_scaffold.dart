import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const MainScaffold({
    super.key,
    required this.child,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1F3C),
              Color(0xFF0D1120),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  isActive: currentIndex == 0,
                  onTap: () => context.go('/home'),
                ),
                _NavItem(
                  icon: Icons.auto_graph_outlined,
                  activeIcon: Icons.auto_graph,
                  label: 'Charts',
                  isActive: currentIndex == 1,
                  onTap: () => context.go('/chart-demo'),
                ),
                _NavItem(
                  icon: Icons.headset_mic_outlined,
                  activeIcon: Icons.headset_mic,
                  label: 'Consult',
                  isActive: currentIndex == 2,
                  onTap: () => context.go('/consultations'),
                  isCenter: true,
                ),
                _NavItem(
                  icon: Icons.calendar_today_outlined,
                  activeIcon: Icons.calendar_today,
                  label: 'Panchang',
                  isActive: currentIndex == 3,
                  onTap: () => context.go('/calendar'),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  isActive: currentIndex == 4,
                  onTap: () => context.go('/profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isCenter;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCenter) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isActive
                  ? [AppTheme.accentGold, AppTheme.accentGoldLight]
                  : [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (isActive ? AppTheme.accentGold : Color(0xFF667EEA)).withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            isActive ? activeIcon : icon,
            color: isActive ? AppTheme.primaryNavy : Colors.white,
            size: 26,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accentGold.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppTheme.accentGold : Colors.white54,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppTheme.accentGold : Colors.white54,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
