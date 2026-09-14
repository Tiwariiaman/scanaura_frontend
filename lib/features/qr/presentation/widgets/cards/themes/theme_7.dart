import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../../../app/theme/app_colors.dart';

class Theme7QrCard extends StatelessWidget {
  const Theme7QrCard({
    super.key,
    required this.qrData,
    this.businessName,
    this.businessLogoUrl,
    this.businessType,
    this.brandColor,
    this.showBusinessName = true,
  });

  final String qrData;
  final String? businessName;
  final String? businessLogoUrl;
  final String? businessType;
  final String? brandColor;
  final bool showBusinessName;

  static const String scanAuraLogo =
      'assets/images/scanaura_logo.png';

  // ===========================================================================
  // BRAND COLOR
  // ===========================================================================

  Color get _brand {
    final raw = brandColor?.trim().replaceFirst('#', '');

    if (raw != null && (raw.length == 6 || raw.length == 8)) {
      final value = int.tryParse(raw, radix: 16);

      if (value != null) {
        return raw.length == 8
            ? Color(value)
            : Color(0xFF000000 | value);
      }
    }

    return AppColors.primary;
  }

  // Dark version of the business brand.
  Color get _brandDark {
    return Color.lerp(
      _brand,
      Colors.black,
      .62,
    ) ??
        _brand;
  }

  // Medium/deeper brand tone.
  Color get _brandDeep {
    return Color.lerp(
      _brand,
      Colors.black,
      .78,
    ) ??
        _brand;
  }

  // Soft brand tint.
  Color get _brandSoft {
    return Color.lerp(
      _brand,
      Colors.white,
      .82,
    ) ??
        Colors.white;
  }

  // Very subtle brand background.
  Color get _brandCream {
    return Color.lerp(
      _brand,
      Colors.white,
      .94,
    ) ??
        Colors.white;
  }

  // Main text automatically adapts to the brand.
  Color get _textColor {
    final luminance = _brand.computeLuminance();

    // Dark brands can use a very dark text.
    // Very bright brands get a darker neutral.
    if (luminance > .70) {
      return const Color(0xFF18201E);
    }

    return Color.lerp(
      _brand,
      Colors.black,
      .78,
    ) ??
        const Color(0xFF18201E);
  }

  Color get _mutedText {
    return Color.lerp(
      _textColor,
      Colors.white,
      .30,
    ) ??
        const Color(0xFF596560);
  }

  // ===========================================================================
  // BUSINESS
  // ===========================================================================

  bool get _isFood =>
      (businessType ?? '').trim().toUpperCase() == 'FOOD';

  String get _primaryAction => _isFood ? 'Menu' : 'View';

