import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import 'api_client.dart';

class ImageUploadResponse {
  const ImageUploadResponse({
    required this.imageUrl,
    required this.publicId,
  });

  final String imageUrl;
  final String publicId;

  factory ImageUploadResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return ImageUploadResponse(
      imageUrl: json['imageUrl'] as String,
      publicId: json['publicId'] as String,
    );
  }
}

class ImageUploadService {
  ImageUploadService({
    required this.apiClient,
  });

  final ApiClient apiClient;

  Future<ImageUploadResponse> uploadCatalogImage(
      Uint8List bytes,
      String fileName,
      ) async {
    return _upload(
      bytes: bytes,
      fileName: fileName,
      type: 'CATALOG',
      errorMessage: 'Catalog image upload failed.',
    );
  }

  // Business Logo
  Future<ImageUploadResponse> uploadBusinessLogo(
      Uint8List bytes,
      String fileName,
      ) async {
    return _upload(
      bytes: bytes,
      fileName: fileName,
      type: 'BUSINESS',
      errorMessage:
      'Business logo upload failed.',
    );
  }

  Future<ImageUploadResponse> uploadPaymentScreenshot(
      Uint8List bytes,
      String fileName,
      ) async {
    return _upload(
      bytes: bytes,
      fileName: fileName,
      type: 'PAYMENT_SCREENSHOT',
      errorMessage: 'Payment screenshot upload failed.',
    );
  }

  Future<ImageUploadResponse> _upload({
    required Uint8List bytes,
    required String fileName,
    required String type,
    required String errorMessage,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
        'type': type,
      });

      final response =
      await apiClient.dio.post<Map<String, dynamic>>(
        ApiConstants.imageUpload,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      final body = response.data;

      if (body == null) {
        throw Exception(
          'Empty response from image server.',
        );
      }

      final data = body['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception(
          body['message'] ??
              'Image upload failed.',
        );
      }

      return ImageUploadResponse.fromJson(data);
    } on DioException catch (e) {
      final responseData = e.response?.data;

      if (responseData is Map<String, dynamic>) {
        final message = responseData['message'];

        if (message is String &&
            message.isNotEmpty) {
          throw Exception(message);
        }
      }

      if (e.type ==
          DioExceptionType.connectionError) {
        throw Exception(
          'Unable to connect to ScanAura server.',
        );
      }

      throw Exception(errorMessage);
    }
  }
}