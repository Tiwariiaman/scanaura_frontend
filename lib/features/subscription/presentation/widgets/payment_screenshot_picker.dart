import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PaymentScreenshotPicker
    extends StatefulWidget {
  const PaymentScreenshotPicker({
    super.key,
    required this.onSelected,
  });

  final ValueChanged<Uint8List?> onSelected;

  @override
  State<PaymentScreenshotPicker>
  createState() =>
      _PaymentScreenshotPickerState();
}

class _PaymentScreenshotPickerState
    extends State<PaymentScreenshotPicker> {
  final ImagePicker _picker =
  ImagePicker();

  Uint8List? _imageBytes;

  bool _isPicking = false;

  Future<void> _pickImage() async {
    if (_isPicking) {
      return;
    }

    setState(() {
      _isPicking = true;
    });

    try {
      final file =
      await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (file == null) {
        return;
      }

      final bytes =
      await file.readAsBytes();

      if (!mounted) {
        return;
      }

      setState(() {
        _imageBytes = bytes;
      });

      widget.onSelected(bytes);
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior:
            SnackBarBehavior.floating,
            content: Text(
              'Unable to select the screenshot.',
            ),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isPicking = false;
        });
      }
    }
  }

  void _removeImage() {
    setState(() {
      _imageBytes = null;
    });

    widget.onSelected(null);
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        final width =
            constraints.maxWidth;

        final compact =
            width < 380;

        final imageHeight =
        compact ? 170.0 : 210.0;

        return Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // ==========================================================
            // PICKER
            // ==========================================================

            InkWell(
              onTap: _isPicking
                  ? null
                  : _pickImage,
              borderRadius:
              BorderRadius.circular(
                16,
              ),
              child: Container(
                width:
                double.infinity,
                height: imageHeight,
                decoration:
                BoxDecoration(
                  color: theme
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(
                    alpha: 0.35,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    16,
                  ),
                  border:
                  Border.all(
                    color: theme
                        .colorScheme
                        .outlineVariant,
                  ),
                ),
                clipBehavior:
                Clip.antiAlias,
                child:
                _buildContent(
                  context,
                ),
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            // ==========================================================
            // ACTIONS
            // ==========================================================

            Row(
              children: [
                Expanded(
                  child:
                  OutlinedButton.icon(
                    onPressed:
                    _isPicking
                        ? null
                        : _pickImage,
                    icon: _isPicking
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child:
                      CircularProgressIndicator(
                        strokeWidth:
                        2,
                      ),
                    )
                        : const Icon(
                      Icons
                          .photo_library_outlined,
                    ),
                    label: Text(
                      _imageBytes == null
                          ? 'Choose Screenshot'
                          : 'Change Screenshot',
                    ),
                  ),
                ),

                if (_imageBytes !=
                    null) ...[
                  const SizedBox(
                    width: 8,
                  ),
                  IconButton(
                    tooltip:
                    'Remove screenshot',
                    onPressed:
                    _isPicking
                        ? null
                        : _removeImage,
                    icon: const Icon(
                      Icons
                          .delete_outline,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              _imageBytes == null
                  ? 'Upload the screenshot of your completed UPI payment.'
                  : 'Screenshot selected. You can change it before submitting.',
              style: theme
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                color: theme
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent(
      BuildContext context,
      ) {
    if (_isPicking) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    if (_imageBytes == null) {
      return Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment:
            Alignment.center,
            decoration:
            BoxDecoration(
              color: Theme.of(
                context,
              )
                  .colorScheme
                  .primaryContainer,
              shape:
              BoxShape.circle,
            ),
            child: Icon(
              Icons
                  .cloud_upload_outlined,
              size: 30,
              color: Theme.of(
                context,
              )
                  .colorScheme
                  .onPrimaryContainer,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          const Text(
            'Upload payment screenshot',
            textAlign:
            TextAlign.center,
            style: TextStyle(
              fontWeight:
              FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            'Tap here to select an image',
            textAlign:
            TextAlign.center,
            style: TextStyle(
              color: Theme.of(
                context,
              )
                  .colorScheme
                  .onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(
          _imageBytes!,
          fit: BoxFit.cover,
          errorBuilder: (
              context,
              error,
              stackTrace,
              ) {
            return Center(
              child: Padding(
                padding:
                const EdgeInsets.all(
                  16,
                ),
                child: Text(
                  'Unable to preview image.',
                  textAlign:
                  TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    )
                        .colorScheme
                        .error,
                  ),
                ),
              ),
            );
          },
        ),

        // Bottom overlay
        Align(
          alignment:
          Alignment.bottomCenter,
          child: Container(
            width:
            double.infinity,
            padding:
            const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            color:
            Colors.black54,
            child: const Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .center,
              children: [
                Icon(
                  Icons
                      .check_circle_outline,
                  color:
                  Colors.white,
                  size: 18,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Payment screenshot selected',
                  style:
                  TextStyle(
                    color:
                    Colors.white,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}