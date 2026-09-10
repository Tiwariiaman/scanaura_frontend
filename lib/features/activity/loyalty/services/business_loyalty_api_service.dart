import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/loyalty_customer_response.dart';
import 'loyalty_api_exception.dart';

class BusinessLoyaltyApiService {
  final ApiClient apiClient;

  const BusinessLoyaltyApiService({
    required this.apiClient,
  });

  // ============================================================
  // VERIFY CUSTOMER VISIT QR
  // ============================================================

  Future<LoyaltyCustomerResponse> verifyLoyaltyQr({
    required String qrPayload,
  }) async {
    final payload = qrPayload.trim();

    if (payload.isEmpty) {
      throw const LoyaltyApiException(
        message: 'Loyalty QR payload is required.',
      );
    }

    Map<String, dynamic> qrData;

    try {
      final decoded = jsonDecode(payload);

      if (decoded is! Map) {
        throw const FormatException(
          'QR payload must be a JSON object.',
        );
      }

      qrData = Map<String, dynamic>.from(decoded);
    } catch (_) {
      throw const LoyaltyApiException(
        message: 'Invalid loyalty QR.',
      );
    }

    final qrToken = qrData['qrToken'];
    final qrType = qrData['type'];
    final qrVersion = qrData['version'];

    if (qrToken is! String || qrToken.trim().isEmpty) {
      throw const LoyaltyApiException(
        message: 'Invalid loyalty QR token.',
      );
    }

    if (qrType != 'SCANAURA_LOYALTY_VISIT') {
      throw const LoyaltyApiException(
        message: 'This QR is not a customer visit QR.',
      );
    }

    if (qrVersion != '1') {
      throw const LoyaltyApiException(
        message: 'Unsupported loyalty QR version.',
      );
    }

    try {
      final response = await apiClient.post(
        '/api/activity/loyalty/visit/verify',
        data: <String, dynamic>{
          'qrToken': qrToken.trim(),
        },
      );

      final body = _decodeResponse(response.data);

      if (body['success'] == false) {
        throw LoyaltyApiException(
          message: _extractMessage(body) ??
              'Unable to verify this loyalty QR.',
        );
      }

      final data = body['data'];

      if (data is! Map) {
        throw const LoyaltyApiException(
          message: 'Invalid loyalty verification response.',
        );
      }

      final customerJson = Map<String, dynamic>.from(data);

      return LoyaltyCustomerResponse.fromJson(
        customerJson,
      );
    } on LoyaltyApiException {
      rethrow;
    } on DioException catch (e) {
      throw LoyaltyApiException(
        message: _extractDioErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw LoyaltyApiException(
        message: _cleanErrorMessage(e),
      );
    }
  }

  // ============================================================
  // VERIFY REWARD QR
  // ============================================================
  //
  // This is intentionally separate from verifyLoyaltyQr().
  //
  // Visit QR:
  //   SCANAURA_LOYALTY_VISIT
  //   -> /visit/verify
  //   -> awards daily points
  //
  // Reward QR:
  //   SCANAURA_LOYALTY_CLAIM
  //   -> /claim/verify
  //   -> grants the already-claimed reward
  //
  // Reward verification does NOT award visit points.
  // ============================================================

  Future<Map<String, dynamic>> verifyRewardQr({
    required String qrPayload,
  }) async {
    final payload = qrPayload.trim();

    if (payload.isEmpty) {
      throw const LoyaltyApiException(
        message: 'Reward QR payload is required.',
      );
    }

    Map<String, dynamic> qrData;

    try {
      final decoded = jsonDecode(payload);

      if (decoded is! Map) {
        throw const FormatException(
          'QR payload must be a JSON object.',
        );
      }

      qrData = Map<String, dynamic>.from(decoded);
    } catch (_) {
      throw const LoyaltyApiException(
        message: 'Invalid reward QR.',
      );
    }

    final qrToken = qrData['qrToken'];
    final qrType = qrData['type'];
    final qrVersion = qrData['version'];

    if (qrToken is! String || qrToken.trim().isEmpty) {
      throw const LoyaltyApiException(
        message: 'Invalid reward QR token.',
      );
    }

    if (qrType != 'SCANAURA_LOYALTY_CLAIM') {
      throw const LoyaltyApiException(
        message: 'This QR is not a reward QR.',
      );
    }

    if (qrVersion != '1') {
      throw const LoyaltyApiException(
        message: 'Unsupported loyalty QR version.',
      );
    }

    try {
      final response = await apiClient.post(
        '/api/activity/loyalty/claim/verify',
        data: <String, dynamic>{
          'qrToken': qrToken.trim(),
        },
      );

      final body = _decodeResponse(response.data);

      if (body['success'] == false) {
        throw LoyaltyApiException(
          message: _extractMessage(body) ??
              'Unable to verify this reward QR.',
        );
      }

      final data = body['data'];

      if (data is! Map) {
        throw const LoyaltyApiException(
          message: 'Invalid reward verification response.',
        );
      }

      return <String, dynamic>{
        'success': true,
        'message': _extractMessage(body) ??
            'Reward verified and granted successfully.',
        'data': Map<String, dynamic>.from(data),
      };
    } on LoyaltyApiException {
      rethrow;
    } on DioException catch (e) {
      throw LoyaltyApiException(
        message: _extractDioErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw LoyaltyApiException(
        message: _cleanErrorMessage(e),
      );
    }
  }

  // ============================================================
  // RESPONSE DECODING
  // ============================================================

  Map<String, dynamic> _decodeResponse(
      dynamic data,
      ) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    if (data is String && data.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(data);

        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        // Handled below.
      }
    }

    throw const LoyaltyApiException(
      message: 'Invalid server response.',
    );
  }

  // ============================================================
  // ERROR EXTRACTION
  // ============================================================

  String? _extractMessage(
      Map<String, dynamic> body,
      ) {
    final message = body['message'];

    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }

    final error = body['error'];

    if (error is String && error.trim().isNotEmpty) {
      return error.trim();
    }

    return null;
  }

  String _extractDioErrorMessage(
      DioException error,
      ) {
    final responseData = error.response?.data;

    if (responseData is Map) {
      final body = Map<String, dynamic>.from(responseData);

      final message = _extractMessage(body);

      if (message != null) {
        return message;
      }
    }

    if (responseData is String &&
        responseData.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(responseData);

        if (decoded is Map) {
          final message = _extractMessage(
            Map<String, dynamic>.from(decoded),
          );

          if (message != null) {
            return message;
          }
        }
      } catch (_) {
        // Ignore malformed error body.
      }
    }

    final dioMessage = error.message;

    if (dioMessage != null &&
        dioMessage.trim().isNotEmpty) {
      return dioMessage.trim();
    }

    return 'Unable to verify this loyalty QR.';
  }

  // ============================================================
  // GENERIC ERROR CLEANUP
  // ============================================================

  String _cleanErrorMessage(Object error) {
    final text = error.toString();

    if (text.startsWith('Exception: ')) {
      return text.substring(
        'Exception: '.length,
      );
    }

    return text;
  }
}