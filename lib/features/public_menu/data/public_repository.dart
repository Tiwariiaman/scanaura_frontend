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

  Future<LandingResponse> getLandingPage(
      String qrCode,
      ) async {
    try {
      final response =
      await apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.publicLanding}/$qrCode',
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
          message is String && message.isNotEmpty
              ? message
              : 'Unable to load business page.',
        );
      }

      return LandingResponse.fromJson(data);
    } on DioException catch (error) {
      throw _handleError(
        error,
        fallback:
        'Unable to load business page.',
      );
    }
  }

  Future<MenuResponse> getMenu(
      String qrCode,
      ) async {
    try {
      final response =
      await apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.publicMenu}/$qrCode/menu',
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
          message is String && message.isNotEmpty
              ? message
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

  Future<PaymentResponse> getPaymentDetails(
      String qrCode,
      ) async {
    try {
      final response =
      await apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.publicPayment}/$qrCode/payment',
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
          message is String && message.isNotEmpty
              ? message
              : 'Unable to load payment details.',
        );
      }

      return PaymentResponse.fromJson(data);
    } on DioException catch (error) {
      throw _handleError(
        error,
        fallback:
        'Unable to load payment details.',
      );
    }
  }

  Exception _handleError(
      DioException error, {
        required String fallback,
      }) {
    final responseData = error.response?.data;

    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];

      if (message is String && message.isNotEmpty) {
        return Exception(message);
      }
    }

    switch (error.response?.statusCode) {
      case 400:
        return Exception(
          'Invalid public page request.',
        );

      case 404:
        return Exception(
          'Business or QR code not found.',
        );

      case 409:
        return Exception(
          'This QR code is not available.',
        );

      case 500:
        return Exception(
          'Unable to load this page right now.',
        );

      default:
        if (error.type ==
            DioExceptionType.connectionError) {
          return Exception(
            'Unable to connect to ScanAura.',
          );
        }

        return Exception(fallback);
    }
  }
}