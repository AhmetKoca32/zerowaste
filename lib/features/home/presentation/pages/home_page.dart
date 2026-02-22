import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/shell/main_tab_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_placeholder.dart';
import '../providers/home_providers.dart';
import '../widgets/recipe_blog_card.dart';
import '../widgets/recipe_detail_sheet.dart';

/// Blog-style recipe listing (Home) with loading, error, and success states.
class HomePage extends ConsumerWidget {
  const HomePage({super.key, this.inTabs = false});

  final bool inTabs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipeListProvider);
    final body = recipesAsync.when(
        data: (recipes) {
          if (recipes.isEmpty) {
            return EmptyPlaceholder(
              icon: Icons.menu_book,
              message: 'Henüz tarif yok. Malzeme ekleyip bir tarif oluşturun!',
              action: FilledButton.icon(
                onPressed: () {
                  if (inTabs) {
                    ref.read(tabIndexProvider.notifier).state = 1;
                  } else {
                    context.go(AppRouter.recipeGenerator);
                  }
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Tarif Oluştur'),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return InkWell(
                onTap: () => showRecipeDetailSheet(context, recipe: recipe),
                borderRadius: BorderRadius.circular(20),
                child: RecipeBlogCard(recipe: recipe),
              );
            },
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: AppColors.fern,
                strokeWidth: 2.5,
              ),
              const SizedBox(height: 16),
              Text(
                'Tarifler yükleniyor…',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
            label: const Text('Tekrar Dene'),
          ),
        ),
      );

    if (inTabs) return body;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: const TextStyle(
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
}
