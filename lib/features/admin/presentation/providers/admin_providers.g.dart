// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminAuthServiceHash() => r'admin_auth_service';

/// See also [adminAuthService].
@ProviderFor(adminAuthService)
final adminAuthServiceProvider = Provider<AdminAuthService>.internal(
  adminAuthService,
  name: r'adminAuthServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminAuthServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminAuthServiceRef = ProviderRef<AdminAuthService>;

String _$adminUserHash() => r'admin_user';

/// See also [adminUser].
@ProviderFor(adminUser)
final adminUserProvider = StreamProvider<User?>.internal(
  adminUser,
  name: r'adminUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminUserRef = StreamProviderRef<User?>;

String _$isAdminHash() => r'is_admin';

/// See also [isAdmin].
@ProviderFor(isAdmin)
final isAdminProvider = FutureProvider<bool>.internal(
  isAdmin,
  name: r'isAdminProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAdminHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAdminRef = FutureProviderRef<bool>;

String _$adminRecipeRepositoryHash() => r'admin_recipe_repository';

/// See also [adminRecipeRepository].
@ProviderFor(adminRecipeRepository)
final adminRecipeRepositoryProvider = Provider<RecipeRepository>.internal(
  adminRecipeRepository,
  name: r'adminRecipeRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminRecipeRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminRecipeRepositoryRef = ProviderRef<RecipeRepository>;

String _$adminRecipeListHash() => r'admin_recipe_list';

/// See also [adminRecipeList].
@ProviderFor(adminRecipeList)
final adminRecipeListProvider = FutureProvider<List<Recipe>>.internal(
  adminRecipeList,
  name: r'adminRecipeListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminRecipeListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminRecipeListRef = FutureProviderRef<List<Recipe>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
