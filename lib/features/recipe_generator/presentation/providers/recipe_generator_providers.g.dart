// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_generator_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ingredientListHash() => r'3d527657906efc66baf1f263ed18972f24cf3e50';

/// Ingredient list for recipe generation (chips).
///
/// Copied from [IngredientList].
@ProviderFor(IngredientList)
final ingredientListProvider =
    AutoDisposeNotifierProvider<IngredientList, List<String>>.internal(
      IngredientList.new,
      name: r'ingredientListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ingredientListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$IngredientList = AutoDisposeNotifier<List<String>>;
String _$selectedCuisineHash() => r'3ea9a7ee3fd598adf36695f4bba0b6af945ec9d6';

/// Optional selected cuisine for recipe generation (null = no preference).
///
/// Copied from [SelectedCuisine].
@ProviderFor(SelectedCuisine)
final selectedCuisineProvider =
    AutoDisposeNotifierProvider<SelectedCuisine, String?>.internal(
      SelectedCuisine.new,
      name: r'selectedCuisineProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedCuisineHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedCuisine = AutoDisposeNotifier<String?>;
String _$generatedRecipesHash() => r'9127470d9225198a20d00c45c66f2d70527e8243';

/// Recipes created by the generator; shown on home page like static recipes.
///
/// Copied from [GeneratedRecipes].
@ProviderFor(GeneratedRecipes)
final generatedRecipesProvider =
    AutoDisposeNotifierProvider<GeneratedRecipes, List<Recipe>>.internal(
      GeneratedRecipes.new,
      name: r'generatedRecipesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$generatedRecipesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GeneratedRecipes = AutoDisposeNotifier<List<Recipe>>;
String _$savedRecipesHash() => r'ea2fada698772f0d04242e232860a07ccff71f4a';

/// User-saved recipes (persisted), shown on recipe generator page.
///
/// Copied from [SavedRecipes].
@ProviderFor(SavedRecipes)
final savedRecipesProvider =
    AutoDisposeAsyncNotifierProvider<SavedRecipes, List<SavedRecipe>>.internal(
      SavedRecipes.new,
      name: r'savedRecipesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$savedRecipesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SavedRecipes = AutoDisposeAsyncNotifier<List<SavedRecipe>>;
String _$generatedRecipeHash() => r'25a4ba327ac36c3ecdc73688ce8f4764868bfacb';

/// Async state for the generated recipe text (loading / data / error).
///
/// Copied from [GeneratedRecipe].
@ProviderFor(GeneratedRecipe)
final generatedRecipeProvider =
    AutoDisposeAsyncNotifierProvider<GeneratedRecipe, String?>.internal(
      GeneratedRecipe.new,
      name: r'generatedRecipeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$generatedRecipeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GeneratedRecipe = AutoDisposeAsyncNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
