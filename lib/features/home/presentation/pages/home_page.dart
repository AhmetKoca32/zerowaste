import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/shell/main_tab_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_placeholder.dart';
import '../../data/models/recipe.dart';
import '../providers/home_providers.dart';
import '../widgets/ingredient_filter_sheet.dart';
import '../widgets/recipe_blog_card.dart';
import '../widgets/recipe_detail_sheet.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, this.inTabs = false});

  final bool inTabs;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _searchQuery = '';
  Set<String> _selectedIngredients = {};

  int _matchCount(Recipe recipe) {
    if (_selectedIngredients.isEmpty) return 0;
    return recipe.ingredients
        .where((i) => _selectedIngredients.contains(i))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(recipeListProvider);

    final body = recipesAsync.when(
      data: (recipes) {
        if (recipes.isEmpty) {
          return EmptyPlaceholder(
            icon: Icons.menu_book,
            message: 'Henüz tarif yok. Malzeme ekleyip bir tarif oluşturun!',
            action: FilledButton.icon(
              onPressed: () {
                if (widget.inTabs) {
                  ref.read(tabIndexProvider.notifier).state = 1;
                } else {
                  context.go(AppRouter.recipeGenerator);
                }
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text(
                'Tarif Oluştur',
                style: TextStyle(fontFamily: 'Manrope'),
              ),
            ),
          );
        }

        final allIngredients = recipes
            .expand((r) => r.ingredients)
            .toSet()
            .toList()
          ..sort();

        var filtered = _searchQuery.isEmpty
            ? recipes.toList()
            : recipes.where((r) {
                final q = _searchQuery.toLowerCase();
                return r.title.toLowerCase().contains(q) ||
                    r.ingredients.any((i) => i.toLowerCase().contains(q));
              }).toList();

        if (_selectedIngredients.isNotEmpty) {
          filtered.sort((a, b) {
            final aMatch = _matchCount(a);
            final bMatch = _matchCount(b);
            return bMatch.compareTo(aMatch);
          });
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
          itemCount: filtered.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                children: [
                  _buildSearchBar(allIngredients),
                  _buildSelectedChips(),
                  const SizedBox(height: 12),
                ],
              );
            }
            final recipe = filtered[index - 1];
            return InkWell(
              onTap: () => showRecipeDetailSheet(context, recipe: recipe),
              borderRadius: BorderRadius.circular(20),
              child: RecipeBlogCard(
                recipe: recipe,
                matchCount: _matchCount(recipe),
                totalSelected: _selectedIngredients.length,
              ),
            );
          },
        );
      },
      loading: () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppColors.brandOrange,
              strokeWidth: 2.5,
            ),
            const SizedBox(height: 16),
            Text(
              'Tarifler yükleniyor…',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'Manrope',
                color: AppColors.inkLight,
              ),
            ),
          ],
        ),
      ),
      error: (err, stack) => EmptyPlaceholder(
        icon: Icons.error_outline,
        message: 'Tarifler yüklenemedi.\n$err',
        action: TextButton.icon(
          onPressed: () => ref.invalidate(recipeListProvider),
          icon: const Icon(Icons.refresh),
          label: const Text(
            'Tekrar Dene',
            style: TextStyle(fontFamily: 'Manrope'),
          ),
        ),
      ),
    );

    if (widget.inTabs) return body;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: const TextStyle(
            fontFamily: 'Manrope',
            color: AppColors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.eco),
            onPressed: () => context.go(AppRouter.recipeGenerator),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => context.go(AppRouter.chat),
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _buildSelectedChips() {
    if (_selectedIngredients.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _selectedIngredients.length + 1,
          itemBuilder: (context, index) {
            if (index == _selectedIngredients.length) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedIngredients.clear()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.stone.withOpacity(0.5)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close, size: 14, color: AppColors.inkLight),
                        SizedBox(width: 4),
                        Text(
                          'Temizle',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.inkLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            final ingredient = _selectedIngredients.elementAt(index);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedIngredients.remove(ingredient)),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandOrange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ingredient,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.close, size: 12, color: Colors.white70),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar(List<String> allIngredients) {
    final radius = BorderRadius.circular(50);
    final hasFilter = _selectedIngredients.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: radius,
                border: Border.all(
                  color: const Color(0xFFE8E8E8),
                  width: 0.5,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.05),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.02),
                    ],
                    stops: const [0.0, 0.15, 0.85, 1.0],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: radius,
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    style: const TextStyle(fontFamily: 'Manrope', fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Tariflerde arayın',
                      hintStyle: TextStyle(
                        color: AppColors.inkLight.withOpacity(0.6),
                        fontFamily: 'Manrope',
                        fontSize: 14,
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          'assets/images/icons/search_icon.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () async {
              final result = await showIngredientFilterSheet(
                context,
                allIngredients: allIngredients,
                selectedIngredients: _selectedIngredients,
              );
              if (result != null) {
                setState(() => _selectedIngredients = result);
              }
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: hasFilter
                        ? AppColors.brandOrange
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hasFilter
                          ? AppColors.brandOrange
                          : const Color(0xFFE8E8E8),
                      width: hasFilter ? 1.5 : 0.5,
                    ),
                  ),
                  child: Icon(
                    Icons.tune,
                    size: 22,
                    color: hasFilter ? Colors.white : AppColors.inkLight,
                  ),
                ),
                if (hasFilter)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: AppColors.ink,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${_selectedIngredients.length}',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
