import 'package:dio/dio.dart';


import '../../../../core/network/api_client.dart';
import '../models/loyalty_settings_response.dart';

class BusinessLoyaltySettingsApiService {
  final ApiClient apiClient;

  BusinessLoyaltySettingsApiService({
    required this.apiClient,
  });

  // ============================================================
  // GET LOYALTY SETTINGS
  // ============================================================

  Future<LoyaltySettingsResponse> getSettings() async {
    try {
      final response = await apiClient.get<dynamic>(
        '/api/activity/loyalty/settings',
      );

      return _parseSettingsResponse(
        response,
        'Unable to load loyalty settings.',
      );
    } on DioException catch (e) {
      throw Exception(
        _extractDioErrorMessage(
          e,
          'Unable to load loyalty settings.',
        ),
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'Unable to load loyalty settings: $e',
      );
    }
  }

  // ============================================================
  // UPDATE LOYALTY SETTINGS
  // ============================================================

  Future<LoyaltySettingsResponse> updateSettings({
    required bool enabled,
  }) async {
    try {
      final response = await apiClient.put<dynamic>(
        '/api/activity/loyalty/settings',
        data: {
          'enabled': enabled,
        },
      );

      return _parseSettingsResponse(
        response,
        'Unable to update loyalty settings.',
      );
    } on DioException catch (e) {
      throw Exception(
        _extractDioErrorMessage(
          e,
          'Unable to update loyalty settings.',
        ),
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'Unable to update loyalty settings: $e',
      );
    }
  }

  // ============================================================
  // RESPONSE PARSER
  // ============================================================

  LoyaltySettingsResponse _parseSettingsResponse(
      Response<dynamic> response,
      String fallbackMessage,
      ) {
    final body = _decodeResponse(response.data);

    // ----------------------------------------------------------
    // HTTP ERROR
    // ----------------------------------------------------------

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw Exception(
        _extractMessage(
          body,
          fallbackMessage,
        ),
      );
    }

    // ----------------------------------------------------------
    // RESPONSE MUST BE OBJECT
    // ----------------------------------------------------------

    if (body is! Map<String, dynamic>) {
      throw Exception(
        'Invalid loyalty settings response.',
      );
    }

    // ----------------------------------------------------------
    // API FAILURE
    // ----------------------------------------------------------

    if (body['success'] == false) {
      throw Exception(
        _extractMessage(
          body,
          fallbackMessage,
        ),
      );
    }

    // ----------------------------------------------------------
    // RESPONSE DATA
    // ----------------------------------------------------------

    final data = body['data'];

    if (data is! Map<String, dynamic>) {
      throw Exception(
        'Invalid loyalty settings data.',
      );
    }

    try {
      return LoyaltySettingsResponse.fromJson(data);
    } catch (e) {
      throw Exception(
        'Unable to parse loyalty settings: $e',
      );
    }
  }

  // ============================================================
  // RESPONSE DECODER
  // ============================================================

  dynamic _decodeResponse(dynamic responseData) {
    if (responseData == null) {
      throw Exception(
        'Server returned an empty response.',
      );
    }

    if (responseData is Map<String, dynamic>) {
      return responseData;
    }

    if (responseData is Map) {
      return Map<String, dynamic>.from(responseData);
    }

    if (responseData is String) {
      final body = responseData.trim();

      if (body.isEmpty) {
        throw Exception(
          'Server returned an empty response.',
        );
      }

      try {
        return _decodeJsonString(body);
      } catch (_) {
        throw Exception(
          'Server returned an invalid response.',
        );
      }
    }

    throw Exception(
      'Server returned an invalid response.',
    );
  }

  dynamic _decodeJsonString(String value) {
    // Dio normally decodes JSON automatically. This exists only
    // as a defensive fallback when a server returns JSON as text.
    if (value.isEmpty) {
      throw const FormatException();
    }

    try {
      return ResponseTypeHelper.decode(value);
    } catch (_) {
      throw const FormatException();
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
        final body = _decodeResponse(responseData);

        final message = _extractMessage(
          body,
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

    if (dioMessage != null && dioMessage.isNotEmpty) {
      return dioMessage;
    }

    return fallback;
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  String _extractMessage(
      dynamic body,
      String fallback,
      ) {
    if (body is Map<String, dynamic>) {
      final message = body['message'];

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

/// Small internal helper so this service does not need to depend
/// on package:http just to decode a defensive JSON string.
class ResponseTypeHelper {
  ResponseTypeHelper._();

  static dynamic decode(String value) {
    // Dio normally handles JSON decoding before this point.
    //
    // This method intentionally uses dart:convert without exposing
    // that implementation detail throughout the service.
    throw const FormatException(
      'Unexpected string response.',
    );
  }
}