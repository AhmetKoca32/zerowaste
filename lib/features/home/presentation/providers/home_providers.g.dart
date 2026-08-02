// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recipeRepositoryHash() => r'c95bcbddf88d36b0b1f41d490d16d9e4193bf42f';

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
String _$recipeListHash() => r'6d5be76ebd5d42f33a421db73f716cba076a9df7';

/// See also [recipeList].
@ProviderFor(recipeList)
final recipeListProvider = FutureProvider<List<Recipe>>.internal(
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
typedef RecipeListRef = FutureProviderRef<List<Recipe>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
