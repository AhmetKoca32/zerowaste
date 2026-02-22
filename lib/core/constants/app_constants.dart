import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Global app constants.
abstract final class AppConstants {
  AppConstants._();

  /// Base URL for API (switch when moving to remote).
  static const String recipesBaseUrl = '';

  /// Local recipes asset path (used when [recipesBaseUrl] is empty).
  static const String recipesAssetPath = 'assets/data/recipes.json';

  /// DeepSeek API base URL.
  static const String deepSeekBaseUrl = 'https://api.deepseek.com';

  /// DeepSeek chat completions path (OpenAI-compatible).
  static const String deepSeekChatPath = '/v1/chat/completions';

  /// DeepSeek model for chat.
  static const String deepSeekModel = 'deepseek-chat';

  /// API key for DeepSeek. Prefer .env (DEEPSEEK_API_KEY); fallback to --dart-define.
  static String get deepSeekApiKey =>
      dotenv.env['DEEPSEEK_API_KEY']?.trim() ??
      String.fromEnvironment('DEEPSEEK_API_KEY', defaultValue: '');

  /// App display name.
  static const String appName = 'ZeroWaste Mutfak';
}
