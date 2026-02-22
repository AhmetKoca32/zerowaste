import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/saved_recipe.dart';
import '../../data/saved_recipes_storage.dart';
import '../../../home/data/models/recipe.dart';

part 'recipe_generator_providers.g.dart';

/// Ingredient list for recipe generation (chips).
@riverpod
class IngredientList extends _$IngredientList {
  @override
  List<String> build() => [];

  void add(String ingredient) => state = [...state, ingredient];
  void removeAt(int index) => state = state..removeAt(index);
  void clear() => state = [];
}

/// Optional selected cuisine for recipe generation (null = no preference).
@riverpod
class SelectedCuisine extends _$SelectedCuisine {
  @override
  String? build() => null;

  void set(String? cuisine) => state = cuisine;
}

/// Recipes created by the generator; shown on home page like static recipes.
@riverpod
class GeneratedRecipes extends _$GeneratedRecipes {
  @override
  List<Recipe> build() => [];

  void add(Recipe recipe) => state = [recipe, ...state];
}

/// User-saved recipes (persisted), shown on recipe generator page.
@riverpod
class SavedRecipes extends _$SavedRecipes {
  @override
  Future<List<SavedRecipe>> build() async {
    return SavedRecipesStorage.load();
  }

  Future<void> addRecipe(Recipe recipe) async {
    final list = state.valueOrNull ?? await SavedRecipesStorage.load();
    state = AsyncValue.data([
      SavedRecipe(recipe: recipe),
      ...list,
    ]);
    await SavedRecipesStorage.save(state.value!);
  }

  Future<void> updateImagePath(String recipeId, String path) async {
    final list = state.valueOrNull ?? await SavedRecipesStorage.load();
    final updated = list.map((sr) {
      if (sr.recipe.id == recipeId) {
        return SavedRecipe(recipe: sr.recipe, localImagePath: path);
      }
      return sr;
    }).toList();
    state = AsyncValue.data(updated);
    await SavedRecipesStorage.save(updated);
  }

  Future<void> remove(String recipeId) async {
    final list = state.valueOrNull ?? await SavedRecipesStorage.load();
    state = AsyncValue.data(list.where((sr) => sr.recipe.id != recipeId).toList());
    await SavedRecipesStorage.save(state.value!);
  }
}

/// Async state for the generated recipe text (loading / data / error).
@riverpod
class GeneratedRecipe extends _$GeneratedRecipe {
  @override
  FutureOr<String?> build() => null;

  Future<void> generate() async {
    state = const AsyncLoading();
    final ingredients = ref.read(ingredientListProvider);
    if (ingredients.isEmpty) {
      state = AsyncValue.data(
        'Lütfen tarif oluşturmadan önce en az bir malzeme ekleyin.',
      );
      return;
    }
    final cuisine = ref.read(selectedCuisineProvider);
    final deepSeek = ref.read(deepSeekServiceProvider);
    state = await AsyncValue.guard(
      () => deepSeek.generateRecipe(ingredients, cuisine: cuisine),
    );
  }

  void clear() => state = const AsyncData(null);
}
