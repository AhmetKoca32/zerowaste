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

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
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
              showRecipeDetailSheet(
                context,
                recipe: recipe,
                showSavePrompt: true,
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                  Text(
                    'Elinizdeki malzemeleri ekleyin',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.brandOrange,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            hintText: 'örn. domates, fesleğen',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.add_circle),
                              color: AppColors.brandOrange,
                              onPressed: _addIngredient,
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _addIngredient(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _addIngredient,
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Ekle'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.brandOrange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (ingredients.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cream,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.stone),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.inkLight),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'En az bir malzeme ekleyin, ardından Tarif Oluştur\'a dokunun.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.inkLight),
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ingredients.asMap().entries.map((e) {
                        return Chip(
                          label: Text(e.value),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => ref
                              .read(ingredientListProvider.notifier)
                              .removeAt(e.key),
                          backgroundColor: AppColors.brandCream.withOpacity(0.5),
                          side: BorderSide(color: AppColors.brandCream),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () =>
                          ref.read(ingredientListProvider.notifier).clear(),
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: const Text('Tümünü temizle'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.inkLight,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'Mutfak (isteğe bağlı)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.brandOrange,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CuisineOptions.all.map((cuisine) {
                      final isNone = cuisine == CuisineOptions.none;
                      final isSelected = isNone
                          ? (selectedCuisine == null)
                          : (selectedCuisine == cuisine);
                      return ChoiceChip(
                        label: Text(cuisine),
                        selected: isSelected,
                        onSelected: (_) {
                          ref.read(selectedCuisineProvider.notifier).set(
                                isNone ? null : cuisine,
                              );
                        },
                        selectedColor: AppColors.brandCream.withOpacity(0.7),
                        side: BorderSide(
                          color: isSelected ? AppColors.brandOrange : AppColors.stone,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: ingredients.isEmpty || isLoading
                        ? null
                        : _generateRecipe,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Tarif Oluştur'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(savedRecipesProvider);
    return savedAsync.when(
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kaydettiğim Tarifler',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.brandOrange,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
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
                            color: AppColors.brandOrange,
                            fontWeight: FontWeight.w600,
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
