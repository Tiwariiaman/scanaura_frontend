import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';

class ApiClient {
  ApiClient({
    required this._secureStorageService,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.webBaseUrl,
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

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token =
          await _secureStorageService.getAccessToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
      ),
    );
  }

  Future<Response<T>> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
      }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
    );
  }

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

  Future<Response<T>> put<T>(
      String path, {
        dynamic data,
      }) {
    return _dio.put<T>(
      path,
      data: data,
    );
  }

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