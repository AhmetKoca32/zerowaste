import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    return AdminGuard(
      child: AdminSidebar(
        currentPath: GoRouterState.of(context).uri.path,
        onLogout: () async {
          await ref.read(adminAuthServiceProvider).signOut();
          if (context.mounted) context.go(AppRouter.adminLogin);
        },
        child: Scaffold(
          backgroundColor: AppColors.cream,
          appBar: AppBar(
            title: const Text('Tarifler'),
            backgroundColor: Colors.white,
            foregroundColor: AppColors.ink,
            elevation: 0,
          ),
          body: _RecipeListContent(),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.go(AppRouter.adminRecipeNew),
            icon: const Icon(Icons.add),
            label: const Text('Yeni Tarif'),
            backgroundColor: AppColors.brandOrange,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _RecipeListContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  'Henüz tarif yok',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.inkLight,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Yeni tarif eklemek için sağ alttaki butonu kullanın',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.inkLight,
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                title: Text(
                  recipe.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${recipe.ingredients.length} malzeme • ${recipe.instructions.length} adım',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      color: AppColors.brandOrange,
                      onPressed: () =>
                          context.go(AppRouter.adminRecipeEdit(recipe.id)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () =>
                          _showDeleteDialog(context, ref, recipe),
                    ),
                  ],
                ),
                onTap: () =>
                    context.go(AppRouter.adminRecipeEdit(recipe.id)),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Hata: $err'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(adminRecipeListProvider),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Recipe recipe,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tarifi Sil'),
        content: Text(
          '"${recipe.title}" tarifini silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
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
                    const SnackBar(content: Text('Tarif silindi')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata: $e')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
