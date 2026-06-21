import 'dart:async';

import 'package:dio/dio.dart';

import '../constants/app_constants.dart';

/// Thrown when DeepSeek API key is missing or invalid.
class DeepSeekAuthException implements Exception {
  DeepSeekAuthException([this.message]);
  final String? message;
  @override
  String toString() => message ?? 'Invalid or missing DeepSeek API key';
}

/// Thrown when the request times out after waiting for a server response.
class DeepSeekTimeoutException implements Exception {
  DeepSeekTimeoutException([this.message]);
  final String? message;
  @override
  String toString() => message ?? 'Request timed out';
}

/// Thrown when we can't even reach the server (DNS, no internet, blocked).
/// Distinct from [DeepSeekTimeoutException] which means we connected but the
/// server didn't reply in time.
class DeepSeekConnectionException implements Exception {
  DeepSeekConnectionException([this.message]);
  final String? message;
  @override
  String toString() => message ?? 'Could not reach the server';
}

/// Thrown when the API returns an error.
class DeepSeekApiException implements Exception {
  DeepSeekApiException(this.statusCode, [this.message]);
  final int statusCode;
  final String? message;
  @override
  String toString() => message ?? 'API error (status: $statusCode)';
}

/// Service for DeepSeek chat API: recipe generation and mascot chat.
class DeepSeekService {
  DeepSeekService(this._dio, {String? apiKey}) : _apiKey = apiKey ?? AppConstants.deepSeekApiKey;

  final Dio _dio;
  final String _apiKey;

  static const String _recipeSystemPrompt = '''
Sen profesyonel bir şefsin adın EcoChef. Kullanıcının verdiği malzemelerle yaratıcı bir tarif oluştur. Resmi bir dilden ziyade arkadaş canlısı bir dil kullan.

ASLA giriş cümlesi, selamlama, "elbette", "işte tarifiniz", "karşınızda" veya benzeri hiçbir tanıtım metni ekleme. Doğrudan tarife geç.

Yanıtını aşağıdaki sabit formatta, başlıkla başlayarak yaz:

## Başlık: [tarif adı]

**Kısa Açıklama:** [1-2 cümlelik açıklama]

**Malzemeler:**
- [malzeme 1]
- [malzeme 2]

**Yapılış Adımları:**
1. [adım 1]
2. [adım 2]

Pratik ve ev mutfağına uygun olsun. Mümkünse sıfır atık ipuçları ver (isteğe bağlı).
''';

  static const String _mascotSystemPrompt = '''
Sen Atıksız Mutfak maskotusun (EcoChef). Çevre bilincine sahip, sıcak ve sıfır atık yemek konusunda uzmansın.
Gıda israfını azaltma, artakalanları kullanma ve sürdürülebilir pişirme hakkında kısa, faydalı ipuçları ver.
Kullanıcının mesajının dilini algıla ve aynı dilde yanıt ver. Kısa, teşvik edici ve samimi bir dil kullan.
''';

  /// Retry budget for transient network failures. The first attempt is
  /// immediate, retries wait [_retryBackoffs] before firing. Keep this small
  /// — the user is staring at a loading indicator.
  static const List<Duration> _retryBackoffs = [
    Duration(milliseconds: 500),
    Duration(milliseconds: 1500),
  ];

  /// Sends a chat request to DeepSeek and returns the assistant message content.
  Future<String> _chat({
    required String systemPrompt,
    required String userContent,
  }) async {
    if (_apiKey.isEmpty) {
      throw DeepSeekAuthException('DEEPSEEK_API_KEY is not set.');
    }

    // Total attempts = initial + retries. We only retry on network-layer
    // failures (no socket, DNS, timeouts) — never on 4xx/5xx, since those
    // are either programmer error or paid-for failures we shouldn't double-charge for.
    final maxAttempts = _retryBackoffs.length + 1;
    Object? lastError;

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        return await _postOnce(
          systemPrompt: systemPrompt,
          userContent: userContent,
        );
      } on DeepSeekTimeoutException catch (e) {
        lastError = e;
      } on DeepSeekConnectionException catch (e) {
        lastError = e;
      }

