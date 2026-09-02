import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'models/landing_response.dart';
import 'models/menu_response.dart';
import 'models/payment_response.dart';

class PublicRepository {
  PublicRepository({
    required this.apiClient,
  });

  final ApiClient apiClient;

  // ============================================================
  // LANDING PAGE
  // ============================================================

  Future<LandingResponse> getLandingPage(
      String qrCode,
      ) async {
    final code = qrCode.trim();

    if (code.isEmpty) {
      throw Exception('QR code is missing.');
    }

    try {
      final response =
      await apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.publicLanding}/$code',
      );

      final body = response.data;

      if (body == null) {
        throw Exception(
          'Empty response from server.',
        );
      }

      final data = body['data'];

      if (data is! Map<String, dynamic>) {
        final message = body['message'];

        throw Exception(
          message is String && message.trim().isNotEmpty
              ? message.trim()
              : 'Unable to load business page.',
        );
      }

      return LandingResponse.fromJson(data);
    } on DioException catch (error) {
      throw _handleError(
        error,
        fallback: 'Unable to load business page.',
      );
    }
  }

  // ============================================================
  // MENU
  // ============================================================

  Future<MenuResponse> getMenu(
      String qrCode,
      ) async {
    final code = qrCode.trim();

    if (code.isEmpty) {
      throw Exception('QR code is missing.');
    }

    try {
      final response =
      await apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.publicMenu}/$code/menu',
      );

      final body = response.data;

      if (body == null) {
        throw Exception(
          'Empty response from server.',
        );
      }

      final data = body['data'];

      if (data is! Map<String, dynamic>) {
        final message = body['message'];

        throw Exception(
          message is String && message.trim().isNotEmpty
              ? message.trim()
              : 'Unable to load menu.',
        );
      }

      return MenuResponse.fromJson(data);
    } on DioException catch (error) {
      throw _handleError(
        error,
        fallback: 'Unable to load menu.',
      );
    }
  }

  // ============================================================
  // PAYMENT DETAILS
  // ============================================================

  Future<PaymentResponse> getPaymentDetails(
      String qrCode,
      ) async {
    final code = qrCode.trim();

    if (code.isEmpty) {
      throw Exception('QR code is missing.');
    }

    try {
      final response =
      await apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.publicPayment}/$code/payment',
      );

      final body = response.data;

      if (body == null) {
        throw Exception(
          'Empty response from server.',
        );
      }

      final data = body['data'];

      if (data is! Map<String, dynamic>) {
        final message = body['message'];

        throw Exception(
          message is String && message.trim().isNotEmpty
              ? message.trim()
              : 'Unable to load payment details.',
        );
      }

      return PaymentResponse.fromJson(data);
    } on DioException catch (error) {
      throw _handleError(
        error,
        fallback: 'Unable to load payment details.',
      );
    }
  }

  // ============================================================
  // ERROR HANDLING
  // ============================================================

  Exception _handleError(
      DioException error, {
        required String fallback,
      }) {
    final responseData = error.response?.data;

    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];

      if (message is String && message.trim().isNotEmpty) {
        return Exception(message.trim());
      }

      final backendError = responseData['error'];

      if (backendError is String &&
          backendError.trim().isNotEmpty) {
        return Exception(backendError.trim());
      }
    }

    switch (error.response?.statusCode) {
      case 400:
        return Exception('Invalid public page request.');

      case 401:
        return Exception(
          'Your session has expired. Please login again.',
        );

      case 403:
        return Exception(
          'This business page is not available.',
        );

      case 404:
        return Exception(
          'Business not found or QR code is invalid.',
        );

      case 409:
        return Exception(
          'This QR code is not available.',
        );

      case 429:
        return Exception(
          'Too many requests. Please try again shortly.',
        );

      case 500:
        return Exception(
          'Server error. Please try again shortly.',
        );

      default:
        if (error.type == DioExceptionType.connectionError) {
          return Exception(
            'Unable to connect to ScanAura.',
          );
        }

        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout) {
          return Exception(
            'ScanAura server request timed out.',
          );
        }

        return Exception(fallback);
    }
  }
}