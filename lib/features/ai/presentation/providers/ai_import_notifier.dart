import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../data/ai_import_repository.dart';

import '../../data/models/ai_import_request.dart';

import '../../data/models/ai_menu_response.dart';
import 'ai_import_state.dart';

final aiImportRepositoryProvider =
Provider<AiImportRepository>((ref) {
  return AiImportRepository(
    apiClient: ref.read(apiClientProvider),
  );
});

final aiImportNotifierProvider =
NotifierProvider<
    AiImportNotifier,
    AiImportState>(
  AiImportNotifier.new,
);

class AiImportNotifier
    extends Notifier<AiImportState> {
  late final AiImportRepository _repository;

  @override
  AiImportState build() {
    _repository =
        ref.read(aiImportRepositoryProvider);

    return const AiImportState();
  }

  Future<AiMenuResponse?> analyzeMenu({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    if (bytes.isEmpty) {
      state = state.copyWith(
        status: AiImportStatus.error,
        errorMessage: 'Selected file is empty.',
        clearError: false,
      );

      return null;
    }

    state = state.copyWith(
      status: AiImportStatus.analyzing,
      clearMenuResponse: true,
      clearError: true,
    );

    try {
      final response =
      await _repository.analyzeMenu(
        bytes: bytes,
        fileName: fileName,
        mimeType: mimeType,
      );

      if (response.categories.isEmpty) {
        state = state.copyWith(
          status: AiImportStatus.error,
          errorMessage:
          'No menu items were detected. Please use a clearer menu file.',
        );

        return null;
      }

      state = state.copyWith(
        status: AiImportStatus.analyzed,
        menuResponse: response,
        clearError: true,
      );

      return response;
    } catch (e) {
      state = state.copyWith(
        status: AiImportStatus.error,
        errorMessage:
        _messageFromException(e),
      );

      return null;
    }
  }

  Future<bool> importMenu() async {
    final menuResponse =
        state.menuResponse;

    if (menuResponse == null) {
      state = state.copyWith(
        status: AiImportStatus.error,
        errorMessage:
        'No analyzed menu is available.',
      );

      return false;
    }

    state = state.copyWith(
      status: AiImportStatus.importing,
      clearError: true,
    );

    try {
      final request = AiImportRequest(
        overwriteExistingMenu:
        state.overwriteExistingMenu,
        categories:
        menuResponse.categories,
      );

      await _repository.importMenu(
        request,
      );

      state = state.copyWith(
        status: AiImportStatus.success,
        clearError: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        status: AiImportStatus.error,
        errorMessage:
        _messageFromException(e),
      );

      return false;
    }
  }

  void setOverwriteExistingMenu(
      bool value,
      ) {
    state = state.copyWith(
      overwriteExistingMenu: value,
    );
  }

  void reset() {
    state = const AiImportState();
  }

  void clearError() {
    state = state.copyWith(
      clearError: true,
    );
  }

  String _messageFromException(
      Object error,
      ) {
    if (error is Exception) {
      final message = error.toString();

      if (message.startsWith(
        'Exception: ',
      )) {
        return message.substring(11);
      }

      return message;
    }

    return 'Something went wrong. Please try again.';
  }
}