import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrViewScreen extends StatelessWidget {
  const QrViewScreen({
    super.key,
    required this.qrCode,
    required this.businessName,
  });

  final String qrCode;
  final String? businessName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital QR'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            child: Column(
              children: [
                Text(
                  businessName ?? 'My Business',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Scan to open your digital menu',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 32),

                Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          color: Colors.white,
                          child: QrImageView(
                            data: qrCode,
                            version: QrVersions.auto,
                            size: 280,
                            backgroundColor: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          qrCode,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Digital QR Code',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Download will be added next.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.download_outlined,
                    ),
                    label: const Text(
                      'Download QR',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}