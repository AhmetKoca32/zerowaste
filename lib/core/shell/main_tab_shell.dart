import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import 'custom_bottom_nav.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/points/presentation/pages/points_page.dart';
import '../../features/recipe_generator/presentation/pages/recipe_generator_page.dart';

/// Current tab index (0 = Recipes, 1 = Generate, 2 = Leafy, 3 = Puan).
final tabIndexProvider = StateProvider<int>((ref) => 0);

/// Single scaffold with AppBar tabs (Recipes | Generate | Leafy).
class MainTabShell extends ConsumerStatefulWidget {
  const MainTabShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  ConsumerState<MainTabShell> createState() => _MainTabShellState();
}

class _MainTabShellState extends ConsumerState<MainTabShell>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialIndex.clamp(0, 3),
    );
    _tabController.addListener(_syncIndexToProvider);
  }

  void _syncIndexToProvider() {
    if (!_tabController.indexIsChanging) {
      ref.read(tabIndexProvider.notifier).state = _tabController.index;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_syncIndexToProvider);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(tabIndexProvider).clamp(0, 3);
    ref.listen<int>(tabIndexProvider, (int? prev, int next) {
      if (prev != next && _tabController.index != next) {
        _tabController.animateTo(next);
      }
    });
    // Sync provider to controller when shell opens with initialIndex (e.g. /generate)
    if (ref.read(tabIndexProvider) != _tabController.index) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(tabIndexProvider.notifier).state = _tabController.index;
      });
    }

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: const TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          HomePage(inTabs: true),
          RecipeGeneratorPage(inTabs: true),
          ChatPage(inTabs: true),
          PointsPage(inTabs: true),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(tabIndexProvider.notifier).state = index;
          _tabController.animateTo(index);
        },
        items: const [
          CustomNavItem(icon: Icons.menu_book, label: 'Tarifler'),
          CustomNavItem(icon: Icons.eco, label: 'Oluştur'),
          CustomNavItem(icon: Icons.chat_bubble_outline, label: 'Leafy'),
          CustomNavItem(icon: Icons.emoji_events_outlined, label: 'Puan'),
        ],
      ),
    );
  }
}
