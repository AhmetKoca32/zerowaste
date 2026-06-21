import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/pages/splash_page.dart';
import '../shell/main_tab_shell.dart';

abstract final class AppRouter {
  AppRouter._();

  static const String splash = '/splash';
  static const String home = '/';
  static const String recipeGenerator = '/generate';
  static const String chat = '/chat';
  static const String points = '/puan';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: <RouteBase>[
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
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
