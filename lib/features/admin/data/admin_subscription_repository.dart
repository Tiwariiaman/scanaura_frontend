import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'model/pending_subscription_request_response.dart';
import 'model/reject_subscription_request.dart';


class AdminSubscriptionRepository {
  AdminSubscriptionRepository({
    required this.apiClient,
  });

  final ApiClient apiClient;

  // ============================================================
  // PENDING REQUESTS
  // ============================================================

  Future<List<PendingSubscriptionRequestResponse>>
  getPendingRequests() async {
    try {
      final response =
      await apiClient.get<Map<String, dynamic>>(
        ApiConstants.adminPendingSubscriptions,
      );

      final body = response.data;

      if (body == null) {
        throw Exception(
          'Empty response from server.',
        );
      }

      final data = body['data'];

      if (data is! List) {
        throw Exception(
          body['message'] ??
              'Unable to load pending subscription requests.',
        );
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(
        PendingSubscriptionRequestResponse
            .fromJson,
      )
          .toList();
    } on DioException catch (e) {
      throw _handleError(
        e,
        fallback:
        'Unable to load pending subscription requests.',
      );
    }
  }

  // ============================================================
  // APPROVE
  // ============================================================

  Future<void> approveRequest(
      String requestId,
      ) async {
    try {
      await apiClient.post<Map<String, dynamic>>(
        ApiConstants.adminApproveSubscription(
          requestId,
        ),
      );
    } on DioException catch (e) {
      throw _handleError(
        e,
        fallback:
        'Unable to approve subscription request.',
      );
    }
  }

  // ============================================================
  // REJECT
  // ============================================================

  Future<void> rejectRequest(
      String requestId,
      String remark,
      ) async {
    final trimmedRemark = remark.trim();

    if (trimmedRemark.isEmpty) {
      throw Exception(
        'Rejection remark is required.',
      );
    }

    try {
      await apiClient.post<Map<String, dynamic>>(
        ApiConstants.adminRejectSubscription(
          requestId,
        ),
        data: RejectSubscriptionRequest(
          remark: trimmedRemark,
        ).toJson(),
      );
    } on DioException catch (e) {
      throw _handleError(
        e,
        fallback:
        'Unable to reject subscription request.',
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

    if (responseData
    is Map<String, dynamic>) {
      final message =
      responseData['message'];

      if (message is String &&
          message.isNotEmpty) {
        return Exception(message);
      }
    }

    switch (error.response?.statusCode) {
      case 400:
        return Exception(
          'Invalid subscription request.',
        );

      case 401:
        return Exception(
          'Your session has expired.',
        );

      case 403:
        return Exception(
          'You do not have admin access.',
        );

      case 404:
        return Exception(
          'Subscription request not found.',
        );

      case 409:
        return Exception(
          'This subscription request cannot be processed in its current state.',
        );

      default:
        if (error.type ==
            DioExceptionType.connectionError) {
          return Exception(
            'Unable to connect to ScanAura server.',
          );
        }

        return Exception(fallback);
    }
  }
}