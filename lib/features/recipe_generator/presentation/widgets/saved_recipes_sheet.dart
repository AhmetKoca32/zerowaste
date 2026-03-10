import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/recipe_detail_sheet.dart';
import '../../data/saved_recipe.dart';
import '../../data/saved_recipes_storage.dart';
import '../providers/recipe_generator_providers.dart';

void showSavedRecipesSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) => _SavedRecipesSheetContent(
        scrollController: scrollController,
      ),
    ),
  );
}

class _SavedRecipesSheetContent extends ConsumerStatefulWidget {
  const _SavedRecipesSheetContent({required this.scrollController});

  final ScrollController scrollController;

  @override
  ConsumerState<_SavedRecipesSheetContent> createState() =>
      _SavedRecipesSheetContentState();
}

class _SavedRecipesSheetContentState
    extends ConsumerState<_SavedRecipesSheetContent> {
  String _searchQuery = '';

  void _openSavedRecipe(SavedRecipe sr) {
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

  @override
  Widget build(BuildContext context) {
    final savedAsync = ref.watch(savedRecipesProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.stone.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Kaydettiğim Tarifler',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Arama
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: const Color(0xFFE8E8E8),
                  width: 0.5,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
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
                  borderRadius: BorderRadius.circular(50),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v.trim()),
                    style: const TextStyle(fontFamily: 'Manrope', fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Tariflerde arayın',
                      hintStyle: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        color: AppColors.inkLight.withOpacity(0.6),
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
          const SizedBox(height: 12),

          // Liste
          Expanded(
            child: savedAsync.when(
              data: (list) {
                final filtered = _searchQuery.isEmpty
                    ? list
                    : list
                        .where((sr) => sr.recipe.title
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'Henüz kaydedilmiş tarif yok.'
                          : 'Sonuç bulunamadı.',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        color: AppColors.inkLight,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: AppColors.stone.withOpacity(0.3),
                  ),
                  itemBuilder: (context, index) {
                    final sr = filtered[index];
                    return _SavedRecipeRow(
                      savedRecipe: sr,
                      onTap: () => _openSavedRecipe(sr),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(
                child: Text(
                  'Tarifler yüklenirken hata oluştu.',
                  style: TextStyle(fontFamily: 'Manrope', color: AppColors.inkLight),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedRecipeRow extends StatelessWidget {
  const _SavedRecipeRow({
    required this.savedRecipe,
    required this.onTap,
  });

  final SavedRecipe savedRecipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final recipe = savedRecipe.recipe;
    final imagePath = savedRecipe.localImagePath;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            if (imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image(
                  image: FileImage(File(imagePath)),
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                ),
              )
            else
              _placeholder(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${recipe.ingredients.length} malzeme · ${recipe.instructions.length} adım',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      color: AppColors.inkLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.inkLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.restaurant,
        color: AppColors.brandOrange.withOpacity(0.5),
        size: 24,
      ),
    );
  }
}
