import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'models/business_request.dart';
import 'models/business_response.dart';

class BusinessRepository {
  BusinessRepository({
    required this.apiClient,
  });

  final ApiClient apiClient;

  Future<BusinessResponse> createBusiness(
      BusinessRequest request,
      ) async {
    try {
      final response =
      await apiClient.post<Map<String, dynamic>>(
        ApiConstants.businessBase,
        data: request.toJson(),
      );

      final responseBody = response.data;

      if (responseBody == null) {
        throw Exception('Empty response from server.');
      }

      final data = responseBody['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception(
          responseBody['message'] ??
              'Business creation failed.',
        );
      }

      return BusinessResponse.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<BusinessResponse> getMyBusiness() async {
    try {
      final response =
      await apiClient.get<Map<String, dynamic>>(
        ApiConstants.businessMine,
      );

      final responseBody = response.data;

      if (responseBody == null) {
        throw Exception('Empty response from server.');
      }

      final data = responseBody['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception(
          responseBody['message'] ??
              'Unable to load business.',
        );
      }

      return BusinessResponse.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<BusinessResponse> updateBusiness(
      BusinessRequest request,
      ) async {
    try {
      final response =
      await apiClient.put<Map<String, dynamic>>(
        ApiConstants.businessBase,
        data: request.toJson(),
      );

      final responseBody = response.data;

      if (responseBody == null) {
        throw Exception('Empty response from server.');
      }

      final data = responseBody['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception(
          responseBody['message'] ??
              'Business update failed.',
        );
      }

      return BusinessResponse.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteBusiness() async {
    try {
      await apiClient.delete<Map<String, dynamic>>(
        ApiConstants.businessBase,
      );
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

    switch (statusCode) {
      case 400:
        return Exception('Invalid business information.');

      case 401:
        return Exception('Your session has expired.');

      case 404:
        return Exception('Business not found.');

      case 409:
        return Exception('Business already exists.');

      default:
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
}