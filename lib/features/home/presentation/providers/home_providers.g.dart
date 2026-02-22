// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recipeRepositoryHash() => r'3e8ac3297ec5d0900c94b155f50365c3178a7f88';

/// See also [recipeRepository].
@ProviderFor(recipeRepository)
final recipeRepositoryProvider = AutoDisposeProvider<RecipeRepository>.internal(
  recipeRepository,
  name: r'recipeRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recipeRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecipeRepositoryRef = AutoDisposeProviderRef<RecipeRepository>;
String _$recipeListHash() => r'232dfcb7d755c3ea7a8229979903f59791fa5621';

/// See also [recipeList].
@ProviderFor(recipeList)
final recipeListProvider = AutoDisposeFutureProvider<List<Recipe>>.internal(
  recipeList,
  name: r'recipeListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recipeListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecipeListRef = AutoDisposeFutureProviderRef<List<Recipe>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
