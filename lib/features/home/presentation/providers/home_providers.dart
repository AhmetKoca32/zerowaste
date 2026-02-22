import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../recipe_generator/presentation/providers/recipe_generator_providers.dart';
import '../../data/models/recipe.dart';
import '../../data/repositories/recipe_repository.dart';

part 'home_providers.g.dart';

@riverpod
RecipeRepository recipeRepository(RecipeRepositoryRef ref) {
  return RecipeRepository(useFirestore: true);
}

@riverpod
Future<List<Recipe>> recipeList(RecipeListRef ref) async {
  final repo = ref.watch(recipeRepositoryProvider);
  final fromRepo = await repo.getRecipes();
  final generated = ref.watch(generatedRecipesProvider);
  return [...generated, ...fromRepo];
}
