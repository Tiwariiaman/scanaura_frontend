import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'models/gallery_image.dart';

class GalleryRepository {
  GalleryRepository({
    required this.apiClient,
  });

  final ApiClient apiClient;

  // ============================================================
  // GET GALLERY
  // ============================================================

  Future<List<GalleryImage>> getGallery(
      String businessId,
      ) async {
    try {
      final response = await apiClient.get<dynamic>(
        ApiConstants.galleryByBusiness(businessId),
      );

      final body = response.data;

      return _parseGalleryList(
        body,
        fallbackMessage: 'Unable to load gallery.',
      );
    } on DioException catch (e) {
      throw _handleDioException(
        e,
        'Unable to load gallery.',
      );
    }
  }

  // ============================================================
  // ADD IMAGE
  // ============================================================

  Future<GalleryImage> addImage({
    required String businessId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
      });

      final response = await apiClient.post<dynamic>(
        ApiConstants.galleryByBusiness(businessId),
        data: formData,
      );

      final body = response.data;

      return _parseGalleryImage(
        body,
        fallbackMessage: 'Unable to add gallery image.',
      );
    } on DioException catch (e) {
      throw _handleDioException(
        e,
        'Unable to add gallery image.',
      );
    }
  }

  // ============================================================
  // REPLACE IMAGE
  // ============================================================

  Future<GalleryImage> replaceImage({
    required String businessId,
    required String imageId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
      });

      final response = await apiClient.put<dynamic>(
        ApiConstants.galleryImage(
          businessId,
          imageId,
        ),
        data: formData,
      );

      final body = response.data;

      return _parseGalleryImage(
        body,
        fallbackMessage: 'Unable to replace gallery image.',
      );
    } on DioException catch (e) {
      throw _handleDioException(
        e,
        'Unable to replace gallery image.',
      );
    }
  }

  // ============================================================
  // DELETE IMAGE
  // ============================================================

  Future<void> deleteImage({
    required String businessId,
    required String imageId,
  }) async {
    try {
      await apiClient.delete<dynamic>(
        ApiConstants.galleryImage(
          businessId,
          imageId,
        ),
      );
    } on DioException catch (e) {
      throw _handleDioException(
        e,
        'Unable to delete gallery image.',
      );
    }
  }

  // ============================================================
  // REORDER IMAGES
  // ============================================================

  Future<void> reorderImages({
    required String businessId,
    required List<String> imageIds,
  }) async {
    try {
      await apiClient.put<dynamic>(
        ApiConstants.galleryReorder(businessId),
        data: {
          'imageIds': imageIds,
        },
      );
    } on DioException catch (e) {
      throw _handleDioException(
        e,
        'Unable to reorder gallery images.',
      );
    }
  }

  // ============================================================
  // PARSE GALLERY LIST
  // ============================================================

  List<GalleryImage> _parseGalleryList(
      dynamic body, {
        required String fallbackMessage,
      }) {
    if (body is List) {
      return body
          .whereType<Map>()
          .map(
            (item) => GalleryImage.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    }

    if (body is! Map) {
      throw Exception(fallbackMessage);
    }

    final map = Map<String, dynamic>.from(body);

    /*
     * Supported:
     *
     * {
     *   "data": [...]
     * }
     *
     * OR
     *
     * {
     *   "galleryImages": [...]
     * }
     *
     * OR
     *
     * {
     *   "images": [...]
     * }
     */

    dynamic data = map['data'];

    if (data == null) {
      data = map['galleryImages'];
    }

    if (data == null) {
      data = map['images'];
    }

    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (item) => GalleryImage.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    }

    final message = map['message'];

    if (message is String &&
        message.trim().isNotEmpty) {
      throw Exception(message);
    }

    throw Exception(fallbackMessage);
  }

  // ============================================================
  // PARSE SINGLE GALLERY IMAGE
  // ============================================================

  GalleryImage _parseGalleryImage(
      dynamic body, {
        required String fallbackMessage,
      }) {
    /*
     * Supported successful responses:
     *
     * 1.
     * {
     *   "data": {
     *     "id": "...",
     *     "imageUrl": "...",
     *     "displayOrder": 0
     *   }
     * }
     *
     * 2.
     * {
     *   "id": "...",
     *   "imageUrl": "...",
     *   "displayOrder": 0
     * }
     *
     * 3.
     * {
     *   "data": [...]
     * }
     */

    if (body is! Map) {
      throw Exception(fallbackMessage);
    }

    final map = Map<String, dynamic>.from(body);

    dynamic data = map['data'];

    // Normal wrapped response.
    if (data is Map) {
      return GalleryImage.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    // Some APIs return the object directly.
    if (_looksLikeGalleryImage(map)) {
      return GalleryImage.fromJson(map);
    }

    // Some APIs may return a single-item list.
    if (data is List && data.isNotEmpty) {
      final first = data.first;

      if (first is Map) {
        return GalleryImage.fromJson(
          Map<String, dynamic>.from(first),
        );
      }
    }

    final galleryImage = map['galleryImage'];

    if (galleryImage is Map) {
      return GalleryImage.fromJson(
        Map<String, dynamic>.from(galleryImage),
      );
    }

    final message = map['message'];

    if (message is String &&
        message.trim().isNotEmpty) {
      throw Exception(message);
    }

    throw Exception(fallbackMessage);
  }

  // ============================================================
  // CHECK GALLERY IMAGE OBJECT
  // ============================================================

  bool _looksLikeGalleryImage(
      Map<String, dynamic> map,
      ) {
    return map.containsKey('id') &&
        (
            map.containsKey('imageUrl') ||
                map.containsKey('url')
        );
  }

  // ============================================================
  // ERROR HANDLING
  // ============================================================

  Exception _handleDioException(
      DioException error,
      String defaultMessage,
      ) {
    final responseData = error.response?.data;

    if (responseData is Map) {
      final map = Map<String, dynamic>.from(
        responseData,
      );

      final message = map['message'];

      if (message is String &&
          message.trim().isNotEmpty) {
        return Exception(message);
      }

      final errorMessage = map['error'];

      if (errorMessage is String &&
          errorMessage.trim().isNotEmpty) {
        return Exception(errorMessage);
      }

      final data = map['data'];

      if (data is Map) {
        final nestedMessage = data['message'];

        if (nestedMessage is String &&
            nestedMessage.trim().isNotEmpty) {
          return Exception(nestedMessage);
        }
      }
    }

    if (error.type ==
        DioExceptionType.connectionError) {
      return Exception(
        'Unable to connect to ScanAura server.',
      );
    }

    return Exception(defaultMessage);
  }
}