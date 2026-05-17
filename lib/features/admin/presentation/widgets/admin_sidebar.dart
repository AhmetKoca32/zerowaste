import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';

/// Responsive admin shell — single Scaffold, no nesting.
/// Desktop: sidebar | content  | Mobile: hamburger -> drawer | content
class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.title,
    required this.currentPath,
    required this.body,
    this.onLogout,
    this.actions,
  });

  final String title;
  final String currentPath;
  final Widget body;
  final VoidCallback? onLogout;
  final List<Widget>? actions;

  static const double sidebarWidth = 260;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;

        if (isWide) {
          // ── Desktop: Row(sidebar | page) ──
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSidebar(context, currentPath, onLogout),
              Expanded(
                child: Scaffold(
                  backgroundColor: AppColors.cream,
                  appBar: _buildAppBar(context),
                  body: body,
                ),
              ),
            ],
          );
        }

        // ── Mobile: single Scaffold with drawer ──
        return Scaffold(
          backgroundColor: AppColors.cream,
          appBar: _buildAppBar(context),
          drawer: Drawer(
            child: Container(
              color: AppColors.brandOrange,
              child: _buildSidebarContent(context, currentPath, onLogout),
            ),
          ),
          body: body,
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.white,
      foregroundColor: AppColors.ink,
      elevation: 0,
      actions: actions,
    );
  }

  static Widget _buildSidebar(
    BuildContext context,
    String path,
    VoidCallback? onLogout,
  ) {
    return Container(
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
      child: _buildSidebarContent(context, path, onLogout),
    );
  }

  static Widget _buildSidebarContent(
    BuildContext context,
    String currentPath,
    VoidCallback? onLogout,
  ) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.eco, color: Colors.white, size: 28),
            const SizedBox(width: 10),
            const Text(
              'Atıksız Admin',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
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
          onTap: () => _navigate(context, AppRouter.adminDashboard),
        ),
        _NavItem(
          icon: Icons.add_circle_outline,
          label: 'Yeni Tarif',
          isSelected: currentPath == AppRouter.adminRecipeNew,
          onTap: () => _navigate(context, AppRouter.adminRecipeNew),
        ),
        _NavItem(
          icon: Icons.pending_actions_outlined,
          label: 'Gönderiler',
          isSelected: currentPath == AppRouter.adminPosts,
          onTap: () => _navigate(context, AppRouter.adminPosts),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.maybePop(context);
              onLogout?.call();
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.white70, size: 22),
                  SizedBox(width: 12),
                  Text(
                    'Çıkış Yap',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  static void _navigate(BuildContext context, String route) {
    context.go(route);
    Navigator.maybePop(context); // close drawer on mobile
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
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.white70,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
