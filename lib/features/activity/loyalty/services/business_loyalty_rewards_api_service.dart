import 'dart:convert';

import 'package:dio/dio.dart';


import '../../../../core/network/api_client.dart';
import '../models/loyalty_reward_response.dart';

class BusinessLoyaltyRewardsApiService {
  final ApiClient apiClient;

  BusinessLoyaltyRewardsApiService({
    required this.apiClient,
  });

  // ============================================================
  // GET ALL BUSINESS REWARDS
  // ============================================================

  Future<List<LoyaltyRewardResponse>> getRewards() async {
    try {
      final response = await apiClient.get<dynamic>(
        '/api/activity/loyalty/rewards',
      );

      final decoded = _decode(response.data);

      _validateResponse(
        response,
        decoded,
        'Unable to load loyalty rewards.',
      );

      if (decoded is! Map<String, dynamic>) {
        throw Exception(
          'Invalid rewards response.',
        );
      }

      final data = decoded['data'];

      if (data == null) {
        return [];
      }

      if (data is! List) {
        throw Exception(
          'Invalid rewards data.',
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
          // Ignore malformed individual reward entries.
          // The remaining valid rewards can still be displayed.
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
  // CREATE REWARD
  // ============================================================

  Future<LoyaltyRewardResponse> createReward({
    required String title,
    required int pointsRequired,
    required double rewardAmount,
  }) async {
    try {
      final response = await apiClient.post<dynamic>(
        '/api/activity/loyalty/rewards',
        data: {
          'title': title.trim(),
          'pointsRequired': pointsRequired,
          'rewardAmount': rewardAmount,
        },
      );

      return _rewardResponse(
        response,
        'Unable to create loyalty reward.',
      );
    } on DioException catch (e) {
      throw Exception(
        _extractDioErrorMessage(
          e,
          'Unable to create loyalty reward.',
        ),
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'Unable to create loyalty reward: $e',
      );
    }
  }

  // ============================================================
  // UPDATE REWARD
  // ============================================================

  Future<LoyaltyRewardResponse> updateReward({
    required String rewardId,
    required String title,
    required int pointsRequired,
    required double rewardAmount,
    required bool active,
  }) async {
    try {
      final response = await apiClient.put<dynamic>(
        '/api/activity/loyalty/rewards/$rewardId',
        data: {
          'title': title.trim(),
          'pointsRequired': pointsRequired,
          'rewardAmount': rewardAmount,
          'active': active,
        },
      );

      return _rewardResponse(
        response,
        'Unable to update loyalty reward.',
      );
    } on DioException catch (e) {
      throw Exception(
        _extractDioErrorMessage(
          e,
          'Unable to update loyalty reward.',
        ),
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'Unable to update loyalty reward: $e',
      );
    }
  }

  // ============================================================
  // DELETE / DEACTIVATE REWARD
  // ============================================================

  Future<void> deleteReward({
    required String rewardId,
  }) async {
    try {
      final response = await apiClient.delete<dynamic>(
        '/api/activity/loyalty/rewards/$rewardId',
      );

      final decoded = _decode(response.data);

      _validateResponse(
        response,
        decoded,
        'Unable to remove loyalty reward.',
      );
    } on DioException catch (e) {
      throw Exception(
        _extractDioErrorMessage(
          e,
          'Unable to remove loyalty reward.',
        ),
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'Unable to remove loyalty reward: $e',
      );
    }
  }

  // ============================================================
  // REWARD RESPONSE
  // ============================================================

  LoyaltyRewardResponse _rewardResponse(
      Response<dynamic> response,
      String fallback,
      ) {
    final decoded = _decode(response.data);

    _validateResponse(
      response,
      decoded,
      fallback,
    );

    if (decoded is! Map<String, dynamic>) {
      throw Exception(fallback);
    }

    final data = decoded['data'];

    if (data is! Map<String, dynamic>) {
      throw Exception(
        _message(
          decoded,
          fallback,
        ),
      );
    }

    try {
      return LoyaltyRewardResponse.fromJson(data);
    } catch (_) {
      throw Exception(
        'Invalid loyalty reward data received from server.',
      );
    }
  }

  // ============================================================
  // RESPONSE DECODER
  // ============================================================

  dynamic _decode(
      dynamic responseData,
      ) {
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
  // DIO ERROR MESSAGE
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
      } catch (_) {
        // Fall through to Dio's own message/fallback.
      }
    }

    final dioMessage = error.message?.trim();

    if (dioMessage != null &&
        dioMessage.isNotEmpty) {
      return dioMessage;
    }

    return fallback;
  }

  // ============================================================
  // SERVER MESSAGE
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