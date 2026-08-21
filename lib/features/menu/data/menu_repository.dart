import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

import 'models/category_request.dart';
import 'models/category_response.dart';
import 'models/catalog_request.dart';
import 'models/catalog_response.dart';

class MenuRepository {
  MenuRepository({
    required this.apiClient,
  });

  final ApiClient apiClient;

  // ============================================================
  // CATEGORY
  // ============================================================

  Future<List<CategoryResponse>> getCategories() async {
    try {
      final response =
      await apiClient.get<Map<String, dynamic>>(
        ApiConstants.categoryBase,
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
              'Unable to load categories.',
        );
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(CategoryResponse.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<CategoryResponse> createCategory(
      CategoryRequest request,
      ) async {
    try {
      final response =
      await apiClient.post<Map<String, dynamic>>(
        ApiConstants.categoryBase,
        data: request.toJson(),
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
              'Unable to create category.',
        );
      }

      return CategoryResponse.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<CategoryResponse> updateCategory(
      String id,
      CategoryRequest request,
      ) async {
    try {
      final response =
      await apiClient.put<Map<String, dynamic>>(
        ApiConstants.categoryById(id),
        data: request.toJson(),
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
              'Unable to update category.',
        );
      }

      return CategoryResponse.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteCategory(
      String id,
      ) async {
    try {
      await apiClient.delete<Map<String, dynamic>>(
        ApiConstants.categoryById(id),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================================
  // CATALOG / MENU
  // ============================================================

  Future<List<CatalogResponse>> getCatalogs() async {
    try {
      final response =
      await apiClient.get<Map<String, dynamic>>(
        ApiConstants.catalogBase,
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
              'Unable to load menu items.',
        );
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(CatalogResponse.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<CatalogResponse> getCatalog(
      String id,
      ) async {
    try {
      final response =
      await apiClient.get<Map<String, dynamic>>(
        ApiConstants.catalogById(id),
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
              'Unable to load menu item.',
        );
      }

      return CatalogResponse.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }


  Future<CatalogResponse> createCatalog(
      CatalogRequest request,
      ) async {
    try {
      final response =
      await apiClient.post<Map<String, dynamic>>(
        ApiConstants.catalog,
        data: request.toJson(),
      );

      final responseBody = response.data;

      if (responseBody == null) {
        throw Exception(
          'Empty response from server.',
        );
      }

      final data = responseBody['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception(
          responseBody['message'] ??
              'Unable to create menu item.',
        );
      }

      return CatalogResponse.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<CatalogResponse> updateCatalog(
      String id,
      CatalogRequest request,
      ) async {
    try {
      final response =
      await apiClient.put<Map<String, dynamic>>(
        ApiConstants.catalogById(id),
        data: request.toJson(),
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
              'Unable to update menu item.',
        );
      }

      return CatalogResponse.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteCatalog(
      String id,
      ) async {
    try {
      await apiClient.delete<Map<String, dynamic>>(
        ApiConstants.catalogById(id),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================================
  // ERROR HANDLING
  // ============================================================

  Exception _handleError(
      DioException error,
      ) {
    final statusCode =
        error.response?.statusCode;

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

    switch (statusCode) {
      case 400:
        return Exception(
          'Invalid menu request.',
        );

      case 401:
        return Exception(
          'Your session has expired.',
        );

      case 404:
        return Exception(
          'Menu item or category not found.',
        );

      case 409:
        return Exception(
          'This item already exists.',
        );

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