import 'package:dio/dio.dart';

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
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
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
