import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_login_page.dart';
import '../../features/admin/presentation/pages/admin_recipe_edit_page.dart';
import '../shell/main_tab_shell.dart';

abstract final class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String recipeGenerator = '/generate';
  static const String chat = '/chat';
  static const String points = '/puan';

  static const String adminLogin = '/admin/login';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminRecipeNew = '/admin/recipes/new';
  static String adminRecipeEdit(String id) => '/admin/recipes/$id';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: <RouteBase>[
      GoRoute(
        path: home,
        name: 'home',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const MainTabShell(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: recipeGenerator,
        name: 'recipeGenerator',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const MainTabShell(initialIndex: 1),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: chat,
        name: 'chat',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const MainTabShell(initialIndex: 2),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: points,
        name: 'points',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const MainTabShell(initialIndex: 3),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: adminLogin,
        name: 'adminLogin',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const AdminLoginPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: '/admin/dashboard',
        name: 'adminDashboard',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const AdminDashboardPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: '/admin/recipes/new',
        name: 'adminRecipeNew',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const AdminRecipeEditPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: '/admin/recipes/:id',
        name: 'adminRecipeEdit',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: AdminRecipeEditPage(recipeId: id.isEmpty ? null : id),
            transitionsBuilder: _slideTransition,
          );
        },
      ),
    ],
  );

  static Widget _slideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.05, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    );
  }
}
