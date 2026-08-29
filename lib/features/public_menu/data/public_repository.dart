import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static const String _menuCachePrefix =
      'scanaura_public_menu_';

  static const String _landingCachePrefix =
      'scanaura_public_landing_';

  // ============================================================
  // LANDING
  // ============================================================

  Future<LandingResponse> getLandingPage(
      String qrCode,
      ) async {
    final normalizedQrCode =
    qrCode.trim();

    final cacheKey =
        '$_landingCachePrefix$normalizedQrCode';

    try {
      final response =
      await apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.publicLanding}/$normalizedQrCode',
      );

      final body =
          response.data;

      if (body == null) {
        throw Exception(
          'Empty response from server.',
        );
      }

      final data =
      body['data'];

      if (data is! Map<String, dynamic>) {
        final message =
        body['message'];

        throw Exception(
          message is String &&
              message.isNotEmpty
              ? message
              : 'Unable to load business page.',
        );
      }

      final landing =
      LandingResponse.fromJson(data);

      await _saveLandingCache(
        cacheKey,
        landing,
      );

      return landing;
    } on DioException catch (error) {
      final cachedLanding =
      await _getCachedLanding(
        cacheKey,
      );

      if (cachedLanding != null) {
        return cachedLanding;
      }

      throw _handleError(
        error,
        fallback:
        'Unable to load business page.',
      );
    }
  }

  // ============================================================
  // MENU / CATALOG
  // ============================================================

  Future<MenuResponse> getMenu(
      String qrCode,
      ) async {
    final normalizedQrCode =
    qrCode.trim();

    final cacheKey =
        '$_menuCachePrefix$normalizedQrCode';

    try {
      final response =
      await apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.publicMenu}/$normalizedQrCode/menu',
      );

      final body =
          response.data;

      if (body == null) {
        throw Exception(
          'Empty response from server.',
        );
      }

      final data =
      body['data'];

      if (data is! Map<String, dynamic>) {
        final message =
        body['message'];

        throw Exception(
          message is String &&
              message.isNotEmpty
              ? message
              : 'Unable to load menu.',
        );
      }

      final menu =
      MenuResponse.fromJson(data);

      await _saveMenuCache(
        cacheKey,
        menu,
      );

      return menu;
    } on DioException catch (error) {
      final cachedMenu =
      await _getCachedMenu(
        cacheKey,
      );

      if (cachedMenu != null) {
        return cachedMenu;
      }

      throw _handleError(
        error,
        fallback:
        'Unable to load menu.',
      );
    }
  }

  // ============================================================
  // PAYMENT
  // ============================================================

  Future<PaymentResponse> getPaymentDetails(
      String qrCode,
      ) async {
    try {
      final response =
      await apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.publicPayment}/$qrCode/payment',
      );

      final body =
          response.data;

      if (body == null) {
        throw Exception(
          'Empty response from server.',
        );
      }

      final data =
      body['data'];

      if (data is! Map<String, dynamic>) {
        final message =
        body['message'];

        throw Exception(
          message is String &&
              message.isNotEmpty
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

  // ============================================================
  // LANDING CACHE
  // ============================================================

  Future<void> _saveLandingCache(
      String cacheKey,
      LandingResponse landing,
      ) async {
    try {
      final preferences =
      await SharedPreferences
          .getInstance();

      await preferences.setString(
        cacheKey,
        jsonEncode(
          landing.toJson(),
        ),
      );
    } catch (_) {
      // Cache failure must never
      // break the public experience.
    }
  }

  Future<LandingResponse?> _getCachedLanding(
      String cacheKey,
      ) async {
    try {
      final preferences =
      await SharedPreferences
          .getInstance();

      final cachedJson =
      preferences.getString(
        cacheKey,
      );

      if (cachedJson == null ||
          cachedJson.isEmpty) {
        return null;
      }

      final decoded =
      jsonDecode(cachedJson);

      if (decoded
      is! Map<String, dynamic>) {
        return null;
      }

      return LandingResponse.fromJson(
        decoded,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // MENU CACHE
  // ============================================================

  Future<void> _saveMenuCache(
      String cacheKey,
      MenuResponse menu,
      ) async {
    try {
      final preferences =
      await SharedPreferences
          .getInstance();

      await preferences.setString(
        cacheKey,
        jsonEncode(
          menu.toJson(),
        ),
      );
    } catch (_) {
      // Cache failure must never
      // break the public experience.
    }
  }

  Future<MenuResponse?> _getCachedMenu(
      String cacheKey,
      ) async {
    try {
      final preferences =
      await SharedPreferences
          .getInstance();

      final cachedJson =
      preferences.getString(
        cacheKey,
      );

      if (cachedJson == null ||
          cachedJson.isEmpty) {
        return null;
      }

      final decoded =
      jsonDecode(cachedJson);

      if (decoded
      is! Map<String, dynamic>) {
        return null;
      }

      return MenuResponse.fromJson(
        decoded,
      );
    } catch (_) {
      return null;
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

    switch (
    error.response?.statusCode) {
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