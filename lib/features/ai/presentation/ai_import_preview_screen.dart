import 'dart:typed_data';

import 'package:flutter/material.dart';

class AiImportPreviewScreen extends StatefulWidget {
  const AiImportPreviewScreen({
    super.key,
    required this.bytes,
    required this.fileName,
    required this.isPdf,
    required this.onReplace,
    required this.onAnalyze,
  });

  final Uint8List bytes;
  final String fileName;
  final bool isPdf;

  final VoidCallback onReplace;
  final Future<void> Function() onAnalyze;

  @override
  State<AiImportPreviewScreen> createState() =>
      _AiImportPreviewScreenState();
}

class _AiImportPreviewScreenState
    extends State<AiImportPreviewScreen> {
  bool _isAnalyzing = false;

  Future<void> _handleAnalyze() async {
    if (_isAnalyzing) {
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      await widget.onAnalyze();
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Preview Menu',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Review your menu file',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Make sure the menu is clear and readable before sending it for AI analysis.',
                      style: TextStyle(
                        color: theme
                            .colorScheme
                            .onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildFilePreview(context),

                    const SizedBox(height: 16),

                    Card(
                      child: ListTile(
                        leading: Icon(
                          widget.isPdf
                              ? Icons.picture_as_pdf
                              : Icons.image_outlined,
                        ),
                        title: Text(
                          widget.fileName,
                          maxLines: 2,
                          overflow:
                          TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          widget.isPdf
                              ? 'PDF menu'
                              : 'Menu image',
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Card(
                      child: Padding(
                        padding:
                        const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: theme
                                  .colorScheme
                                  .primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'AI will detect menu categories, item names, descriptions, prices and veg/non-veg information.',
                                style: theme
                                    .textTheme
                                    .bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (_isAnalyzing)
                      Card(
                        child: Padding(
                          padding:
                          const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const SizedBox(
                                width: 28,
                                height: 28,
                                child:
                                CircularProgressIndicator(
                                  strokeWidth: 3,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Analyzing your menu...',
                                style: TextStyle(
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Please wait while ScanAura reads the menu.',
                                textAlign:
                                TextAlign.center,
                                style: TextStyle(
                                  color: theme
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  20,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                        _isAnalyzing
                            ? null
                            : widget.onReplace,
                        child: const Text(
                          'Replace',
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: FilledButton.icon(
                        onPressed:
                        _isAnalyzing
                            ? null
                            : _handleAnalyze,
                        icon: _isAnalyzing
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : const Icon(
                          Icons.auto_awesome,
                        ),
                        label: Text(
                          _isAnalyzing
                              ? 'Analyzing...'
                              : 'Analyze Menu',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(
      BuildContext context,
      ) {
    final theme = Theme.of(context);

    if (widget.isPdf) {
      return Container(
        height: 320,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme
              .colorScheme
              .surfaceContainerHighest,
          borderRadius:
          BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf,
              size: 80,
              color: theme.colorScheme.primary,
            ),

            const SizedBox(height: 16),

            const Text(
              'PDF Menu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Ready for AI analysis',
              style: TextStyle(
                color: theme
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius:
      BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 500,
        ),
        width: double.infinity,
        color: theme
            .colorScheme
            .surfaceContainerHighest,
        child: Image.memory(
          widget.bytes,
          fit: BoxFit.contain,
          errorBuilder: (
              context,
              error,
              stackTrace,
              ) {
            return const SizedBox(
              height: 320,
              child: Center(
                child: Text(
                  'Unable to preview image.',
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}