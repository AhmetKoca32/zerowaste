/// Global app constants.
abstract final class AppConstants {
  AppConstants._();

  /// Base URL for API (switch when moving to remote).
  static const String recipesBaseUrl = '';

  /// Local recipes asset path (used when [recipesBaseUrl] is empty).
  static const String recipesAssetPath = 'assets/data/recipes.json';

  /// App display name.
  static const String appName = 'Atıksız Mutfak';
}