  String get _safeBusinessName {
    final value = businessName?.trim();

    if (value == null || value.isEmpty) {
      return 'Your Business';
    }

    return value;
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 430.0;

        final width = availableWidth.clamp(280.0, 430.0);

        final compact = width < 340;
        final small = width < 380;

        final qrSize = compact
            ? 170.0
            : small
            ? 190.0
            : 208.0;

        return Container(
          width: width,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: _brandCream,
            borderRadius: BorderRadius.circular(
              compact ? 18 : 22,
            ),
            border: Border.all(
              color: _brand.withValues(alpha: .22),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: _brand.withValues(alpha: .16),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: .06),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Dynamic botanical decoration.
              _buildBotanicalPanel(
                compact: compact,
              ),

              Padding(
                padding: EdgeInsets.only(
                  top: compact ? 18 : 22,
                  bottom: compact ? 16 : 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(
                      compact: compact,
                      small: small,
                    ),

                    SizedBox(
                      height: compact ? 16 : 22,
                    ),

                    _buildQrSection(
                      compact: compact,
                      qrSize: qrSize,
                    ),

                    SizedBox(
                      height: compact ? 14 : 18,
                    ),

                    _buildFeatureRow(
                      compact: compact,
                    ),

                    if (showBusinessName) ...[
                      SizedBox(
                        height: compact ? 14 : 18,
                      ),
                      _buildBusinessName(
                        compact: compact,
                      ),
                    ],

                    SizedBox(
                      height: compact ? 12 : 16,
                    ),

                    _buildFooter(
                      compact: compact,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // BOTANICAL BACKGROUND
  // ===========================================================================

  Widget _buildBotanicalPanel({
    required bool compact,
  }) {
    return Positioned(
      top: 0,
      right: 0,
      width: compact ? 92 : 118,
      height: compact ? 180 : 225,
      child: IgnorePointer(
        child: CustomPaint(
          painter: _BotanicalPainter(
            brand: _brand,
            brandDark: _brandDark,
            brandDeep: _brandDeep,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildHeader({
    required bool compact,
    required bool small,
  }) {
    final logo = businessLogoUrl?.trim();

    final hasBusinessLogo =
        logo != null && logo.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 18 : 24,
      ),
      child: Column(
        children: [
          if (hasBusinessLogo)
            _buildBusinessLogo(
              logo,
              size: compact ? 46 : 54,
            )
          else
            _buildFallbackBusinessLogo(
              size: compact ? 46 : 54,
            ),

          SizedBox(
            height: compact ? 8 : 10,
          ),

          Text(
            _safeBusinessName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _textColor,
              fontSize: compact ? 17 : 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -.35,
              height: 1.05,
            ),
          ),

          const SizedBox(height: 6),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'SCAN • CONNECT • EXPLORE',
              style: TextStyle(
                color: _brandDark,
                fontSize: compact ? 8 : 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
              ),
            ),
          ),

          SizedBox(
            height: compact ? 8 : 10,
          ),

          // Small brand divider.
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: compact ? 28 : 36,
                height: 1,
                color: _brand.withValues(alpha: .45),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                ),
                child: Icon(
                  Icons.eco_rounded,
                  size: compact ? 10 : 12,
                  color: _brand,
                ),
              ),
              Container(
                width: compact ? 28 : 36,
                height: 1,
                color: _brand.withValues(alpha: .45),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessLogo(
      String url, {
        required double size,
      }) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .96),
        shape: BoxShape.circle,
        border: Border.all(
          color: _brand.withValues(alpha: .28),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _brand.withValues(alpha: .10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return _buildFallbackBusinessLogo(
            size: size - 10,
          );
        },
      ),
    );
  }

  Widget _buildFallbackBusinessLogo({
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .96),
        shape: BoxShape.circle,
        border: Border.all(
          color: _brand.withValues(alpha: .28),
        ),
        boxShadow: [
          BoxShadow(
            color: _brand.withValues(alpha: .08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        Icons.storefront_rounded,
        size: size * .48,
        color: _brand,
      ),
    );
  }

  // ===========================================================================
  // QR
  // ===========================================================================

  Widget _buildQrSection({
    required bool compact,
    required double qrSize,
  }) {
    return Container(
      padding: EdgeInsets.all(
        compact ? 11 : 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          compact ? 15 : 18,
        ),
        border: Border.all(
          color: _brand.withValues(alpha: .20),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _brand.withValues(alpha: .10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: QrImageView(
        data: qrData,
        version: QrVersions.auto,
        size: qrSize,
        backgroundColor: Colors.white,
        gapless: true,

        // Keep QR pure black/white for scanning reliability.
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Colors.black,
        ),

        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Colors.black,
        ),
      ),
    );
  }

  // ===========================================================================
  // FEATURES
  // ===========================================================================

  Widget _buildFeatureRow({
    required bool compact,
  }) {
    final features = <_Theme7Feature>[
      _Theme7Feature(
        icon: _isFood
            ? Icons.restaurant_menu_rounded
            : Icons.visibility_rounded,
        label: _primaryAction,
      ),
      const _Theme7Feature(
        icon: Icons.star_rounded,
        label: 'Reviews',
      ),
      const _Theme7Feature(
        icon: Icons.share_rounded,
        label: 'Social',
      ),
      const _Theme7Feature(
        icon: Icons.local_offer_rounded,
        label: 'Offers',
      ),
      const _Theme7Feature(
        icon: Icons.apps_rounded,
        label: 'More',
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 18,
      ),
      child: Row(
        children: [
          for (final feature in features)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 2,
                ),
                child: _buildFeature(
                  feature,
                  compact: compact,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeature(
      _Theme7Feature feature, {
        required bool compact,
      }) {
    final size = compact ? 38.0 : 44.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .96),
            borderRadius: BorderRadius.circular(
              compact ? 12 : 14,
            ),
            border: Border.all(
              color: _brand.withValues(alpha: .18),
            ),
            boxShadow: [
              BoxShadow(
                color: _brand.withValues(alpha: .08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(
            feature.icon,
            size: compact ? 18 : 20,
            color: _brandDark,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          feature.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _textColor,
            fontSize: compact ? 7.5 : 8.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // BUSINESS NAME STRIP
  // ===========================================================================

  Widget _buildBusinessName({
    required bool compact,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 18,
      ),
      padding: EdgeInsets.symmetric(
        vertical: compact ? 8 : 10,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: _brandDeep,
        borderRadius: BorderRadius.circular(
          compact ? 4 : 5,
        ),
        boxShadow: [
          BoxShadow(
            color: _brand.withValues(alpha: .14),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        _safeBusinessName,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          fontSize: compact ? 13 : 15,
          fontWeight: FontWeight.w800,
          letterSpacing: -.2,
        ),
      ),
    );
  }

  // ===========================================================================
  // FOOTER
  // ===========================================================================

  Widget _buildFooter({
    required bool compact,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/scanaura_logo_white.png',
          width: compact ? 19 : 22,
          height: compact ? 19 : 22,
          fit: BoxFit.contain,
        ),

        SizedBox(
          width: compact ? 5 : 7,
        ),

        Text(
          'Powered by ScanAura',
          style: TextStyle(
            color: _mutedText,
            fontSize: compact ? 10.5 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// FEATURE MODEL
// =============================================================================

class _Theme7Feature {
  const _Theme7Feature({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

// =============================================================================
// BOTANICAL PAINTER
// =============================================================================

class _BotanicalPainter extends CustomPainter {
  const _BotanicalPainter({
    required this.brand,
    required this.brandDark,
    required this.brandDeep,
  });

  final Color brand;
  final Color brandDark;
  final Color brandDeep;

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    // -------------------------------------------------------------------------
    // Main botanical panel
    // -------------------------------------------------------------------------

    final mainPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = brandDeep.withValues(alpha: .72);

    final path = Path();

    path.moveTo(size.width * .12, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);

    path.cubicTo(
      size.width * .70,
      size.height * .82,
      size.width * .45,
      size.height * .58,
      size.width * .12,
      0,
    );

    canvas.drawPath(
      path,
      mainPaint,
    );

    // -------------------------------------------------------------------------
    // Second softer botanical layer
    // -------------------------------------------------------------------------

    final secondaryPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = brand.withValues(alpha: .30);

    final secondaryPath = Path();

    secondaryPath.moveTo(
      size.width * .48,
      0,
    );

    secondaryPath.cubicTo(
      size.width * .72,
      size.height * .18,
      size.width * .55,
      size.height * .48,
      size.width * .98,
      size.height * .68,
    );

    secondaryPath.lineTo(
      size.width,
      0,
    );

    secondaryPath.close();

    canvas.drawPath(
      secondaryPath,
      secondaryPaint,
    );

    // -------------------------------------------------------------------------
    // Leaves
    // -------------------------------------------------------------------------

    final leafPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = brandDark.withValues(alpha: .62);

    _drawLeaf(
      canvas,
      leafPaint,
      Offset(
        size.width * .68,
        size.height * .20,
      ),
      size.width * .23,
      -0.45,
    );

    _drawLeaf(
      canvas,
      leafPaint,
      Offset(
        size.width * .52,
        size.height * .37,
      ),
      size.width * .19,
      0.18,
    );

    _drawLeaf(
      canvas,
      leafPaint,
      Offset(
        size.width * .78,
        size.height * .48,
      ),
      size.width * .21,
      -0.35,
    );

    _drawLeaf(
      canvas,
      leafPaint,
      Offset(
        size.width * .63,
        size.height * .66,
      ),
      size.width * .18,
      0.38,
    );

    // -------------------------------------------------------------------------
    // Small brand dots
    // -------------------------------------------------------------------------

    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = brand.withValues(alpha: .28);

    canvas.drawCircle(
      Offset(
        size.width * .84,
        size.height * .78,
      ),
      size.width * .035,
      dotPaint,
    );

    canvas.drawCircle(
      Offset(
        size.width * .73,
        size.height * .88,
      ),
      size.width * .022,
      dotPaint,
    );
  }

  void _drawLeaf(
      Canvas canvas,
      Paint paint,
      Offset center,
      double radius,
      double rotation,
      ) {
    canvas.save();

    canvas.translate(
      center.dx,
      center.dy,
    );

    canvas.rotate(rotation);

    final path = Path();

    path.moveTo(
      0,
      -radius,
    );

    path.cubicTo(
      radius * .82,
      -radius * .72,
      radius * .95,
      radius * .25,
      0,
      radius,
    );

    path.cubicTo(
      -radius * .95,
      radius * .25,
      -radius * .82,
      -radius * .72,
      0,
      -radius,
    );

    canvas.drawPath(
      path,
      paint,
    );

    // Leaf vein.
    final veinPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: .18);

    canvas.drawLine(
      const Offset(0, -1),
      Offset(
        0,
        radius * .78,
      ),
      veinPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(
      covariant _BotanicalPainter oldDelegate,
      ) {
    return oldDelegate.brand != brand ||
        oldDelegate.brandDark != brandDark ||
        oldDelegate.brandDeep != brandDeep;
  }
}