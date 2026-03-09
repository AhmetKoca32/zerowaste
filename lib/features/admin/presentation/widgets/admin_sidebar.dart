import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';

/// Desktop-friendly sidebar for admin panel.
class AdminSidebar extends StatelessWidget {
  const AdminSidebar({
    super.key,
    required this.currentPath,
    required this.child,
    this.onLogout,
  });

  final String currentPath;
  final Widget child;
  final VoidCallback? onLogout;

  static const double sidebarWidth = 260;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: sidebarWidth,
          decoration: BoxDecoration(
            color: AppColors.brandOrange,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.eco, color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    'ZeroWaste Admin',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _NavItem(
                icon: Icons.dashboard_outlined,
                label: 'Tarifler',
                isSelected: currentPath == AppRouter.adminDashboard ||
                    currentPath.startsWith('${AppRouter.adminDashboard}/'),
                onTap: () => context.go(AppRouter.adminDashboard),
              ),
              _NavItem(
                icon: Icons.add_circle_outline,
                label: 'Yeni Tarif',
                isSelected: currentPath == AppRouter.adminRecipeNew,
                onTap: () => context.go(AppRouter.adminRecipeNew),
              ),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white70, size: 22),
                title: Text(
                  'Çıkış Yap',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                onTap: () {
                  onLogout?.call();
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white70,
            size: 22,
          ),
          title: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
