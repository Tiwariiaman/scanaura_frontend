import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/ai_file_service.dart';
import '../data/ai_image_compressor.dart';
import 'ai_import_preview_screen.dart';
import 'ai_import_review_screen.dart';
import 'providers/ai_import_notifier.dart';

class AiImportScreen extends ConsumerStatefulWidget {
  const AiImportScreen({super.key});

  @override
  ConsumerState<AiImportScreen> createState() =>
      _AiImportScreenState();
}

class _AiImportScreenState
    extends ConsumerState<AiImportScreen> {
  final AiFileService _fileService = AiFileService();

  final AiImageCompressor _compressor =
  const AiImageCompressor();

  bool _isProcessing = false;

  Future<void> _pickFromCamera() async {
    await _handleSelection(
      _fileService.pickFromCamera,
    );
  }

  Future<void> _pickFromGalleryOrFile() async {
    await _handleSelection(
      _fileService.pickFromGalleryOrFile,
    );
  }

  Future<void> _handleSelection(
      Future<AiSelectedFile?> Function() picker,
      ) async {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final selectedFile = await picker();

      if (selectedFile == null) {
        return;
      }

      Uint8List bytes = selectedFile.bytes;

      // Compress images only.
      // PDFs are kept unchanged.
      if (!selectedFile.isPdf) {
        bytes = await _compressor.compress(
          bytes: bytes,
          fileName: selectedFile.fileName,
        );
      }

      if (!mounted) {
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AiImportPreviewScreen(
            bytes: bytes,
            fileName: selectedFile.fileName,
            isPdf: selectedFile.isPdf,
            onReplace: () {
              Navigator.of(context).pop();
            },
            onAnalyze: () async {
              await _analyzeMenu(
                bytes: bytes,
                fileName: selectedFile.fileName,
                mimeType: selectedFile.mimeType,
              );
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _analyzeMenu({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    try {
      final notifier =
      ref.read(
        aiImportNotifierProvider.notifier,
      );

      final response = await notifier.analyzeMenu(
        bytes: bytes,
        fileName: fileName,
        mimeType: mimeType,
      );

      if (!mounted) {
        return;
      }

      if (response == null) {
        final state =
        ref.read(aiImportNotifierProvider);

        _showMessage(
          state.errorMessage ??
              'Unable to analyze menu.',
        );

        return;
      }

      Navigator.of(context).pop();

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              AiImportReviewScreen(
                menuResponse: response,
              ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Menu Import',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              Icon(
                Icons.auto_awesome,
                size: 64,
                color: theme.colorScheme.primary,
              ),

              const SizedBox(height: 20),

              const Text(
                'Import Menu with AI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Take a photo or upload your menu. '
                    'ScanAura will extract menu items, '
                    'prices, categories and veg/non-veg information.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: theme
                      .colorScheme
                      .onSurfaceVariant,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 36),

              _ActionCard(
                icon: Icons.camera_alt_outlined,
                title: 'Capture Menu',
                subtitle:
                'Take a clear photo using your camera',
                onTap: _isProcessing
                    ? null
                    : _pickFromCamera,
              ),

              const SizedBox(height: 16),

              _ActionCard(
                icon: Icons.upload_file_outlined,
                title: 'Upload Menu',
                subtitle:
                'Choose JPG, PNG, WEBP or PDF',
                onTap: _isProcessing
                    ? null
                    : _pickFromGalleryOrFile,
              ),

              if (_isProcessing) ...[
                const SizedBox(height: 32),
                const Center(
                  child: CircularProgressIndicator(),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Preparing your menu...',
                  ),
                ),
              ],

              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme
                      .colorScheme
                      .surfaceContainerHighest,
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: const Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Use a clear, well-lit menu. '
                            'Images are compressed before AI analysis '
                            'to reduce unnecessary upload size.',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: theme
                      .colorScheme
                      .primaryContainer,
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: theme
                      .colorScheme
                      .onPrimaryContainer,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}