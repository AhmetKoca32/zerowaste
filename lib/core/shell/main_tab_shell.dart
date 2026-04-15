import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import 'custom_bottom_nav.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/points/presentation/pages/points_page.dart';
import '../../features/recipe_generator/presentation/pages/recipe_generator_page.dart';

/// Current tab index (0 = Recipes, 1 = Generate, 2 = EcoChef, 3 = Puan).
final tabIndexProvider = StateProvider<int>((ref) => 0);

/// Single scaffold with AppBar tabs (Recipes | Generate | EcoChef).
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
    // Listen to the animation value so the navbar updates mid-swipe
    // (rounds to nearest tab as soon as user crosses the halfway point).
    _tabController.animation?.addListener(_onSwipeAnimation);
  }

  void _onSwipeAnimation() {
    // Skip during programmatic animateTo (navbar tap) — only react to swipe gestures
    if (_tabController.indexIsChanging) return;

    final roundedIndex = _tabController.animation!.value.round().clamp(0, 3);
    final current = ref.read(tabIndexProvider);
    if (current != roundedIndex) {
      ref.read(tabIndexProvider.notifier).state = roundedIndex;
    }
  }

  @override
  void dispose() {
    _tabController.animation?.removeListener(_onSwipeAnimation);
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
      appBar: currentIndex == 0
          ? AppBar(
              title: Text(
                AppConstants.appName,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          const HomePage(inTabs: true),
          const RecipeGeneratorPage(inTabs: true),
          const ChatPage(inTabs: true),
          const PointsPage(inTabs: true),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(tabIndexProvider.notifier).state = index;
          _tabController.animateTo(index);
        },
        items: const [
          CustomNavItem(assetPath: 'assets/images/icons/tarifler_icon.png', label: 'Tarifler'),
          CustomNavItem(assetPath: 'assets/images/icons/oluştur_icon.png', label: 'Oluştur'),
          CustomNavItem(assetPath: 'assets/images/icons/chat_icon.png', label: 'EcoChef'),
          CustomNavItem(assetPath: 'assets/images/icons/puan_icon.png', label: 'Puan'),
        ],
      ),
    );
  }
}
