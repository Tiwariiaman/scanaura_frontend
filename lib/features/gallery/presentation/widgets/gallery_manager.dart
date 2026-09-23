import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/image_compression_helper.dart';
import '../../data/models/gallery_image.dart';

import '../../providers/gallery_notifier.dart';

class GalleryManager extends ConsumerStatefulWidget {
  const GalleryManager({
    super.key,
    required this.businessId,
  });

  final String businessId;

  @override
  ConsumerState<GalleryManager> createState() =>
      _GalleryManagerState();
}

class _GalleryManagerState
    extends ConsumerState<GalleryManager> {
  static const int _maxImages = 12;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(
        galleryNotifierProvider(
          widget.businessId,
        ).notifier,
      )
          .loadGallery();
    });
  }

  // ============================================================
  // ADD IMAGES
  // ============================================================

  Future<void> _pickImages() async {
    final notifier = ref.read(
      galleryNotifierProvider(
        widget.businessId,
      ).notifier,
    );

    final state = ref.read(
      galleryNotifierProvider(
        widget.businessId,
      ),
    );

    if (!state.canAddMore) {
      _showMessage(
        'Gallery already contains $_maxImages images.',
      );
      return;
    }

    final remaining =
        _maxImages - state.images.length;

    try {
      final result =
      await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );

      if (result == null ||
          result.files.isEmpty) {
        return;
      }

      final selected =
      result.files
          .where(
            (file) =>
        file.bytes != null &&
            file.bytes!.isNotEmpty,
      )
          .toList();

      if (selected.isEmpty) {
        _showMessage(
          'Unable to read the selected images.',
        );
        return;
      }

      final filesToUpload =
      selected.take(remaining).toList();

      if (selected.length > remaining) {
        _showMessage(
          'Only $remaining more image${remaining == 1 ? '' : 's'} can be added.',
        );
      }

      for (final file in filesToUpload) {
        if (file.bytes == null) {
          continue;
        }

        final compressed =
        await ImageCompressionHelper
            .compressLogo(
          file.bytes!,
        );

        await notifier.addImage(
          bytes: compressed,
          fileName: file.name,
        );
      }

      if (!mounted) return;

      final latestState = ref.read(
        galleryNotifierProvider(
          widget.businessId,
        ),
      );

      if (latestState.errorMessage != null) {
        _showMessage(
          latestState.errorMessage!,
        );
      } else {
        _showMessage(
          filesToUpload.length == 1
              ? 'Photo added to gallery.'
              : '${filesToUpload.length} photos added to gallery.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        _cleanError(e),
      );
    }
  }

  // ============================================================
  // REPLACE IMAGE
  // ============================================================

  Future<void> _replaceImage(
      GalleryImage image,
      ) async {
    try {
      final result =
      await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result == null ||
          result.files.isEmpty) {
        return;
      }

      final file = result.files.first;

      if (file.bytes == null ||
          file.bytes!.isEmpty) {
        _showMessage(
          'Unable to read the selected image.',
        );
        return;
      }

      final compressed =
      await ImageCompressionHelper
          .compressLogo(
        file.bytes!,
      );

      await ref
          .read(
        galleryNotifierProvider(
          widget.businessId,
        ).notifier,
      )
          .replaceImage(
        imageId: image.id,
        bytes: compressed,
        fileName: file.name,
      );
      if (!mounted) return;

      final state = ref.read(
        galleryNotifierProvider(
          widget.businessId,
        ),
      );

      if (state.errorMessage != null) {
        _showMessage(
          state.errorMessage!,
        );
      } else {
        _showMessage(
          'Photo replaced successfully.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        _cleanError(e),
      );
    }
  }

  // ============================================================
  // DELETE IMAGE
  // ============================================================

  Future<void> _deleteImage(
      GalleryImage image,
      ) async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete photo?',
          ),
          content: const Text(
            'This photo will be removed from your gallery and public page.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              style:
              FilledButton.styleFrom(
                backgroundColor:
                Theme.of(context)
                    .colorScheme
                    .error,
                foregroundColor:
                Theme.of(context)
                    .colorScheme
                    .onError,
              ),
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref
          .read(
        galleryNotifierProvider(
          widget.businessId,
        ).notifier,
      )
          .deleteImage(
        image.id,
      );

      if (!mounted) return;

      final state = ref.read(
        galleryNotifierProvider(
          widget.businessId,
        ),
      );

      if (state.errorMessage != null) {
        _showMessage(
          state.errorMessage!,
        );
      } else {
        _showMessage(
          'Photo deleted.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        _cleanError(e),
      );
    }
  }

  // ============================================================
  // REORDER
  // ============================================================

  Future<void> _reorderImages(
      int oldIndex,
      int newIndex,
      ) async {
    if (oldIndex == newIndex) {
      return;
    }

    await ref
        .read(
      galleryNotifierProvider(
        widget.businessId,
      ).notifier,
    )
        .reorderImages(
      oldIndex,
      newIndex,
    );

    if (!mounted) return;

    final state = ref.read(
      galleryNotifierProvider(
        widget.businessId,
      ),
    );

    if (state.errorMessage != null) {
      _showMessage(
        state.errorMessage!,
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      galleryNotifierProvider(
        widget.businessId,
      ),
    );

    final theme =
    Theme.of(context);

    final scheme =
        theme.colorScheme;

    return Container(
      decoration:
      BoxDecoration(
        color: scheme.surface,
        borderRadius:
        BorderRadius.circular(
          26,
        ),
        border: Border.all(
          color: scheme
              .outlineVariant
              .withOpacity(.42),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(.025),
            blurRadius: 25,
            offset:
            const Offset(
              0,
              8,
            ),
          ),
        ],
      ),
      child: Padding(
        padding:
        const EdgeInsets.all(
          18,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _buildHeader(
              context,
              state,
            ),

            const SizedBox(
              height: 16,
            ),

            if (state.isLoading)
              _buildLoading(
                context,
              )
            else if (state.images.isEmpty)
              _buildEmptyState(
                context,
                state,
              )
            else ...[
                _buildGalleryCount(
                  context,
                  state,
                ),

                const SizedBox(
                  height: 12,
                ),

                _buildThumbnailStrip(
                  context,
                  state,
                ),

                const SizedBox(
                  height: 14,
                ),

                _buildGalleryHint(
                  context,
                ),
              ],

            if (state.errorMessage != null) ...[
              const SizedBox(
                height: 12,
              ),
              _buildError(
                context,
                state.errorMessage!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(
      BuildContext context,
      GalleryState state,
      ) {
    final theme =
    Theme.of(context);

    final scheme =
        theme.colorScheme;

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration:
          BoxDecoration(
            color:
            scheme.primaryContainer,
            borderRadius:
            BorderRadius.circular(
              15,
            ),
          ),
          child: Icon(
            Icons
                .photo_library_rounded,
            color:
            scheme
                .onPrimaryContainer,
            size: 22,
          ),
        ),

        const SizedBox(
          width: 12,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Gallery',
                style: theme
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                  fontWeight:
                  FontWeight.w800,
                  letterSpacing:
                  -.2,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                'Show your best business moments on your public page.',
                style: theme
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                  color: scheme
                      .onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          width: 8,
        ),

        IconButton.filledTonal(
          tooltip:
          'Add photos',
          onPressed:
          state.isBusy ||
              !state.canAddMore
              ? null
              : _pickImages,
          icon: const Icon(
            Icons
                .add_photo_alternate_rounded,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // COUNT
  // ============================================================

  Widget _buildGalleryCount(
      BuildContext context,
      GalleryState state,
      ) {
    final theme =
    Theme.of(context);

    final scheme =
        theme.colorScheme;

    final count =
        state.images.length;

    return Row(
      children: [
        Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration:
          BoxDecoration(
            color:
            scheme.surfaceContainerHighest,
            borderRadius:
            BorderRadius.circular(
              20,
            ),
          ),
          child: Text(
            '$count/$_maxImages photos',
            style: theme
                .textTheme
                .labelMedium
                ?.copyWith(
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(
          width: 8,
        ),

        if (count <
            _maxImages)
          Text(
            'You can add ${_maxImages - count} more',
            style: theme
                .textTheme
                .bodySmall
                ?.copyWith(
              color: scheme
                  .onSurfaceVariant,
            ),
          )
        else
          Text(
            'Gallery limit reached',
            style: theme
                .textTheme
                .bodySmall
                ?.copyWith(
              color:
              scheme.error,
              fontWeight:
              FontWeight.w600,
            ),
          ),
      ],
    );
  }

  // ============================================================
  // THUMBNAILS
  // ============================================================

  Widget _buildThumbnailStrip(
      BuildContext context,
      GalleryState state,
      ) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    return SizedBox(
      height: 150,
      child:
      ReorderableListView.builder(
        scrollDirection:
        Axis.horizontal,
        buildDefaultDragHandles:
        false,
        padding:
        const EdgeInsets.only(
          right: 4,
        ),
        itemCount:
        state.images.length,
        onReorder:
        _reorderImages,
        proxyDecorator:
            (
            child,
            index,
            animation,
            ) {
          return AnimatedBuilder(
            animation:
            animation,
            builder:
                (
                context,
                child,
                ) {
              final scale =
                  1 +
                      (animation
                          .value *
                          .04);

              return Transform.scale(
                scale: scale,
                child: Material(
                  elevation:
                  8,
                  color: Colors
                      .transparent,
                  borderRadius:
                  BorderRadius
                      .circular(
                    18,
                  ),
                  child:
                  child,
                ),
              );
            },
            child: child,
          );
        },
        itemBuilder:
            (
            context,
            index,
            ) {
          final image =
          state.images[index];

          return Padding(
            key: ValueKey(
              image.id,
            ),
            padding:
            const EdgeInsets
                .only(
              right: 12,
            ),
            child:
            _buildGalleryItem(
              context,
              image,
              index,
              state,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // GALLERY ITEM
  // ============================================================

  Widget _buildGalleryItem(
      BuildContext context,
      GalleryImage image,
      int index,
      GalleryState state,
      ) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    return SizedBox(
      width: 126,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius:
              BorderRadius.circular(
                18,
              ),
              child: Image.network(
                image.imageUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (
                    _,
                    __,
                    ___,
                    ) {
                  return Container(
                    color: scheme
                        .surfaceContainerHighest,
                    child: Icon(
                      Icons
                          .broken_image_outlined,
                      color: scheme
                          .onSurfaceVariant,
                    ),
                  );
                },
                loadingBuilder:
                    (
                    context,
                    child,
                    progress,
                    ) {
                  if (progress ==
                      null) {
                    return child;
                  }

                  return Container(
                    color: scheme
                        .surfaceContainerHighest,
                    alignment:
                    Alignment.center,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      value: progress
                          .expectedTotalBytes !=
                          null
                          ? progress
                          .cumulativeBytesLoaded /
                          progress
                              .expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),

          Positioned.fill(
            child: DecoratedBox(
              decoration:
              BoxDecoration(
                borderRadius:
                BorderRadius
                    .circular(
                  18,
                ),
                gradient:
                LinearGradient(
                  begin:
                  Alignment.topCenter,
                  end:
                  Alignment.bottomCenter,
                  colors: [
                    Colors.black
                        .withOpacity(
                      .08,
                    ),
                    Colors.black
                        .withOpacity(
                      .58,
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 7,
                vertical: 4,
              ),
              decoration:
              BoxDecoration(
                color: Colors.black
                    .withOpacity(.48),
                borderRadius:
                BorderRadius.circular(
                  10,
                ),
              ),
              child: Text(
                '${index + 1}',
                style:
                const TextStyle(
                  color:
                  Colors.white,
                  fontSize: 11,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),
          ),

          Positioned(
            top: 5,
            right: 5,
            child:
            ReorderableDragStartListener(
              index: index,
              child: Container(
                width: 34,
                height: 34,
                decoration:
                BoxDecoration(
                  color: Colors.black
                      .withOpacity(
                    .48,
                  ),
                  shape:
                  BoxShape.circle,
                ),
                child: const Icon(
                  Icons
                      .drag_indicator_rounded,
                  color:
                  Colors.white,
                  size: 19,
                ),
              ),
            ),
          ),

          Positioned(
            left: 7,
            right: 7,
            bottom: 7,
            child: Row(
              children: [
                Expanded(
                  child:
                  _thumbnailAction(
                    context,
                    icon: Icons
                        .edit_rounded,
                    tooltip:
                    'Replace',
                    onPressed:
                    state.isBusy
                        ? null
                        : () =>
                        _replaceImage(
                          image,
                        ),
                  ),
                ),
                const SizedBox(
                  width: 6,
                ),
                _thumbnailAction(
                  context,
                  icon: Icons
                      .delete_outline_rounded,
                  tooltip:
                  'Delete',
                  danger: true,
                  onPressed:
                  state.isBusy
                      ? null
                      : () =>
                      _deleteImage(
                        image,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumbnailAction(
      BuildContext context, {
        required IconData icon,
        required String tooltip,
        required VoidCallback? onPressed,
        bool danger = false,
      }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.black
            .withOpacity(.52),
        borderRadius:
        BorderRadius.circular(
          11,
        ),
        child: InkWell(
          onTap:
          onPressed,
          borderRadius:
          BorderRadius.circular(
            11,
          ),
          child: Padding(
            padding:
            const EdgeInsets.all(
              8,
            ),
            child: Icon(
              icon,
              size: 17,
              color: danger
                  ? Colors.red.shade200
                  : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(
      BuildContext context,
      GalleryState state,
      ) {
    final theme =
    Theme.of(context);

    final scheme =
        theme.colorScheme;

    return Container(
      width:
      double.infinity,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 28,
      ),
      decoration:
      BoxDecoration(
        color: scheme
            .surfaceContainerLowest,
        borderRadius:
        BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color: scheme
              .outlineVariant
              .withOpacity(.55),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration:
            BoxDecoration(
              color: scheme
                  .primaryContainer,
              shape:
              BoxShape.circle,
            ),
            child: Icon(
              Icons
                  .add_photo_alternate_outlined,
              size: 30,
              color: scheme
                  .onPrimaryContainer,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          Text(
            'Your gallery is empty',
            style: theme
                .textTheme
                .titleMedium
                ?.copyWith(
              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            'Add photos of your business, products, space or work.',
            textAlign:
            TextAlign.center,
            style: theme
                .textTheme
                .bodySmall
                ?.copyWith(
              color: scheme
                  .onSurfaceVariant,
              height: 1.4,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          FilledButton.icon(
            onPressed:
            state.isBusy
                ? null
                : _pickImages,
            icon: const Icon(
              Icons
                  .add_photo_alternate_rounded,
            ),
            label: const Text(
              'Add Photos',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading(
      BuildContext context,
      ) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    return SizedBox(
      height: 150,
      child: Center(
        child:
        CircularProgressIndicator(
          color: scheme.primary,
        ),
      ),
    );
  }

  // ============================================================
  // HINT
  // ============================================================

  Widget _buildGalleryHint(
      BuildContext context,
      ) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration:
      BoxDecoration(
        color: scheme
            .surfaceContainerLowest,
        borderRadius:
        BorderRadius.circular(
          13,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons
                .drag_indicator_rounded,
            size: 18,
            color: scheme
                .onSurfaceVariant,
          ),
          const SizedBox(
            width: 7,
          ),
          Expanded(
            child: Text(
              'Drag photos to change their order. The first photo appears first on your public page.',
              style: Theme.of(
                context,
              )
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                color: scheme
                    .onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(
      BuildContext context,
      String message,
      ) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    return Container(
      padding:
      const EdgeInsets.all(
        12,
      ),
      decoration:
      BoxDecoration(
        color: scheme.error
            .withOpacity(.08),
        borderRadius:
        BorderRadius.circular(
          14,
        ),
        border: Border.all(
          color: scheme.error
              .withOpacity(.18),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons
                .error_outline_rounded,
            size: 19,
            color: scheme.error,
          ),
          const SizedBox(
            width: 9,
          ),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              )
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                color: scheme.error,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message,
      ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
          Text(message),
          behavior:
          SnackBarBehavior.floating,
          margin:
          const EdgeInsets.all(
            16,
          ),
          duration:
          const Duration(
            seconds: 3,
          ),
        ),
      );
  }

  // ============================================================
  // ERROR
  // ============================================================

  String _cleanError(
      Object error,
      ) {
    final value =
    error.toString();

    if (value.startsWith(
      'Exception: ',
    )) {
      return value.substring(
        11,
      );
    }

    return value;
  }
}