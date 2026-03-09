// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminAuthServiceHash() => r'2a70a30aab5309cb894ca48cbaf1a389ff81455b';

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
String _$adminUserHash() => r'9bbfbf3024815f3707ad5f44cdbda1a0986be586';

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
String _$isAdminHash() => r'4471abc65c413b8ff071582659b992819807297a';

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
String _$adminRecipeRepositoryHash() =>
    r'e626670d1497affc576a8522bb167cd2e1a95577';

/// Recipe repository for admin (Firestore only).
///
/// Copied from [adminRecipeRepository].
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
String _$adminRecipeListHash() => r'6ddc3315facfefb71b05facd03ce19f4998eae54';

/// Recipe list for admin panel (Firestore only, no in-memory generated).
///
/// Copied from [adminRecipeList].
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
