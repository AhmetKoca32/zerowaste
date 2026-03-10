import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/recipe_detail_sheet.dart';
import '../../data/cuisine_options.dart';
import '../../data/recipe_parser.dart';
import '../../data/saved_recipe.dart';
import '../../data/saved_recipes_storage.dart';
import '../providers/recipe_generator_providers.dart';
import '../widgets/chef_loading_overlay.dart';
import '../widgets/recipe_result_sheet.dart';
import '../widgets/saved_recipes_sheet.dart';

/// Input ingredients (text field + chips), Generate Recipe, then show result in bottom sheet.
class RecipeGeneratorPage extends ConsumerStatefulWidget {
  const RecipeGeneratorPage({super.key, this.inTabs = false});

  final bool inTabs;

  @override
  ConsumerState<RecipeGeneratorPage> createState() =>
      _RecipeGeneratorPageState();
}

class _RecipeGeneratorPageState extends ConsumerState<RecipeGeneratorPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _cuisineExpanded = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Widget _buildRecentIngredients(WidgetRef ref, List<String> currentIngredients) {
    final recentAsync = ref.watch(recentIngredientsProvider);
    return recentAsync.when(
      data: (recentList) {
        final filtered = recentList
            .where((r) => !currentIngredients
                .any((c) => c.toLowerCase() == r.toLowerCase()))
            .toList();
        if (filtered.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Son eklenenler',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filtered.map((ingredient) {
                  return GestureDetector(
                    onTap: () => ref
                        .read(ingredientListProvider.notifier)
                        .add(ingredient),
                    child: Chip(
                      label: Text(
                        ingredient,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          color: AppColors.ink,
                        ),
                      ),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.brandOrange),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _addIngredient() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref.read(ingredientListProvider.notifier).add(text);
    _controller.clear();
  }

  void _generateRecipe() {
    ref.read(generatedRecipeProvider.notifier).generate();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<String?>>(generatedRecipeProvider, (prev, next) {
      next.whenOrNull(
        data: (value) {
          if (value != null && value.isNotEmpty && context.mounted) {
            final isError = value.contains('Lütfen') ||
                value.contains('Invalid') ||
                value.contains('timed out') ||
                value.contains('API') ||
                value.contains('timeout');
            final recipe = isError ? null : RecipeParser.parse(value);
            if (recipe != null) {
              ref.read(generatedRecipesProvider.notifier).add(recipe);
              ref.read(ingredientListProvider.notifier).clear();
              showRecipeDetailSheet(
                context,
                recipe: recipe,
                showSavePrompt: true,
                showPlaceholderImage: false,
                onSave: () =>
                    ref.read(savedRecipesProvider.notifier).addRecipe(recipe),
              );
            } else {
              showRecipeResultSheet(context, content: value, isError: isError);
            }
            ref.read(generatedRecipeProvider.notifier).clear();
          }
        },
        error: (err, _) {
          if (context.mounted) {
            showRecipeResultSheet(
              context,
              content: err.toString(),
              isError: true,
            );
            ref.read(generatedRecipeProvider.notifier).clear();
          }
        },
      );
    });

    final ingredients = ref.watch(ingredientListProvider);
    final selectedCuisine = ref.watch(selectedCuisineProvider);
    final generatedAsync = ref.watch(generatedRecipeProvider);
    final isLoading = generatedAsync.isLoading;

    final scrollBody = SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, widget.inTabs ? 120 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Başlık ---
            Text(
              'Elinizdeki malzemeleri ekleyin',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 15,
                  color: AppColors.inkLight,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'En az bir malzeme ekleyin, ardından Tarif Oluştur\'a dokunun.',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      color: AppColors.inkLight,
                    ),
                  ),
                ),
              ],
            ),

            // --- Input + "+" butonu ---
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xFFE8E8E8),
                        width: 0.5,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
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
                        borderRadius: BorderRadius.circular(28),
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          style: const TextStyle(fontFamily: 'Manrope', fontSize: 15),
                          decoration: InputDecoration(
                            hintText: 'örn. domates, fesleğen',
                            hintStyle: TextStyle(
                              fontFamily: 'Manrope',
                              color: AppColors.inkLight.withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _addIngredient(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _addIngredient,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: AppColors.brandOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),

            // --- Eklenen malzemeler ---
            if (ingredients.isNotEmpty) ...[
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ingredients.asMap().entries.map((e) {
                  return Chip(
                    label: Text(
                      e.value,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white70),
                    onDeleted: () => ref
                        .read(ingredientListProvider.notifier)
                        .removeAt(e.key),
                    backgroundColor: AppColors.brandOrange,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],

            // --- Son eklenenler (geçmiş malzemeler) ---
            _buildRecentIngredients(ref, ingredients),

            // --- Mutfak (isteğe bağlı) ---
            const SizedBox(height: 28),
            Text(
              'Mutfak (isteğe bağlı)',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: _cuisineExpanded
                      ? AppColors.brandOrange
                      : const Color(0xFFE8E8E8),
                  width: _cuisineExpanded ? 1.5 : 0.5,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
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
                child: Column(
                children: [
                  // Dropdown satırı
                  InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: () =>
                        setState(() => _cuisineExpanded = !_cuisineExpanded),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedCuisine ?? 'Fark etmez',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 15,
                                color: selectedCuisine != null
                                    ? AppColors.ink
                                    : AppColors.inkLight.withOpacity(0.6),
                              ),
                            ),
                          ),
                          AnimatedRotation(
                            turns: _cuisineExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: Image.asset(
                              'assets/images/icons/arrow_icon.png',
                              width: 16,
                              height: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Açılır liste
                  AnimatedCrossFade(
                    firstChild: const SizedBox(width: double.infinity),
                    secondChild: Column(
                      children: List.generate(
                        CuisineOptions.all.length,
                        (index) {
                          final cuisine = CuisineOptions.all[index];
                          final isNone = cuisine == CuisineOptions.none;
                          final isSelected = isNone
                              ? (selectedCuisine == null)
                              : (selectedCuisine == cuisine);

                          return Column(
                            children: [
                              Divider(
                                height: 1,
                                thickness: 0.5,
                                color: AppColors.stone.withOpacity(0.3),
                                indent: 16,
                                endIndent: 16,
                              ),
                              InkWell(
                                onTap: () {
                                  ref
                                      .read(selectedCuisineProvider.notifier)
                                      .set(isNone ? null : cuisine);
                                  setState(() => _cuisineExpanded = false);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          cuisine,
                                          style: TextStyle(
                                            fontFamily: 'Manrope',
                                            fontSize: 15,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            color: isSelected
                                                ? AppColors.brandOrange
                                                : AppColors.ink,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_circle,
                                          color: AppColors.brandOrange,
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    crossFadeState: _cuisineExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 250),
                  ),
                ],
              ),
              ),
            ),

            // --- Tarif Oluştur butonu ---
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: ingredients.isEmpty || isLoading
                    ? null
                    : _generateRecipe,
                icon: const Icon(Icons.auto_awesome),
                label: const Text(
                  'Tarif Oluştur',
                  style: TextStyle(fontFamily: 'Manrope', fontSize: 16),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const _SavedRecipesSection(),
          ],
        ),
    );
    return Stack(
      children: [
        widget.inTabs
            ? scrollBody
            : Scaffold(
                appBar: AppBar(
                  title: const Text('Tarif Oluştur'),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go(AppRouter.home),
                  ),
                ),
                body: scrollBody,
              ),
      ]..addAll(isLoading ? [const ChefLoadingOverlay()] : <Widget>[]),
    );
  }
}

class _SavedRecipesSection extends ConsumerWidget {
  const _SavedRecipesSection();

  static const int _maxVisible = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(savedRecipesProvider);
    return savedAsync.when(
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        final hasMore = list.length > _maxVisible;
        final visibleCount = hasMore ? _maxVisible : list.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Kaydettiğim Tarifler',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontFamily: 'Manrope',
                          color: AppColors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (hasMore)
                  GestureDetector(
                    onTap: () => showSavedRecipesSheet(context),
                    child: Text(
                      'Tümünü gör (${list.length})',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.brandOrange,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: visibleCount + (hasMore ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  if (hasMore && index == visibleCount) {
                    return _SeeAllCard(
                      count: list.length,
                      onTap: () => showSavedRecipesSheet(context),
                    );
                  }
                  final sr = list[index];
                  return _SavedRecipeCard(
                    savedRecipe: sr,
                    onTap: () => _openSavedRecipe(context, ref, sr),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _openSavedRecipe(
      BuildContext context, WidgetRef ref, SavedRecipe sr) {
    showRecipeDetailSheet(
      context,
      recipe: sr.recipe,
      localImagePath: sr.localImagePath,
      canAddPhoto: true,
      showPlaceholderImage: false,
      onImagePicked: (XFile file) async {
        final bytes = await file.readAsBytes();
        final path = await SavedRecipesStorage.saveRecipeImage(
          sr.recipe.id,
          bytes,
        );
        await ref.read(savedRecipesProvider.notifier).updateImagePath(
              sr.recipe.id,
              path,
            );
        return path;
      },
      onDelete: () async {
        await ref.read(savedRecipesProvider.notifier).remove(sr.recipe.id);
      },
    );
  }
}

class _SeeAllCard extends StatelessWidget {
  const _SeeAllCard({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 120,
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.brandOrange, width: 1),
            ),
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.brandOrange,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tümünü gör',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandOrange,
                    ),
                  ),
                  Text(
                    '$count tarif',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      color: AppColors.inkLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SavedRecipeCard extends StatelessWidget {
  const _SavedRecipeCard({
    required this.savedRecipe,
    required this.onTap,
  });

  final SavedRecipe savedRecipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final recipe = savedRecipe.recipe;
    final localImagePath = savedRecipe.localImagePath;
    final title = recipe.title;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 160,
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.brandCream, width: 1),
            ),
            color: AppColors.cream,
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: localImagePath != null
                      ? Image(
                          image: FileImage(File(localImagePath)),
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _placeholder(context),
                        )
                      : _placeholder(context),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontFamily: 'Manrope',
                            color: AppColors.ink,
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.brandCream.withOpacity(0.4),
      child: Icon(
        Icons.restaurant,
        size: 36,
        color: AppColors.brandOrange.withOpacity(0.6),
      ),
    );
  }
}
