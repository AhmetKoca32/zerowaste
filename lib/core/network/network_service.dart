import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';

/// Global Dio-based HTTP client for API calls (DeepSeek, future recipe API).
class NetworkService {
  NetworkService({BaseOptions? baseOptions}) {
    final options = baseOptions ??
        BaseOptions(
          baseUrl: AppConstants.deepSeekBaseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: <String, dynamic>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
    _dio = Dio(options);

    // Only attach the verbose logger in debug builds. The default LogInterceptor
    // dumps headers (including Authorization: Bearer <key>) and full request
    // bodies, which is fine for dev but a leak risk in release.
    if (kDebugMode) {
      _dio.interceptors.add(_redactedLogInterceptor());
    }
  }

  /// LogInterceptor with the Authorization header redacted so API keys never
  /// land in logs / crash reports.
  Interceptor _redactedLogInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        final masked = Map<String, dynamic>.from(options.headers);
        if (masked.containsKey('Authorization')) {
          masked['Authorization'] = 'Bearer ***';
        }
        debugPrint('--> ${options.method} ${options.uri}');
        debugPrint('   headers: $masked');
        debugPrint('   data: ${options.data}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('<-- ${response.statusCode} ${response.requestOptions.uri}');
        handler.next(response);
      },
      onError: (err, handler) {
        debugPrint('*** ${err.type} ${err.requestOptions.uri}');
        debugPrint('   message: ${err.message}');
        handler.next(err);
      },
    );
  }

  late final Dio _dio;
  Dio get dio => _dio;

  /// Create a separate Dio instance for a custom base URL (e.g. recipe API).
  Dio createClient({required String baseUrl, Map<String, String>? headers}) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: <String, dynamic>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?headers,
        },
      ),
    );
  }
}