      // Wait before the next attempt (skip wait after the last attempt).
      if (attempt < maxAttempts - 1) {
        await Future<void>.delayed(_retryBackoffs[attempt]);
      }
    }

    // All attempts exhausted — surface the most recent failure.
    throw lastError!;
  }

  /// One round-trip; never retries. Wrapped by [_chat] for the retry loop.
  Future<String> _postOnce({
    required String systemPrompt,
    required String userContent,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        AppConstants.deepSeekChatPath,
        data: <String, dynamic>{
          'model': AppConstants.deepSeekModel,
          'messages': <Map<String, String>>[
            <String, String>{'role': 'system', 'content': systemPrompt},
            <String, String>{'role': 'user', 'content': userContent},
          ],
          'max_tokens': 1024,
        },
        options: Options(
          headers: <String, String>{
            'Authorization': 'Bearer $_apiKey',
          },
          // All three timeouts are overridden here. Previously connectTimeout
          // fell back to the 30s default from NetworkService, which masqueraded
          // as "60s" in the per-request config.
          connectTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      final data = response.data;
      if (data == null) throw DeepSeekApiException(response.statusCode ?? -1, 'Empty response');
      final choices = data['choices'] as List<dynamic>?;
      final content = choices?.isNotEmpty == true
          ? (choices!.first as Map<String, dynamic>)['message'] as Map<String, dynamic>?
          : null;
      final text = content?['content'] as String?;
      if (text == null || text.isEmpty) {
        throw DeepSeekApiException(response.statusCode ?? -1, 'No content in response');
      }
      return text.trim();
    } on DioException catch (e) {
      // Connection-level: server was never reached. Worth retrying.
      // connectionError covers DNS, socket, refused, host unreachable — Dio's
      // cross-platform shorthand for "we never got bytes flowing".
      if (e.type == DioExceptionType.connectionError) {
        throw DeepSeekConnectionException(e.message);
      }
      // Timeouts — these split into "couldn't open socket" (connectTimeout,
      // also retry-worthy) and "server slow to respond" (send/receive). We
      // bucket the first as a connection error and the others as proper timeouts.
      if (e.type == DioExceptionType.connectionTimeout) {
        throw DeepSeekConnectionException(e.message);
      }
      if (e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw DeepSeekTimeoutException(e.message);
      }
      final statusCode = e.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw DeepSeekAuthException(
          statusCode == 401 ? 'Invalid API key.' : 'Access forbidden. Check your API key.',
        );
      }
      throw DeepSeekApiException(
        statusCode ?? -1,
        e.response?.data?.toString() ?? e.message ?? 'Network error',
      );
    }
  }

  /// Generates a recipe using the given ingredients and optional cuisine style.
  Future<String> generateRecipe(List<String> ingredients, {String? cuisine}) async {
    if (ingredients.isEmpty) {
      return 'Lütfen en az bir malzeme ekleyin.';
    }
    final list = ingredients.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (list.isEmpty) return 'Lütfen en az bir malzeme ekleyin.';
    var userContent = 'Sadece şu malzemelerle bir tarif oluştur:\n${list.join('\n')}';
    if (cuisine != null && cuisine.isNotEmpty) {
      userContent += '\n\nTercih edilen mutfak: $cuisine. Tarif bu mutfağın lezzet ve tekniklerine uygun olsun.';
    }
    return _chat(systemPrompt: _recipeSystemPrompt, userContent: userContent);
  }

  /// Chat with the Atıksız mascot (friendly, eco-conscious, zero-waste expert).
  Future<String> chatWithMascot(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return 'Atıksız mutfak veya ipuçları hakkında ne olursa olsun sorabilirsiniz!';
    return _chat(systemPrompt: _mascotSystemPrompt, userContent: trimmed);
  }
}
