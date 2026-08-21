import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'models/ai_import_request.dart';
import 'models/ai_menu_response.dart';

class AiImportRepository {
  AiImportRepository({
    required this.apiClient,
  });

  final ApiClient apiClient;

  Future<AiMenuResponse> analyzeMenu({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
          contentType: DioMediaType.parse(mimeType),
        ),
      });

      final response =
      await apiClient.dio.post<Map<String, dynamic>>(
        ApiConstants.aiMenuAnalyze,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      final body = response.data;

      if (body == null) {
        throw Exception(
          'Empty response from AI server.',
        );
      }

      final data = body['data'];

      if (data is! Map<String, dynamic>) {
        final message = body['message'];

        throw Exception(
          message is String && message.isNotEmpty
              ? message
              : 'Unable to analyze menu.',
        );
      }

      return AiMenuResponse.fromJson(data);
    } on DioException catch (error) {
      throw _handleError(
        error,
        fallback:
        'Unable to analyze menu. Please try again.',
      );
    }
  }

  Future<void> importMenu(
      AiImportRequest request,
      ) async {
    try {
      final response =
      await apiClient.post<Map<String, dynamic>>(
        ApiConstants.aiMenuImport,
        data: request.toJson(),
      );

      final body = response.data;

      if (body == null) {
        throw Exception(
          'Empty response from AI import server.',
        );
      }

      final success = body['success'];

      if (success == false) {
        final message = body['message'];

        throw Exception(
          message is String && message.isNotEmpty
              ? message
              : 'Unable to import menu.',
        );
      }
    } on DioException catch (error) {
      throw _handleError(
        error,
        fallback:
        'Unable to import menu. Please try again.',
      );
    }
  }

  Exception _handleError(
      DioException error, {
        required String fallback,
      }) {
    final responseData = error.response?.data;

    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];

      if (message is String && message.isNotEmpty) {
        return Exception(message);
      }
    }

    switch (error.response?.statusCode) {
      case 400:
        return Exception(
          'Invalid menu import request.',
        );

      case 401:
        return Exception(
          'Your session has expired.',
        );

      case 404:
        return Exception(
          'AI menu service not found.',
        );

      case 409:
        return Exception(
          'Unable to import menu because of a conflict.',
        );

      case 413:
        return Exception(
          'The selected file is too large.',
        );

      case 429:
        return Exception(
          'AI import limit reached for your plan.',
        );

      case 500:
        return Exception(
          'AI service is temporarily unavailable.',
        );
    }

    if (error.type ==
        DioExceptionType.connectionError) {
      return Exception(
        'Unable to connect to ScanAura server.',
      );
    }

    return Exception(fallback);
  }
}