import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';

class ApiClient {
  ApiClient({
    required this._secureStorageService,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _resolveBaseUrl(),
        connectTimeout: Duration(
          seconds: AppConstants.connectTimeoutSeconds,
        ),
        receiveTimeout: Duration(
          seconds: AppConstants.receiveTimeoutSeconds,
        ),
        sendTimeout: Duration(
          seconds: AppConstants.requestTimeoutSeconds,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  late final Dio _dio;

  final SecureStorageService _secureStorageService;

  Dio get dio => _dio;

  // ------------------------------------------------------------
  // BASE URL
  // ------------------------------------------------------------

  String _resolveBaseUrl() {
    // 1. Explicit build-time override.
    //
    // Example:
    // flutter run -d edge
    //   --dart-define=API_BASE_URL=https://api.scanaura.in
    //
    // This takes priority over automatic detection.
    const configuredBaseUrl =
    String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );

    if (configuredBaseUrl.isNotEmpty) {
      return configuredBaseUrl;
    }

    // 2. Flutter Web automatic environment detection.
    if (kIsWeb) {
      final host = Uri.base.host.toLowerCase();

      // Local Flutter Web development.
      if (host == 'localhost' ||
          host == '127.0.0.1' ||
          host == '::1') {
        return ApiConstants.webBaseUrl;
      }

      // Deployed web application.
      return ApiConstants.productionBaseUrl;
    }

    // 3. Android emulator.
    if (defaultTargetPlatform ==
        TargetPlatform.android) {
      return ApiConstants.androidBaseUrl;
    }

    // 4. Fallback.
    return ApiConstants.productionBaseUrl;
  }

  // ------------------------------------------------------------
  // INTERCEPTORS
  // ------------------------------------------------------------

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token =
          await _secureStorageService.getAccessToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] =
            'Bearer $token';
          }

          handler.next(options);
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // GET
  // ------------------------------------------------------------

  Future<Response<T>> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
      }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
    );
  }

  // ------------------------------------------------------------
  // POST
  // ------------------------------------------------------------

  Future<Response<T>> post<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
      }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  // ------------------------------------------------------------
  // PUT
  // ------------------------------------------------------------

  Future<Response<T>> put<T>(
      String path, {
        dynamic data,
      }) {
    return _dio.put<T>(
      path,
      data: data,
    );
  }

  // ------------------------------------------------------------
  // PATCH
  // ------------------------------------------------------------

  Future<Response<T>> patch<T>(
      String path, {
        dynamic data,
      }) {
    return _dio.patch<T>(
      path,
      data: data,
    );
  }

  // ------------------------------------------------------------
  // DELETE
  // ------------------------------------------------------------

  Future<Response<T>> delete<T>(
      String path, {
        dynamic data,
      }) {
    return _dio.delete<T>(
      path,
      data: data,
    );
  }
}