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

  static String _recipeSystemPrompt(String languageCode) {
    if (languageCode == 'en') {
      return '''
You are EcoChef, a professional chef. Create a creative recipe from the user's ingredients. Use a friendly, casual tone.

LANGUAGE — highest priority:
- Write the entire recipe in English only. Never use Turkish words or headers.
- The recipe title (text after "## Title:") MUST be in English — e.g. "Tomato & Egg Skillet", NOT "Domatesli Omlet".
- Use "## Title:" only. NEVER use "## Başlık:" or any Turkish section headers.

Never add intro phrases, greetings, "sure", "here is your recipe", or similar. Start directly with the recipe.

Use exactly this format:

## Title: [recipe name]

**Short Description:** [1-2 sentence description]

**Ingredients:**
- [ingredient 1]
- [ingredient 2]

**Steps:**
1. [step 1]
2. [step 2]

Keep it practical and home-kitchen friendly. Add zero-waste tips when possible (optional).
''';
    }

    return '''
You are EcoChef, a professional chef. Create a creative recipe from the user's ingredients. Use a friendly, casual tone.

LANGUAGE — highest priority:
- Write the entire recipe in Turkish only. Never use English words or headers.

Never add intro phrases, greetings, "elbette", "işte tarifiniz", "karşınızda", or similar. Start directly with the recipe.

Use exactly this format:

## Başlık: [tarif adı]

**Kısa Açıklama:** [1-2 cümlelik açıklama]

**Malzemeler:**
- [malzeme 1]
- [malzeme 2]

**Yapılış Adımları:**
1. [adım 1]
2. [adım 2]

Keep it practical and home-kitchen friendly. Add zero-waste tips when possible (optional).
''';
  }

  static const String _mascotSystemPrompt = '''
You are EcoChef, the mascot of Zero-Waste Kitchen (Atıksız Mutfak). You are warm, eco-conscious, and an expert on reducing food waste, using leftovers, and sustainable cooking.

LANGUAGE — highest priority, never violate:
- Read the user's latest message and reply entirely in that same language only.
- English in → English out. Every word must be English. No Turkish words, greetings, or phrases.
- Turkish in → Turkish out. Every word must be Turkish.
- Never default to Turkish because of your brand name, this prompt, or the app locale.
- Do not mix languages in one reply. Do not translate the user's question unless they ask.
- If a [LANGUAGE RULE] tag is present in the user message, follow it exactly.

Style: short, helpful, encouraging, friendly. Stay on zero-waste cooking and kitchen topics.
''';

  /// Retry budget for transient network failures. The first attempt is
  /// immediate, retries wait [_retryBackoffs] before firing. Keep this small
  /// — the user is staring at a loading indicator.
  static const List<Duration> _retryBackoffs = [
    Duration(milliseconds: 500),
    Duration(milliseconds: 1500),
  ];

  /// How many prior+current bubbles to send to the model (user + assistant).
  static const int mascotHistoryLimit = 20;

  /// Soft-cap long EcoChef replies in history to keep token use bounded.
  static const int _maxHistoryAssistantChars = 1200;

  /// Sends a chat request to DeepSeek and returns the assistant message content.
  Future<String> _chat({
    required String systemPrompt,
    required List<Map<String, String>> conversation,
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
          conversation: conversation,
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
    required List<Map<String, String>> conversation,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        AppConstants.deepSeekChatPath,
        data: <String, dynamic>{
          'model': AppConstants.deepSeekModel,
          'messages': <Map<String, String>>[
            <String, String>{'role': 'system', 'content': systemPrompt},
            ...conversation,
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
  Future<String> generateRecipe(
    List<String> ingredients, {
    String? cuisine,
    String languageCode = 'tr',
  }) async {
    final isEnglish = languageCode == 'en';
    if (ingredients.isEmpty) {
      return isEnglish
          ? 'Please add at least one ingredient.'
          : 'Lütfen en az bir malzeme ekleyin.';
    }
    final list = ingredients.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (list.isEmpty) {
      return isEnglish
          ? 'Please add at least one ingredient.'
          : 'Lütfen en az bir malzeme ekleyin.';
    }

    final languageRule = isEnglish
        ? 'Write the entire recipe in English only. The recipe title must be in English. Use "## Title:" as the first header — never "## Başlık:".'
        : 'Tarifin tamamını yalnızca Türkçe yaz. Tüm başlıklar, malzemeler ve adımlar Türkçe olmalı.';

    var userContent = isEnglish
        ? 'Create a recipe using only these ingredients:\n${list.join('\n')}\n\n'
            'Ingredients may be in any language, but the recipe title, description, '
            'ingredient names in the list, and steps must all be in English. '
            'Give the dish an English name (e.g. "Tomato & Egg Skillet", not "Domatesli Omlet").'
        : 'Sadece şu malzemelerle bir tarif oluştur:\n${list.join('\n')}';
    if (cuisine != null && cuisine.isNotEmpty) {
      userContent += isEnglish
          ? '\n\nPreferred cuisine: $cuisine. Match this cuisine\'s flavors and techniques.'
          : '\n\nTercih edilen mutfak: $cuisine. Tarif bu mutfağın lezzet ve tekniklerine uygun olsun.';
    }

    userContent = '''
[LANGUAGE RULE: $languageRule]

$userContent''';

    return _chat(
      systemPrompt: _recipeSystemPrompt(languageCode),
      conversation: [
        <String, String>{'role': 'user', 'content': userContent},
      ],
    );
  }

  /// Chat with the Atıksız mascot (friendly, eco-conscious, zero-waste expert).
  ///
  /// [priorTurns] is the conversation **before** [message] (oldest → newest).
  /// The last [mascotHistoryLimit] bubbles (prior + current) are sent to the model.
  Future<String> chatWithMascot(
    String message, {
    List<({String text, bool isUser})> priorTurns = const [],
  }) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      return 'Ask me anything about zero-waste cooking and kitchen tips! / Sıfır atık mutfak ve ipuçları hakkında ne olursa olsun sorabilirsin!';
    }

    final languageRule = _languageRuleForMessage(trimmed);
    final latestUserContent = '''
[LANGUAGE RULE: $languageRule]

User message:
$trimmed''';

    final turns = <({String text, bool isUser})>[
      ...priorTurns,
      (text: trimmed, isUser: true),
    ];
    final window = turns.length > mascotHistoryLimit
        ? turns.sublist(turns.length - mascotHistoryLimit)
        : turns;

    final conversation = <Map<String, String>>[];
    for (var i = 0; i < window.length; i++) {
      final turn = window[i];
      final isLast = i == window.length - 1;
      if (turn.isUser) {
        conversation.add({
          'role': 'user',
          'content': isLast ? latestUserContent : turn.text,
        });
      } else {
        conversation.add({
          'role': 'assistant',
          'content': _truncateHistoryText(turn.text),
        });
      }
    }

    return _chat(
      systemPrompt: _mascotSystemPrompt,
      conversation: conversation,
    );
  }

  static String _truncateHistoryText(String text) {
    if (text.length <= _maxHistoryAssistantChars) return text;
    return '${text.substring(0, _maxHistoryAssistantChars)}…';
  }

  /// Returns an explicit reply-language instruction derived from the user's text.
  static String _languageRuleForMessage(String message) {
    switch (_detectMessageLanguage(message)) {
      case _MessageLanguage.english:
        return 'The user wrote in English. Reply ONLY in English. Do not use any Turkish.';
      case _MessageLanguage.turkish:
        return 'Kullanıcı Türkçe yazdı. Yanıtını YALNIZCA Türkçe ver. İngilizce kullanma.';
      case _MessageLanguage.unknown:
        return 'Detect the language of the user message and reply entirely in that same language only.';
    }
  }

  static _MessageLanguage _detectMessageLanguage(String message) {
    final lower = message.toLowerCase();

    if (RegExp(r'[ğüşöçı]').hasMatch(lower)) {
      return _MessageLanguage.turkish;
    }

    const turkishWords = [
      'merhaba', 'nasıl', 'neden', 'ne ', ' bir ', 'için', 'olan', 'var',
      'yok', 'yemek', 'mutfak', 'atık', 'tarif', 'pişir', 'lütfen',
      'teşekkür', 'evet', 'hayır', 'artık', 'malzeme', 'soğan', 'domates',
    ];
    const englishWords = [
      'hello', 'how', 'what', 'the', 'is', 'are', 'you', 'can', 'could',
      'would', 'please', 'thanks', 'thank', 'yes', 'no', 'why', 'when',
      'where', 'food', 'waste', 'recipe', 'cook', 'kitchen', 'leftover',
      'ingredient', 'help', 'good', 'morning', 'evening', 'hey', 'hi ',
    ];

    var trScore = 0;
    var enScore = 0;
    for (final word in turkishWords) {
      if (lower.contains(word)) trScore++;
    }
    for (final word in englishWords) {
      if (RegExp('\\b${RegExp.escape(word.trim())}\\b').hasMatch(lower)) {
        enScore++;
      }
    }

    if (trScore > enScore) return _MessageLanguage.turkish;
    if (enScore > trScore) return _MessageLanguage.english;
    if (enScore > 0) return _MessageLanguage.english;

    return _MessageLanguage.unknown;
  }
}

enum _MessageLanguage { english, turkish, unknown }
