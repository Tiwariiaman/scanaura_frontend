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

  // Prevent multiple refresh requests at the same time.
  Future<String?>? _refreshFuture;

  // ------------------------------------------------------------
  // BASE URL
  // ------------------------------------------------------------

  String _resolveBaseUrl() {
    const configuredBaseUrl =
    String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );

    if (configuredBaseUrl.isNotEmpty) {
      return configuredBaseUrl;
    }

    if (kIsWeb) {
      final host = Uri.base.host.toLowerCase();

      if (host == 'localhost' ||
          host == '127.0.0.1' ||
          host == '::1') {
        return ApiConstants.webBaseUrl;
      }

      return ApiConstants.productionBaseUrl;
    }

    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      return ApiConstants.productionBaseUrl;
    }

    return ApiConstants.productionBaseUrl;
  }

  // ------------------------------------------------------------
  // INTERCEPTORS
  // ------------------------------------------------------------

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(

        // ------------------------------------------------------
        // REQUEST
        // ------------------------------------------------------

        onRequest: (options, handler) async {
          final token =
          await _secureStorageService.getAccessToken();

          if (token != null && token.trim().isNotEmpty) {
            options.headers['Authorization'] =
            'Bearer ${token.trim()}';
          }

          handler.next(options);
        },

        // ------------------------------------------------------
        // ERROR
        // ------------------------------------------------------

        onError: (error, handler) async {
          final statusCode =
              error.response?.statusCode;

          final requestOptions =
              error.requestOptions;

          // Only refresh when backend says:
          // Unauthorized.
          if (statusCode != 401) {
            handler.next(error);
            return;
          }

          // Never try to refresh the refresh endpoint itself.
          if (requestOptions.path.endsWith('/auth/refresh')) {
            await _clearTokens();

            handler.next(error);
            return;
          }

          // Prevent infinite retry loops.
          final alreadyRetried =
              requestOptions.extra['authRetry'] == true;

          if (alreadyRetried) {
            handler.next(error);
            return;
          }

          try {
            final newAccessToken =
            await _getRefreshedAccessToken();

            // Refresh failed.
            if (newAccessToken == null ||
                newAccessToken.trim().isEmpty) {
              await _clearTokens();

              handler.next(error);
              return;
            }

            // Mark this request so it cannot
            // continuously retry.
            requestOptions.extra['authRetry'] = true;

            // Put the new token into the original request.
            requestOptions.headers['Authorization'] =
            'Bearer ${newAccessToken.trim()}';

            // Retry the original request.
            final response =
            await _dio.fetch<dynamic>(
              requestOptions,
            );

            handler.resolve(response);
          } catch (e) {
            await _clearTokens();

            handler.next(error);
          }
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // REFRESH ACCESS TOKEN
  // ------------------------------------------------------------

  Future<String?> _getRefreshedAccessToken() async {
    // If another request is already refreshing the token,
    // wait for that same refresh operation.
    if (_refreshFuture != null) {
      return _refreshFuture;
    }

    _refreshFuture =
        _performTokenRefresh();

    try {
      return await _refreshFuture;
    } finally {
      _refreshFuture = null;
    }
  }

  // ------------------------------------------------------------
  // ACTUAL REFRESH REQUEST
  // ------------------------------------------------------------

  Future<String?> _performTokenRefresh() async {
    final refreshToken =
    await _secureStorageService.getRefreshToken();

    if (refreshToken == null ||
        refreshToken.trim().isEmpty) {
      return null;
    }

    try {
      /*
       * Use a separate Dio instance here.
       *
       * This prevents the refresh request from using
       * the expired access token through our interceptor.
       */
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: _dio.options.baseUrl,
          connectTimeout: _dio.options.connectTimeout,
          receiveTimeout: _dio.options.receiveTimeout,
          sendTimeout: _dio.options.sendTimeout,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final response =
      await refreshDio.post(
        '/api/v1/auth/refresh',
        data: {
          'refreshToken': refreshToken.trim(),
        },
      );

      final responseData =
          response.data;

      /*
       * Your backend response structure is:
       *
       * {
       *   "success": true,
       *   "message": "...",
       *   "data": {
       *      "accessToken": "...",
       *      "refreshToken": "...",
       *      "tokenType": "Bearer",
       *      "expiresIn": 86400000
       *   }
       * }
       */

      final data =
      responseData['data'];

      if (data == null ||
          data is! Map<String, dynamic>) {
        return null;
      }

      final newAccessToken =
      data['accessToken'] as String?;

      final newRefreshToken =
      data['refreshToken'] as String?;

      if (newAccessToken == null ||
          newAccessToken.trim().isEmpty) {
        return null;
      }

      // Save the new access token.
      await _secureStorageService.saveAccessToken(
        newAccessToken,
      );

      // Save rotated refresh token.
      if (newRefreshToken != null &&
          newRefreshToken.trim().isNotEmpty) {
        await _secureStorageService.saveRefreshToken(
          newRefreshToken,
        );
      }

      return newAccessToken;
    } catch (e) {
      debugPrint(
        'TOKEN REFRESH FAILED: $e',
      );

      return null;
    }
  }

  // ------------------------------------------------------------
  // CLEAR TOKENS
  // ------------------------------------------------------------

  Future<void> _clearTokens() async {
    await _secureStorageService.deleteAccessToken();
    await _secureStorageService.deleteRefreshToken();
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