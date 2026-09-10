import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/loyalty_claim_response.dart';
import '../models/loyalty_customer_response.dart';
import '../models/loyalty_reward_response.dart';
import '../models/loyalty_qr_response.dart';
import '../models/loyalty_visit_qr_response.dart';

class LoyaltyApiService {
  LoyaltyApiService({
    required this.apiClient,
  });

  final ApiClient apiClient;

  // ============================================================
  // CUSTOMER
  // ============================================================

  Future<LoyaltyCustomerResponse> getCustomer({
    required String businessId,
    required String mobileNumber,
  }) async {
    try {
      final response = await apiClient.get<dynamic>(
        '/api/public/loyalty/customer',
        queryParameters: {
          'businessId': businessId,
          'mobileNumber': mobileNumber.trim(),
        },
      );

      final decoded = _decode(response.data);

      _validateResponse(
        response,
        decoded,
        'Unable to load loyalty account.',
      );

      final data = _extractDataMap(
        decoded,
        'Invalid loyalty customer data.',
      );

      return LoyaltyCustomerResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
        _extractDioErrorMessage(
          e,
          'Unable to load loyalty account.',
        ),
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'Unable to load loyalty account: $e',
      );
    }
  }

  // ============================================================
  // CREATE / UPDATE CUSTOMER
  // ============================================================

  Future<LoyaltyCustomerResponse> createOrUpdateCustomer({
    required String businessId,
    required String customerName,
    required String mobileNumber,
  }) async {
    try {
      final response = await apiClient.post<dynamic>(
        '/api/public/loyalty/customer',
        queryParameters: {
          'businessId': businessId,
        },
        data: {
          'customerName': customerName.trim(),
          'mobileNumber': mobileNumber.trim(),
        },
      );

      final decoded = _decode(response.data);

      _validateResponse(
        response,
        decoded,
        'Unable to create loyalty account.',
      );

      final data = _extractDataMap(
        decoded,
        'Invalid loyalty customer data.',
      );

      return LoyaltyCustomerResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
        _extractDioErrorMessage(
          e,
          'Unable to create loyalty account.',
        ),
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'Unable to create loyalty account: $e',
      );
    }
  }

  // ============================================================
  // GENERATE TEMPORARY VISIT QR
  // ============================================================

  Future<LoyaltyVisitQrResponse> createVisitQr({
    required String businessId,
    required String mobileNumber,
  }) async {
    try {
      final response = await apiClient.post<dynamic>(
        '/api/public/loyalty/visit/qr',
        queryParameters: {
          'businessId': businessId,
          'mobileNumber': mobileNumber.trim(),
        },
      );

      final decoded = _decode(response.data);

      _validateResponse(
        response,
        decoded,
        'Unable to generate loyalty QR.',
      );

      final data = _extractDataMap(
        decoded,
        'Invalid loyalty QR data.',
      );

      return LoyaltyVisitQrResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
        _extractDioErrorMessage(
          e,
          'Unable to generate loyalty QR.',
        ),
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'Unable to generate loyalty QR: $e',
      );
    }
  }

  // ============================================================
  // ACTIVE REWARDS
  // ============================================================

  Future<List<LoyaltyRewardResponse>> getRewards({
    required String businessId,
  }) async {
    try {
      final response = await apiClient.get<dynamic>(
        '/api/public/loyalty/rewards',
        queryParameters: {
          'businessId': businessId,
        },
      );

      final decoded = _decode(response.data);

      _validateResponse(
        response,
        decoded,
        'Unable to load loyalty rewards.',
      );

      if (decoded is! Map<String, dynamic>) {
        throw Exception(
          'Invalid loyalty rewards response.',
        );
      }

      final data = decoded['data'];

      if (data == null) {
        return [];
      }

      if (data is! List) {
        throw Exception(
          'Invalid loyalty rewards data.',
        );
      }

      final rewards = <LoyaltyRewardResponse>[];

      for (final item in data) {
        if (item is! Map<String, dynamic>) {
          continue;
        }

        try {
          rewards.add(
            LoyaltyRewardResponse.fromJson(item),
          );
        } catch (_) {
          // Ignore malformed individual reward records.
        }
      }

      return rewards;
    } on DioException catch (e) {
      throw Exception(
        _extractDioErrorMessage(
          e,
          'Unable to load loyalty rewards.',
        ),
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'Unable to load loyalty rewards: $e',
      );
    }
  }

  // ============================================================
  // CLAIM REWARD
  // ============================================================

  Future<LoyaltyClaimResponse> claimReward({
    required String businessId,
    required String mobileNumber,
    required String rewardId,
  }) async {
    try {
      final response = await apiClient.post<dynamic>(
        '/api/public/loyalty/claim',
        queryParameters: {
          'businessId': businessId,
          'mobileNumber': mobileNumber.trim(),
        },
        data: {
          'rewardId': rewardId,
        },
      );

      final decoded = _decode(response.data);

      _validateResponse(
        response,
        decoded,
        'Unable to claim loyalty reward.',
      );

      final data = _extractDataMap(
        decoded,
        'Invalid loyalty claim data.',
      );

      return LoyaltyClaimResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
        _extractDioErrorMessage(
          e,
          'Unable to claim loyalty reward.',
        ),
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'Unable to claim loyalty reward: $e',
      );
    }
  }

  // ============================================================
  // RESPONSE DECODING
  // ============================================================

  dynamic _decode(dynamic responseData) {
    if (responseData == null) {
      throw Exception(
        'Empty server response.',
      );
    }

    if (responseData is Map<String, dynamic>) {
      return responseData;
    }

    if (responseData is Map) {
      return Map<String, dynamic>.from(
        responseData,
      );
    }

    if (responseData is List) {
      return responseData;
    }

    if (responseData is String) {
      final body = responseData.trim();

      if (body.isEmpty) {
        throw Exception(
          'Empty server response.',
        );
      }

      try {
        return jsonDecode(body);
      } catch (_) {
        throw Exception(
          'Invalid server response.',
        );
      }
    }

    throw Exception(
      'Invalid server response.',
    );
  }

  // ============================================================
  // DATA EXTRACTION
  // ============================================================

  Map<String, dynamic> _extractDataMap(
      dynamic decoded,
      String fallback,
      ) {
    if (decoded is! Map<String, dynamic>) {
      throw Exception(fallback);
    }

    final data = decoded['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(
      _message(decoded, fallback),
    );
  }

  // ============================================================
  // RESPONSE VALIDATION
  // ============================================================

  void _validateResponse(
      Response<dynamic> response,
      dynamic decoded,
      String fallback,
      ) {
    final statusCode = response.statusCode;

    if (statusCode == null ||
        statusCode < 200 ||
        statusCode >= 300) {
      throw Exception(
        _message(
          decoded,
          fallback,
        ),
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception(fallback);
    }

    if (decoded['success'] == false) {
      throw Exception(
        _message(
          decoded,
          fallback,
        ),
      );
    }
  }

  // ============================================================
  // DIO ERROR
  // ============================================================

  String _extractDioErrorMessage(
      DioException error,
      String fallback,
      ) {
    final responseData = error.response?.data;

    if (responseData != null) {
      try {
        final decoded = _decode(responseData);

        final message = _message(
          decoded,
          '',
        );

        if (message.isNotEmpty) {
          return message;
        }
      } catch (_) {}
    }

    final dioMessage = error.message?.trim();

    if (dioMessage != null &&
        dioMessage.isNotEmpty) {
      return dioMessage;
    }

    return fallback;
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  String _message(
      dynamic decoded,
      String fallback,
      ) {
    if (decoded is Map<String, dynamic>) {
      final message = decoded['message'];

      if (message != null) {
        final text = message.toString().trim();

        if (text.isNotEmpty) {
          return text;
        }
      }
    }

    return fallback;
  }
}