import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../providers/admin_providers.dart';

/// Wraps admin pages and redirects to login if not authenticated or not admin.
class AdminGuard extends ConsumerWidget {
  const AdminGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(adminUserProvider);
    final isAdminAsync = ref.watch(isAdminProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go(AppRouter.adminLogin);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return isAdminAsync.when(
          data: (isAdmin) {
            if (!isAdmin) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) context.go(AppRouter.adminLogin);
              });
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return child;
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) context.go(AppRouter.adminLogin);
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.go(AppRouter.adminLogin);
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
