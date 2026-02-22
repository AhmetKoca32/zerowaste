import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/data/models/recipe.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_guard.dart';
import '../widgets/admin_recipe_form.dart';
import '../widgets/admin_sidebar.dart';

class AdminRecipeEditPage extends ConsumerStatefulWidget {
  const AdminRecipeEditPage({super.key, this.recipeId});

  final String? recipeId;

  @override
  ConsumerState<AdminRecipeEditPage> createState() =>
      _AdminRecipeEditPageState();
}

class _AdminRecipeEditPageState extends ConsumerState<AdminRecipeEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _handleSave(Recipe recipe) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(adminRecipeRepositoryProvider);

      if (widget.recipeId == null) {
        final newRecipe = recipe.copyWith(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
        );
        await repo.addRecipe(newRecipe);
      } else {
        await repo.updateRecipe(recipe);
      }

      if (!mounted) return;
      ref.invalidate(adminRecipeListProvider);
      context.go(AppRouter.adminDashboard);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.recipeId == null ? 'Tarif eklendi' : 'Tarif güncellendi',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recipeId != null && widget.recipeId!.isNotEmpty;
    final recipesAsync = ref.watch(adminRecipeListProvider);

    Recipe? existingRecipe;
    if (isEditing) {
      existingRecipe = recipesAsync.maybeWhen(
        data: (recipes) {
          try {
            return recipes.firstWhere(
              (r) => r.id == widget.recipeId,
            );
          } catch (_) {
            return null;
          }
        },
        orElse: () => null,
      );
    }

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
            title: Text(isEditing ? 'Tarif Düzenle' : 'Yeni Tarif'),
            backgroundColor: Colors.white,
            foregroundColor: AppColors.ink,
            elevation: 0,
          ),
          body: isEditing && existingRecipe == null
              ? recipesAsync.when(
                  data: (_) => const Center(
                      child: Text('Tarif bulunamadı')),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Hata: $e')),
                )
              : AdminRecipeForm(
                  formKey: _formKey,
                  initialRecipe: existingRecipe,
                  onSave: _handleSave,
                  isLoading: _isLoading,
                ),
        ),
      ),
    );
  }
}
