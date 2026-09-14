import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../business/presentation/providers/business_notifier.dart';
import '../data/models/qr_response.dart';
import 'widgets/cards/qr_card_theme.dart';
import '../services/qr_file_service.dart';
import 'providers/qr_notifier.dart';
import 'providers/qr_state.dart';

import 'widgets/cards/scanaura_qr_card.dart';

class QrScreen extends ConsumerStatefulWidget {
  const QrScreen({super.key});

  @override
  ConsumerState<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends ConsumerState<QrScreen> {
  static const String _themeKeyPrefix = 'qr_card_theme_';

  final GlobalKey _qrCardKey = GlobalKey();

  QrCardTheme _selectedTheme = QrCardTheme.theme1;
  String? _themeBusinessId;
  bool _themeLoaded = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        ref.read(qrNotifierProvider.notifier).loadQr(),
        ref.read(businessNotifierProvider.notifier).loadMyBusiness(),
      ]);
      await _loadSavedTheme();
    });
  }

  String _publicQrUrl(String qrCode) =>
      'https://scanaura.in/#/q/$qrCode';

  Future<void> _loadSavedTheme() async {
    final business =
        ref.read(businessNotifierProvider).business;

    if (business == null || business.id.trim().isEmpty) {
      if (mounted) setState(() => _themeLoaded = true);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final key = '$_themeKeyPrefix${business.id}';
    final index = prefs.getInt(key);

    if (!mounted) return;

    setState(() {
      _themeBusinessId = business.id;
      _themeLoaded = true;
      if (index != null &&
          index >= 0 &&
          index < QrCardTheme.values.length) {
        _selectedTheme = QrCardTheme.values[index];
      }
    });
  }

  Future<void> _selectTheme(QrCardTheme theme) async {
    final business =
        ref.read(businessNotifierProvider).business;

    setState(() {
      _selectedTheme = theme;
      _themeBusinessId = business?.id;
    });

    if (business == null || business.id.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      '$_themeKeyPrefix${business.id}',
      theme.index,
    );
  }

  Future<Uint8List> _generateQrCardBytes() async {
    await WidgetsBinding.instance.endOfFrame;

    final boundaryContext = _qrCardKey.currentContext;
    if (boundaryContext == null) {
      throw Exception('QR card is not ready.');
    }

    final renderObject = boundaryContext.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      throw Exception('Unable to capture QR card.');
    }

    final image = await renderObject.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    image.dispose();

    if (byteData == null) {
      throw Exception('Unable to generate QR card image.');
    }

    return byteData.buffer.asUint8List();
  }

  Future<void> _downloadQr() async {
    try {
      final bytes = await _generateQrCardBytes();
      final business =
          ref.read(businessNotifierProvider).business;

      final businessName = business?.businessName
          .trim()
          .replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_');

      final fileName = businessName == null || businessName.isEmpty
          ? 'scanaura_qr_card.png'
          : 'scanaura_${businessName}_qr.png';

      await QrFileService.downloadQr(bytes, fileName);

      if (mounted) {
        _showMessage('QR downloaded successfully.');
      }
    } catch (e) {
      if (mounted) {
        _showMessage(
          'QR download failed: ${_cleanError(e)}',
        );
      }
    }
  }

  Future<void> _shareQr() async {
    try {
      final qr = ref.read(qrNotifierProvider).digitalQr;
      if (qr == null) {
        throw Exception('Digital QR not available.');
      }

      final bytes = await _generateQrCardBytes();
      final business =
          ref.read(businessNotifierProvider).business;

      final businessName = business?.businessName.trim();
      final safeBusinessName = businessName == null ||
          businessName.isEmpty
          ? 'business'
          : businessName.replaceAll(
        RegExp(r'[^a-zA-Z0-9]+'),
        '_',
      );

      final publicUrl = _publicQrUrl(qr.qrCode);
      final shareText = businessName != null &&
          businessName.isNotEmpty
          ? 'Hi! Check out $businessName on ScanAura.\n\n'
          'View the business page:\n$publicUrl'
          : 'Hi! Check out this business on ScanAura.\n\n'
          'View the business page:\n$publicUrl';

      await QrFileService.shareQr(
        bytes: bytes,
        fileName: 'scanaura_${safeBusinessName}_qr.png',
        text: shareText,
        subject: '$businessName on ScanAura',
      );

      if (mounted) {
        _showMessage('QR shared successfully.');
      }
    } catch (e) {
      if (mounted) {
        _showMessage(
          'QR sharing failed: ${_cleanError(e)}',
        );
      }
    }
  }

  String _cleanError(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }
    return message;
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qrNotifierProvider);
    final business =
        ref.watch(businessNotifierProvider).business;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QR Management',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: _buildBody(
        context,
        state,
        business,
        theme,
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      QrState state,
      dynamic business,
      ThemeData theme,
      ) {
    switch (state.status) {
      case QrStatus.initial:
      case QrStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case QrStatus.error:
        return _buildError(context, state);
      case QrStatus.success:
        return _buildQrContent(
          context,
          state,
          business,
          theme,
        );
    }
  }

  Widget _buildQrContent(
      BuildContext context,
      QrState state,
      dynamic business,
      ThemeData theme,
      ) {
    final digitalQr = state.digitalQr;
    final physicalQrs = state.qrCodes
        .where((qr) => qr.type == 'PHYSICAL')
        .toList();

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(qrNotifierProvider.notifier).loadQr();
        await _loadSavedTheme();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final horizontalPadding = width < 360
              ? 12.0
              : width < 600
              ? 16.0
              : 24.0;
          final maxWidth = width >= 1000 ? 1000.0 : 720.0;

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              32,
            ),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Your QR Codes',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Manage the QR codes connected to your business.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildDigitalQrCard(
                        context,
                        theme,
                        digitalQr,
                        business,
                      ),
                      const SizedBox(height: 16),
                      _buildPhysicalQrCard(
                        context,
                        theme,
                        physicalQrs,
                        business,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDigitalQrCard(
      BuildContext context,
      ThemeData theme,
      QrResponse? qr,
      dynamic business,
      ) {
    if (qr == null) {
      return Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.qr_code_2_rounded,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                'Digital QR not found.',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    final businessName = business?.businessName as String?;
    final businessLogoUrl = business?.logoUrl as String?;
    final businessType = business?.businessType as String?;
    final brandColor = business?.brandColor as String?;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Digital QR',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your primary digital QR code.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildThemeMenu(
                  context,
                  theme,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _buildThemeHint(theme),
            const SizedBox(height: 18),
            Center(
              child: RepaintBoundary(
                key: _qrCardKey,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: ScanAuraQrCard(
                    qrData: _publicQrUrl(qr.qrCode),
                    businessName: businessName,
                    businessLogoUrl: businessLogoUrl,
                    businessType: businessType,
                    brandColor: brandColor,
                    theme: _selectedTheme,
                    showBusinessName: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  qr.active
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  size: 18,
                  color: qr.active
                      ? Colors.green
                      : theme.colorScheme.error,
                ),
                const SizedBox(width: 6),
                Text(
                  qr.active ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: qr.active
                        ? Colors.green
                        : theme.colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 500) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _downloadQr,
                          icon: const Icon(Icons.download_rounded),
                          label: const Text('Download QR'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: _shareQr,
                          icon: const Icon(Icons.share_rounded),
                          label: const Text('Share QR'),
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _downloadQr,
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('Download QR'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _shareQr,
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('Share QR'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeMenu(
      BuildContext context,
      ThemeData theme,
      ) {
    return PopupMenuButton<QrCardTheme>(
      tooltip: 'Choose QR theme',
      initialValue: _selectedTheme,
      onSelected: _selectTheme,
      position: PopupMenuPosition.under,
      itemBuilder: (context) => [
        for (final item in QrCardTheme.values)
          PopupMenuItem<QrCardTheme>(
            value: item,
            child: Row(
              children: [
                _themePreviewDot(item, theme),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        item.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item == _selectedTheme)
                  Icon(
                    Icons.check_rounded,
                    size: 19,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
          ),
      ],
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.palette_outlined,
              size: 19,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 7),
            Text(
              _selectedTheme.label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 3),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }

  Widget _themePreviewDot(
      QrCardTheme item,
      ThemeData theme,
      ) {
    final colors = <QrCardTheme, Color>{
      QrCardTheme.theme1: theme.colorScheme.primary,
      QrCardTheme.theme2: const Color(0xFF667085),
      QrCardTheme.theme3: const Color(0xFF3446FF),
      QrCardTheme.theme4: const Color(0xFFB7831E),
      QrCardTheme.theme5: const Color(0xFF6B5BFF),
      QrCardTheme.theme6: const Color(0xFF149A7B),
      QrCardTheme.theme7: const Color(0xFF30422A),
      QrCardTheme.theme8: const Color(0xFFB82B2B),
    };

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: colors[item],
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildThemeHint(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Choose a style. Your brand colour and business identity are applied automatically.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicalQrCard(
      BuildContext context,
      ThemeData theme,
      List<QrResponse> physicalQrs,
      dynamic business,
      ) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assigned QR',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'QR codes assigned to your business.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Count
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(
                      alpha: .08,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${physicalQrs.length}',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (physicalQrs.isEmpty)
              _buildNoPhysicalQr(
                context,
                theme,
              )
            else
              ...physicalQrs.map(
                    (qr) => _buildPhysicalQrItem(
                  context,
                  theme,
                  qr,
                  business,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalQrItem(
      BuildContext context,
      ThemeData theme,
      QrResponse qr,
      dynamic business,
      ) {
    final isActive = qr.active;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          // QR icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.qr_code_2_rounded,
              size: 25,
              color: theme.colorScheme.primary,
            ),
          ),

          const SizedBox(width: 12),

          // QR CODE TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assigned QR',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                SelectableText(
                  qr.qrCode,
                  maxLines: 1,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: .3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // STATUS
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.green.withValues(alpha: .10)
                  : theme.colorScheme.error.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.green
                        : theme.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? Colors.green
                        : theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPhysicalQr(
      BuildContext context,
      ThemeData theme,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.qr_code_2_rounded,
            size: 40,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            'No physical QR assigned yet.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildError(
      BuildContext context,
      QrState state,
      ) {
    return Center(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 52,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unable to load QR codes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.errorMessage ??
                      'Unable to load QR codes.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      ref
                          .read(qrNotifierProvider.notifier)
                          .loadQr();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
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
