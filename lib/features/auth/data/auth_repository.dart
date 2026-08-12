import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'models/login_request.dart';
import 'models/login_response.dart';
import 'models/register_request.dart';
import 'models/register_response.dart';

class AuthRepository {
  AuthRepository({
    required this._apiClient,
  });

  final ApiClient _apiClient;

  Future<RegisterResponse> register(
      RegisterRequest request,
      ) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.authRegister,
        data: request.toJson(),
      );

      final responseData = response.data;

      if (responseData == null) {
        throw Exception('Empty response from server.');
      }

      final data = responseData['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception(
          responseData['message'] ?? 'Registration failed.',
        );
      }

      return RegisterResponse.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<LoginResponse> login(
      LoginRequest request,
      ) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.authLogin,
        data: request.toJson(),
      );

      final responseData = response.data;

      if (responseData == null) {
        throw Exception('Empty response from server.');
      }

      final data = responseData['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception(
          responseData['message'] ?? 'Login failed.',
        );
      }

      return LoginResponse.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];

      if (message is String && message.isNotEmpty) {
        return Exception(message);
      }
    }

    if (statusCode == 401) {
      return Exception('Invalid email or password.');
    }

    if (statusCode == 409) {
      return Exception(
        'An account with these details already exists.',
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return Exception(
        'Unable to connect to ScanAura server.',
      );
    }

    return Exception(
      'Something went wrong. Please try again.',
    );
  }
}