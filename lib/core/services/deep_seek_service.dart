import 'package:dio/dio.dart';

import '../constants/app_constants.dart';

/// Thrown when DeepSeek API key is missing or invalid.
class DeepSeekAuthException implements Exception {
  DeepSeekAuthException([this.message]);
  final String? message;
  @override
  String toString() => message ?? 'Invalid or missing DeepSeek API key';
}

/// Thrown when the request times out.
class DeepSeekTimeoutException implements Exception {
  DeepSeekTimeoutException([this.message]);
  final String? message;
  @override
  String toString() => message ?? 'Request timed out';
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
Sen profesyonel bir şefsin. Kullanıcının verdiği malzemelerle yaratıcı bir tarif oluştur.
Yanıtını Türkçe yaz. Tarifte başlık, kısa açıklama, malzemeler listesi ve adım adım yapılış olsun.
Pratik ve ev mutfağına uygun olsun. Mümkünse sıfır atık ipuçları ver.
''';

  static const String _mascotSystemPrompt = '''
Sen ZeroWaste Mutfak maskotusun (EcoChef). Çevre bilincine sahip, sıcak ve sıfır atık yemek konusunda uzmansın.
Gıda israfını azaltma, artakalanları kullanma ve sürdürülebilir pişirme hakkında kısa, faydalı ipuçları ver.
Tüm yanıtlarını Türkçe yaz. Kısa, teşvik edici ve samimi bir dil kullan.
''';

  /// Sends a chat request to DeepSeek and returns the assistant message content.
  Future<String> _chat({
    required String systemPrompt,
    required String userContent,
  }) async {
    if (_apiKey.isEmpty) {
      throw DeepSeekAuthException('DEEPSEEK_API_KEY is not set.');
    }

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
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
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

  /// Chat with the ZeroWaste mascot (friendly, eco-conscious, zero-waste expert).
  Future<String> chatWithMascot(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return 'Sıfır atık mutfak veya ipuçları hakkında ne olursa olsun sorabilirsiniz!';
    return _chat(systemPrompt: _mascotSystemPrompt, userContent: trimmed);
  }
}
