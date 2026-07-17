import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/recipe.dart';
import '../../data/repositories/recipe_repository.dart';

part 'home_providers.g.dart';

@riverpod
RecipeRepository recipeRepository(RecipeRepositoryRef ref) {
  return RecipeRepository(useFirestore: true);
}

@Riverpod(keepAlive: true)
Future<List<Recipe>> recipeList(RecipeListRef ref) async {
  final repo = ref.watch(recipeRepositoryProvider);
  return repo.getRecipes();
}
