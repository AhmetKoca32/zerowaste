import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../home/data/models/recipe.dart';
import '../../../home/data/repositories/recipe_repository.dart';
import '../../services/admin_auth_service.dart';

part 'admin_providers.g.dart';

@Riverpod(keepAlive: true)
AdminAuthService adminAuthService(AdminAuthServiceRef ref) {
  return AdminAuthService();
}

@Riverpod(keepAlive: true)
Stream<User?> adminUser(AdminUserRef ref) {
  return ref.watch(adminAuthServiceProvider).authStateChanges;
}

@Riverpod(keepAlive: true)
Future<bool> isAdmin(IsAdminRef ref) async {
  return ref.watch(adminAuthServiceProvider).isCurrentUserAdmin();
}

/// Recipe repository for admin (Firestore only).
@Riverpod(keepAlive: true)
RecipeRepository adminRecipeRepository(AdminRecipeRepositoryRef ref) {
  return RecipeRepository(useFirestore: true);
}

/// Recipe list for admin panel (Firestore only, no in-memory generated).
@Riverpod(keepAlive: true)
Future<List<Recipe>> adminRecipeList(AdminRecipeListRef ref) async {
  final repo = ref.watch(adminRecipeRepositoryProvider);
  return repo.getRecipes();
}
