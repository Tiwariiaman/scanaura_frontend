import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'models/qr_response.dart';

class QrRepository {
  QrRepository({
    required this.apiClient,
  });

  final ApiClient apiClient;

  Future<QrResponse> getMyDigitalQr() async {
    try {
      final response =
      await apiClient.get<Map<String, dynamic>>(
        ApiConstants.qrDigital,
      );

      final responseBody = response.data;

      if (responseBody == null) {
        throw Exception('Empty response from server.');
      }

      final data = responseBody['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception(
          responseBody['message'] ??
              'Unable to load digital QR.',
        );
      }

      return QrResponse.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<QrResponse>> getMyQrCodes() async {
    try {
      final response =
      await apiClient.get<Map<String, dynamic>>(
        ApiConstants.qrMy,
      );

      final responseBody = response.data;

      if (responseBody == null) {
        throw Exception('Empty response from server.');
      }

      final data = responseBody['data'];

      if (data is! List) {
        throw Exception(
          responseBody['message'] ??
              'Unable to load QR codes.',
        );
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(QrResponse.fromJson)
          .toList();
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
        return Exception('Invalid QR request.');

      case 401:
        return Exception('Your session has expired.');

      case 404:
        return Exception('QR code not found.');

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