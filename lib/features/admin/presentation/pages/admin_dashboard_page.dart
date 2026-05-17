import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:zerowaste/l10n/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/data/models/recipe.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_guard.dart';
import '../widgets/admin_sidebar.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return AdminGuard(
      child: Consumer(
        builder: (context, ref, _) {
          return AdminShell(
            title: l10n.adminDashboardTitle,
            currentPath: GoRouterState.of(context).uri.path,
            onLogout: () async {
              await ref.read(adminAuthServiceProvider).signOut();
              if (context.mounted) context.go(AppRouter.adminLogin);
            },
            body: _RecipeListContent(),
          );
        },
      ),
    );
  }
}

class _RecipeListContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final recipesAsync = ref.watch(adminRecipeListProvider);

    return recipesAsync.when(
      data: (recipes) {
        if (recipes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 64,
                  color: AppColors.inkLight,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.adminDashboardEmpty,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.inkLight,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.adminDashboardEmptyHint,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.inkLight,
                      ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => context.go(AppRouter.adminRecipeEdit(recipe.id)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipe.title,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${recipe.ingredients.length} malzeme • ${recipe.instructions.length} adım',
                                  style: TextStyle(color: AppColors.inkLight, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                color: AppColors.brandOrange,
                                onPressed: () =>
                                    context.go(AppRouter.adminRecipeEdit(recipe.id)),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(8),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                color: Colors.red,
                                onPressed: () =>
                                    _showDeleteDialog(context, ref, recipe),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(8),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              right: 24,
              bottom: 24,
              child: FloatingActionButton(
                onPressed: () => context.go(AppRouter.adminRecipeNew),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) {
        final l10n = AppLocalizations.of(context)!;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(l10n.homeError(err.toString())),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(adminRecipeListProvider),
                child: Text(l10n.homeRetry),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Recipe recipe,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.adminDashboardDeleteTitle),
        content: Text(
          l10n.adminDashboardDeleteConfirm(recipe.title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.recipeDetailCancel),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await ref
                    .read(adminRecipeRepositoryProvider)
                    .deleteRecipe(recipe.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ref.invalidate(adminRecipeListProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.adminDashboardDeleted)),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.homeError(e.toString()))),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.recipeDetailDeleteAction),
          ),
        ],
      ),
    );
  }
}
