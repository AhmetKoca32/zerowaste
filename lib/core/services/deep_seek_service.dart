import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';

/// Thrown when Firebase cannot verify the signed-in user.
class DeepSeekAuthException implements Exception {
  DeepSeekAuthException([this.message]);
  final String? message;
  @override
  String toString() => message ?? 'Authentication is required.';
}

/// Thrown when the request times out after waiting for a server response.
class DeepSeekTimeoutException implements Exception {
  DeepSeekTimeoutException([this.message]);
  final String? message;
  @override
  String toString() => message ?? 'Request timed out';
}

/// Thrown when the application cannot reach Firebase.
class DeepSeekConnectionException implements Exception {
  DeepSeekConnectionException([this.message]);
  final String? message;
  @override
  String toString() => message ?? 'Could not reach the server';
}

/// Thrown when the AI service returns an error.
class DeepSeekApiException implements Exception {
  DeepSeekApiException(this.statusCode, [this.message]);
  final int statusCode;
  final String? message;
  @override
  String toString() => message ?? 'API error (status: $statusCode)';
}

/// Calls the protected Firebase AI functions for recipe generation and chat.
///
/// The DeepSeek API key and prompt policy live only on the server, so neither
/// is packaged into the Android or iOS app.
class DeepSeekService {
  DeepSeekService({FirebaseFunctions? functions})
    : _functions =
          functions ?? FirebaseFunctions.instanceFor(region: 'europe-west1');

  final FirebaseFunctions _functions;

  static const List<Duration> _retryBackoffs = [
    Duration(milliseconds: 500),
    Duration(milliseconds: 1500),
  ];

  /// How many prior+current bubbles the server accepts.
  static const int mascotHistoryLimit = 20;

  Future<String> _call(String name, Map<String, dynamic> data) async {
    Object? lastError;
    final attempts = _retryBackoffs.length + 1;

    for (var attempt = 0; attempt < attempts; attempt++) {
      try {
        final callable = _functions.httpsCallable(
          name,
          options: HttpsCallableOptions(timeout: const Duration(seconds: 60)),
        );
        final result = await callable.call<Map<String, dynamic>>(data);
        final text = result.data['text'];
        if (text is! String || text.trim().isEmpty) {
          throw DeepSeekApiException(500, 'The AI service returned no text.');
        }
        return text.trim();
      } on FirebaseFunctionsException catch (error) {
        final mapped = _mapFunctionsError(error);
        if (mapped is DeepSeekTimeoutException ||
            mapped is DeepSeekConnectionException) {
          lastError = mapped;
        } else {
          throw mapped;
        }
      }

      if (attempt < attempts - 1) {
        await Future<void>.delayed(_retryBackoffs[attempt]);
      }
    }

    throw lastError ?? DeepSeekConnectionException();
  }

  Object _mapFunctionsError(FirebaseFunctionsException error) {
    switch (error.code) {
      case 'unauthenticated':
      case 'permission-denied':
        return DeepSeekAuthException(error.message);
      case 'deadline-exceeded':
        return DeepSeekTimeoutException(error.message);
      case 'unavailable':
      case 'unknown':
        return DeepSeekConnectionException(error.message);
      case 'invalid-argument':
        return DeepSeekApiException(400, error.message);
      case 'failed-precondition':
        return DeepSeekApiException(412, error.message);
      case 'resource-exhausted':
        return DeepSeekApiException(429, error.message);
      default:
        return DeepSeekApiException(500, error.message);
    }
  }

  /// Generates a recipe using the given ingredients and optional cuisine style.
  Future<String> generateRecipe(
    List<String> ingredients, {
    String? cuisine,
    String languageCode = 'tr',
  }) async {
    final isEnglish = languageCode == 'en';
    final list = ingredients
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (list.isEmpty) {
      return isEnglish
          ? 'Please add at least one ingredient.'
          : 'Lütfen en az bir malzeme ekleyin.';
    }

    final trimmedCuisine = cuisine?.trim();
    return _call('generateRecipe', {
      'ingredients': list,
      'cuisine': trimmedCuisine?.isEmpty ?? true ? null : trimmedCuisine,
      'languageCode': isEnglish ? 'en' : 'tr',
    });
  }

  /// Chats with the app mascot. The server owns both the prompt and language
  /// policy; this method only sends the visible conversation context.
  Future<String> chatWithMascot(
    String message, {
    List<({String text, bool isUser})> priorTurns = const [],
  }) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      return 'Ask me anything about zero-waste cooking and kitchen tips! / Sıfır atık mutfak ve ipuçları hakkında ne olursa olsun sorabilirsin!';
    }

    final window = priorTurns.length >= mascotHistoryLimit
        ? priorTurns.sublist(priorTurns.length - (mascotHistoryLimit - 1))
        : priorTurns;
    return _call('chatWithMascot', {
      'message': trimmed,
      'priorTurns': window
          .map((turn) => {'text': turn.text, 'isUser': turn.isUser})
          .toList(growable: false),
    });
  }
}
