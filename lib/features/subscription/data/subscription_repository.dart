import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'models/subscription_history_response.dart';
import 'models/subscription_request.dart';
import 'models/subscription_response.dart';

class SubscriptionRepository {
  SubscriptionRepository({
    required this.apiClient,
  });

  final ApiClient apiClient;

  Future<SubscriptionResponse>
  getMySubscription() async {
    try {
      final response =
      await apiClient.get<Map<String, dynamic>>(
        ApiConstants.subscriptionMy,
      );

      final responseBody = response.data;

      if (responseBody == null) {
        throw Exception(
          'Empty response from server.',
        );
      }

      final data = responseBody['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception(
          responseBody['message'] ??
              'Unable to load subscription.',
        );
      }

      return SubscriptionResponse.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> createSubscriptionRequest(
      SubscriptionRequest request,
      ) async {
    try {
      await apiClient.post<Map<String, dynamic>>(
        ApiConstants.subscriptionRequest,
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<SubscriptionHistoryResponse>>
  getRequestHistory() async {
    try {
      final response =
      await apiClient.get<Map<String, dynamic>>(
        ApiConstants.subscriptionRequestHistory,
      );

      final responseBody = response.data;

      if (responseBody == null) {
        throw Exception(
          'Empty response from server.',
        );
      }

      final data = responseBody['data'];

      if (data is! List) {
        throw Exception(
          responseBody['message'] ??
              'Unable to load subscription history.',
        );
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(
        SubscriptionHistoryResponse.fromJson,
      )
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(
      DioException error,
      ) {
    final statusCode =
        error.response?.statusCode;

    final responseData =
        error.response?.data;

    if (responseData is Map<String, dynamic>) {
      final message =
      responseData['message'];

      if (message is String &&
          message.isNotEmpty) {
        return Exception(message);
      }
    }

    switch (statusCode) {
      case 400:
        return Exception(
          'Invalid subscription request.',
        );

      case 401:
        return Exception(
          'Your session has expired.',
        );

      case 404:
        return Exception(
          'Subscription not found.',
        );

      case 409:
        return Exception(
          'You already have a pending subscription request.',
        );

      default:
        if (error.type ==
            DioExceptionType.connectionError) {
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