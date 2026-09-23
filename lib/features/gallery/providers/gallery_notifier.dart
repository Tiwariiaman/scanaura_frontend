import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../data/gallery_repository.dart';
import '../data/models/gallery_image.dart';


final galleryNotifierProvider = StateNotifierProvider.family<
    GalleryNotifier,
    GalleryState,
    String>((ref, businessId) {
  return GalleryNotifier(
    repository: ref.read(galleryRepositoryProvider),
    businessId: businessId,
  );
});

class GalleryState {
  const GalleryState({
    this.images = const [],
    this.isLoading = false,
    this.isUploading = false,
    this.isDeleting = false,
    this.isReplacing = false,
    this.isReordering = false,
    this.errorMessage,
  });

  final List<GalleryImage> images;

  final bool isLoading;
  final bool isUploading;
  final bool isDeleting;
  final bool isReplacing;
  final bool isReordering;

  final String? errorMessage;

  bool get isBusy =>
      isLoading ||
          isUploading ||
          isDeleting ||
          isReplacing ||
          isReordering;

  bool get canAddMore =>
      images.length < 12;

  GalleryState copyWith({
    List<GalleryImage>? images,
    bool? isLoading,
    bool? isUploading,
    bool? isDeleting,
    bool? isReplacing,
    bool? isReordering,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GalleryState(
      images: images ?? this.images,
      isLoading: isLoading ?? this.isLoading,
      isUploading:
      isUploading ?? this.isUploading,
      isDeleting:
      isDeleting ?? this.isDeleting,
      isReplacing:
      isReplacing ?? this.isReplacing,
      isReordering:
      isReordering ?? this.isReordering,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

class GalleryNotifier
    extends StateNotifier<GalleryState> {

  GalleryNotifier({
    required this.repository,
    required this.businessId,
  }) : super(const GalleryState());

  final GalleryRepository repository;
  final String businessId;

  // ------------------------------------------------------------
  // LOAD
  // ------------------------------------------------------------

  Future<void> loadGallery() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final images =
      await repository.getGallery(
        businessId,
      );

      state = state.copyWith(
        images: images,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _message(e),
      );
    }
  }

  // ------------------------------------------------------------
  // ADD IMAGE
  // ------------------------------------------------------------

  Future<bool> addImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (state.images.length >= 12) {
      state = state.copyWith(
        errorMessage:
        'Gallery can contain a maximum of 12 images.',
      );

      return false;
    }

    state = state.copyWith(
      isUploading: true,
      clearError: true,
    );

    try {
      final image =
      await repository.addImage(
        businessId: businessId,
        bytes: bytes,
        fileName: fileName,
      );

      state = state.copyWith(
        images: [
          ...state.images,
          image,
        ],
        isUploading: false,
        clearError: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: _message(e),
      );

      return false;
    }
  }

  // ------------------------------------------------------------
  // DELETE IMAGE
  // ------------------------------------------------------------

  Future<bool> deleteImage(
      String imageId,
      ) async {
    state = state.copyWith(
      isDeleting: true,
      clearError: true,
    );

    try {
      await repository.deleteImage(
        businessId: businessId,
        imageId: imageId,
      );

      final updatedImages =
      state.images
          .where(
            (image) => image.id != imageId,
      )
          .toList();

      /*
       * Recalculate local display order after deletion.
       */
      final normalizedImages =
      _normalizeOrder(
        updatedImages,
      );

      state = state.copyWith(
        images: normalizedImages,
        isDeleting: false,
        clearError: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        errorMessage: _message(e),
      );

      return false;
    }
  }

  // ------------------------------------------------------------
  // REPLACE IMAGE
  // ------------------------------------------------------------

  Future<bool> replaceImage({
    required String imageId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    state = state.copyWith(
      isReplacing: true,
      clearError: true,
    );

    try {
      final updatedImage =
      await repository.replaceImage(
        businessId: businessId,
        imageId: imageId,
        bytes: bytes,
        fileName: fileName,
      );

      final updatedImages =
      state.images.map((image) {
        if (image.id == imageId) {
          return updatedImage;
        }

        return image;
      }).toList();

      state = state.copyWith(
        images: updatedImages,
        isReplacing: false,
        clearError: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isReplacing: false,
        errorMessage: _message(e),
      );

      return false;
    }
  }

  // ------------------------------------------------------------
  // REORDER
  // ------------------------------------------------------------

  Future<bool> reorderImages(
      int oldIndex,
      int newIndex,
      ) async {
    if (oldIndex < 0 ||
        oldIndex >= state.images.length) {
      return false;
    }

    if (newIndex < 0 ||
        newIndex >= state.images.length) {
      return false;
    }

    if (oldIndex == newIndex) {
      return true;
    }

    final reordered =
    List<GalleryImage>.from(
      state.images,
    );

    final item =
    reordered.removeAt(oldIndex);

    reordered.insert(
      newIndex,
      item,
    );

    final normalized =
    _normalizeOrder(
      reordered,
    );

    /*
     * Optimistic UI:
     * show the new order immediately.
     */
    final previousImages =
        state.images;

    state = state.copyWith(
      images: normalized,
      isReordering: true,
      clearError: true,
    );

    try {
      await repository.reorderImages(
        businessId: businessId,
        imageIds: normalized
            .map((image) => image.id)
            .toList(),
      );

      state = state.copyWith(
        isReordering: false,
        clearError: true,
      );

      return true;
    } catch (e) {
      /*
       * Restore the previous order if the
       * backend rejects the reorder.
       */
      state = state.copyWith(
        images: previousImages,
        isReordering: false,
        errorMessage: _message(e),
      );

      return false;
    }
  }

  // ------------------------------------------------------------
  // CLEAR ERROR
  // ------------------------------------------------------------

  void clearError() {
    state = state.copyWith(
      clearError: true,
    );
  }

  // ------------------------------------------------------------
  // HELPERS
  // ------------------------------------------------------------

  List<GalleryImage> _normalizeOrder(
      List<GalleryImage> images,
      ) {
    return List.generate(
      images.length,
          (index) {
        final image = images[index];

        return GalleryImage(
          id: image.id,
          imageUrl: image.imageUrl,
          displayOrder: index,
        );
      },
    );
  }

  String _message(Object error) {
    final message =
    error.toString();

    if (message.startsWith(
      'Exception: ',
    )) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }
}