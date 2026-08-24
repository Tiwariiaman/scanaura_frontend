import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../qr/data/models/qr_response.dart';
import 'model/admin_dashboard_response.dart';
import 'model/admin_qr_details_response.dart';
import 'model/business_summary_response.dart';
import 'model/qr_inventory_response.dart';


class AdminRepository {
  AdminRepository({
    required this.apiClient,
  });

  final ApiClient apiClient;

  // ============================================================
  // DASHBOARD
  // ============================================================

  Future<AdminDashboardResponse>
  getDashboard() async {
    try {
      final response =
      await apiClient.get<Map<String, dynamic>>(
        ApiConstants.adminDashboard,
      );

      final body = response.data;

      if (body == null) {
        throw Exception(
          'Empty response from server.',
        );
      }

      final data = body['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception(
          body['message'] ??
              'Unable to load admin dashboard.',
        );
      }

      return AdminDashboardResponse.fromJson(
        data,
      );
    } on DioException catch (e) {
      throw _handleError(
        e,
        fallback:
        'Unable to load admin dashboard.',
      );
    }
  }

  // ============================================================
  // BUSINESSES
  // ============================================================

  Future<List<BusinessSummaryResponse>>
  getBusinesses() async {
    try {
      final response =
      await apiClient.get<Map<String, dynamic>>(
        ApiConstants.adminBusinesses,
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
              'Unable to load businesses.',
        );
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(
        BusinessSummaryResponse.fromJson,
      )
          .toList();
    } on DioException catch (e) {
      throw _handleError(
        e,
        fallback:
        'Unable to load businesses.',
      );
    }
  }

  Future<List<BusinessSummaryResponse>>
  searchBusinesses(
      String keyword,
      ) async {
    try {
      final response =
      await apiClient.get<Map<String, dynamic>>(
        ApiConstants.adminBusinessSearch,
        queryParameters: {
          'keyword': keyword,
        },
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
              'Unable to search businesses.',
        );
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(
        BusinessSummaryResponse.fromJson,
      )
          .toList();
    } on DioException catch (e) {
      throw _handleError(
        e,
        fallback:
        'Unable to search businesses.',
      );
    }
  }

  Future<void> activateBusiness(
      String businessId,
      ) async {
    try {
      await apiClient.patch<Map<String, dynamic>>(
        ApiConstants.adminActivateBusiness(
          businessId,
        ),
      );
    } on DioException catch (e) {
      throw _handleError(
        e,
        fallback:
        'Unable to activate business.',
      );
    }
  }

  Future<void> deactivateBusiness(
      String businessId,
      ) async {
    try {
      await apiClient.patch<Map<String, dynamic>>(
        ApiConstants.adminDeactivateBusiness(
          businessId,
        ),
      );
    } on DioException catch (e) {
      throw _handleError(
        e,
        fallback:
        'Unable to deactivate business.',
      );
    }
  }

  // ============================================================
  // QR INVENTORY
  // ============================================================

  Future<QrInventoryResponse>
  getQrInventory() async {
    try {
      final response =
      await apiClient.get<Map<String, dynamic>>(
        ApiConstants.adminQrInventory,
      );

      final body = response.data;

      if (body == null) {
        throw Exception(
          'Empty response from server.',
        );
      }

      final data = body['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception(
          body['message'] ??
              'Unable to load QR inventory.',
        );
      }

      return QrInventoryResponse.fromJson(
        data,
      );
    } on DioException catch (e) {
      throw _handleError(
        e,
        fallback:
        'Unable to load QR inventory.',
      );
    }
  }

  Future<List<QrResponse>> generatePhysicalQr(
      int count,
      ) async {
    if (count <= 0) {
      throw Exception(
        'QR quantity must be greater than zero.',
      );
    }

    try {
      final response =
      await apiClient.post<Map<String, dynamic>>(
        ApiConstants.adminGenerateQr(count),
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
              'Unable to generate QR codes.',
        );
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(QrResponse.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _handleError(
        e,
        fallback:
        'Unable to generate QR codes.',
      );
    }
  }

  Future<void> deactivateQr(
      String qrCode,
      ) async {
    try {
      await apiClient.patch<Map<String, dynamic>>(
        ApiConstants.adminDeactivateQr(
          qrCode,
        ),
      );
    } on DioException catch (e) {
      throw _handleError(
        e,
        fallback: 'Unable to deactivate QR code.',
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
    final responseData =
        error.response?.data;

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
          'Invalid admin request.',
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
          'Requested admin resource was not found.',
        );

      case 409:
        return Exception(
          'The requested admin operation conflicts with the current state.',
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

  Future<AdminQrDetailsResponse> getQrDetails(
      String qrCode,
      ) async {
    try {
      final response =
      await apiClient.get<Map<String, dynamic>>(
        '/api/v1/admin/qr/$qrCode',
      );

      final body = response.data;

      if (body == null) {
        throw Exception(
          'Empty response from server.',
        );
      }

      final data = body['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception(
          body['message'] ??
              'Unable to load QR details.',
        );
      }

      return AdminQrDetailsResponse.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(
        e,
        fallback: 'Unable to load QR details.',
      );
    }
  }


  Future<void> assignQrToBusiness({
    required String businessId,
    required String qrCode,
  }) async {
    try {
      await apiClient.post<Map<String, dynamic>>(
        '/api/v1/qr/assign',
        data: {
          'businessId': businessId,
          'qrCodes': [
            qrCode,
          ],
        },
      );
    } on DioException catch (e) {
      throw _handleError(
        e,
        fallback:
        'Unable to assign QR code.',
      );
    }
  }
}