import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/locale_provider.dart';
import '../theme/app_colors.dart';
import 'custom_bottom_nav.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/points/presentation/pages/points_page.dart';
import '../../features/recipe_generator/presentation/pages/recipe_generator_page.dart';
import '../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
              centerTitle: true,
              title: Text(
                l10n.appName,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: _LocaleToggle(),
                ),
              ],
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
        items: [
          CustomNavItem(
            assetPath: 'assets/images/icons/tarifler_icon.png',
            label: l10n.navRecipes,
          ),
          CustomNavItem(
            assetPath: 'assets/images/icons/oluştur_icon.png',
            label: l10n.navCreate,
          ),
          CustomNavItem(
            assetPath: 'assets/images/icons/chat_icon.png',
            label: l10n.navEcoChef,
          ),
          CustomNavItem(
            assetPath: 'assets/images/icons/puan_icon.png',
            label: l10n.navPoints,
          ),
        ],
      ),
    );
  }
}

/// Animated locale toggle button showing TR / EN with crossfade.
class _LocaleToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isTurkish = locale.languageCode == 'tr';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        ref.read(localeProvider.notifier).toggle();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: AppColors.brandOrange.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: animation,
                child: child,
              ),
            );
          },
          child: Text(
            isTurkish ? 'TR' : 'EN',
            key: ValueKey(isTurkish),
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.brandOrange,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}