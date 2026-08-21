import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PaymentScreenshotPicker extends StatefulWidget {
  const PaymentScreenshotPicker({
    super.key,
    required this.onSelected,
  });

  final ValueChanged<Uint8List?> onSelected;

  @override
  State<PaymentScreenshotPicker> createState() =>
      _PaymentScreenshotPickerState();
}

class _PaymentScreenshotPickerState
    extends State<PaymentScreenshotPicker> {
  final ImagePicker _picker = ImagePicker();

  Uint8List? _imageBytes;

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (file == null) {
      return;
    }

    final bytes = await file.readAsBytes();

    setState(() {
      _imageBytes = bytes;
    });

    widget.onSelected(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Screenshot',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline,
              ),
            ),
            child: _imageBytes == null
                ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 40,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Upload payment screenshot',
                  ),
                ],
              ),
            )
                : ClipRRect(
              borderRadius:
              BorderRadius.circular(16),
              child: Image.memory(
                _imageBytes!,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}