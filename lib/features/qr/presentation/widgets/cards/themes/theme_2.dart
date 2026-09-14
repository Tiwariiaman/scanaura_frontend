import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../../../app/theme/app_colors.dart';

class Theme2QrCard extends StatelessWidget {
  const Theme2QrCard({
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

  // ---------------------------------------------------------------------------
  // ASSETS
  // ---------------------------------------------------------------------------

  static const String scanAuraLogo =
      'assets/images/scanaura_logo.png';

  static const String whiteScanAuraLogo =
      'assets/images/scanaura_logo_white.png';

  // ---------------------------------------------------------------------------
  // BRAND COLOR
  // ---------------------------------------------------------------------------

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

  Color get _darkBrand {
    return Color.lerp(
      _brand,
      Colors.black,
      .22,
    ) ??
        _brand;
  }

  Color get _lightBrand {
    return Color.lerp(
      _brand,
      Colors.white,
      .90,
    ) ??
        Colors.white;
  }

  Color get _veryLightBrand {
    return Color.lerp(
      _brand,
      Colors.white,
      .96,
    ) ??
        Colors.white;
  }

  // ---------------------------------------------------------------------------
  // BUSINESS TYPE
  // ---------------------------------------------------------------------------

  bool get _isFood {
    return (businessType ?? '').trim().toUpperCase() == 'FOOD';
  }

  String get _primaryAction {
    return _isFood ? 'Menu' : 'View';
  }

  IconData get _primaryIcon {
    return _isFood
        ? Icons.restaurant_menu_rounded
        : Icons.visibility_rounded;
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 430.0;

        final width = availableWidth.clamp(
          280.0,
          430.0,
        );

        final compact = width < 340;
        final small = width < 380;

        final qrSize = compact
            ? 178.0
            : small
            ? 205.0
            : 225.0;

        return Container(
          width: width,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              compact ? 17 : 20,
            ),
            border: Border.all(
              color: _brand.withValues(alpha: .20),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .07),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // ---------------------------------------------------------------
              // TOP RIGHT LEAVES
              // ---------------------------------------------------------------

              Positioned(
                right: -5,
                top: 8,
                child: _buildTopLeaves(
                  compact: compact,
                ),
              ),

              // ---------------------------------------------------------------
              // BOTTOM LEFT LEAVES
              // ---------------------------------------------------------------

              Positioned(
                left: -8,
                bottom: 54,
                child: _buildBottomLeaves(
                  compact: compact,
                ),
              ),

              // ---------------------------------------------------------------
              // SOFT BRAND GRADIENT AT BOTTOM
              // ---------------------------------------------------------------

              Positioned(
                right: -55,
                bottom: -65,
                child: Container(
                  width: width * .72,
                  height: 145,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _brand.withValues(alpha: .02),
                        _brand.withValues(alpha: .11),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),

              // ---------------------------------------------------------------
              // MAIN CONTENT
              // ---------------------------------------------------------------

              Padding(
                padding: EdgeInsets.fromLTRB(
                  compact ? 17 : 22,
                  compact ? 16 : 20,
                  compact ? 17 : 22,
                  compact ? 16 : 19,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(
                      compact: compact,
                    ),

                    SizedBox(
                      height: compact ? 16 : 20,
                    ),

                    _buildQrSection(
                      qrSize: qrSize,
                      compact: compact,
                    ),

                    SizedBox(
                      height: compact ? 14 : 17,
                    ),

                    _buildFeatureRow(
                      compact: compact,
                    ),

                    if (showBusinessName)
                      _buildBusinessName(
                        compact: compact,
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
  // HEADER
  // ===========================================================================

  Widget _buildHeader({
    required bool compact,
  }) {
    final logo = businessLogoUrl?.trim();

    final hasLogo = logo != null && logo.isNotEmpty;

    return Column(
      children: [
        // ---------------------------------------------------------------------
        // BUSINESS LOGO
        //
        // IMPORTANT:
        // No white container.
        // No circle.
        // No border.
        // No padding around the actual logo.
        // ---------------------------------------------------------------------

        if (hasLogo)
          _buildBusinessLogo(
            logo!,
            size: compact ? 58 : 70,
          )
        else
          _buildFallbackLogo(
            size: compact ? 58 : 70,
          ),

        SizedBox(
          height: compact ? 5 : 7,
        ),

        // ---------------------------------------------------------------------
        // BUSINESS NAME
        // ---------------------------------------------------------------------

        Text(
          (businessName?.trim().isNotEmpty ?? false)
              ? businessName!.trim()
              : 'Your Business',
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: const Color(0xFF101828),
            fontSize: compact ? 17 : 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -.35,
            height: 1.05,
          ),
        ),

        const SizedBox(height: 5),

        // ---------------------------------------------------------------------
        // TAGLINE
        // ---------------------------------------------------------------------

        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'SCAN • CONNECT • EXPLORE',
            style: TextStyle(
              color: const Color(0xFF475467),
              fontSize: compact ? 8 : 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),

        const SizedBox(height: 5),

        // Small brand divider
        Container(
          width: compact ? 90 : 115,
          height: 1.2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                _brand.withValues(alpha: .75),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // QR SECTION
  // ===========================================================================

  Widget _buildQrSection({
    required double qrSize,
    required bool compact,
  }) {
    return Container(
      padding: EdgeInsets.all(
        compact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          compact ? 14 : 17,
        ),
        border: Border.all(
          color: _brand.withValues(alpha: .18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .055),
            blurRadius: 13,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: QrImageView(
        data: qrData,
        version: QrVersions.auto,
        size: qrSize,
        backgroundColor: Colors.white,
        gapless: true,

        // ---------------------------------------------------------------------
        // IMPORTANT:
        // Business logo is NOT placed inside the QR code.
        // ---------------------------------------------------------------------

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
    final features = <_Theme2Feature>[
      _Theme2Feature(
        icon: _primaryIcon,
        label: _primaryAction,
      ),
      const _Theme2Feature(
        icon: Icons.star_rounded,
        label: 'Reviews',
      ),
      const _Theme2Feature(
        icon: Icons.share_rounded,
        label: 'Social',
      ),
      const _Theme2Feature(
        icon: Icons.local_offer_rounded,
        label: 'Offers',
      ),
      const _Theme2Feature(
        icon: Icons.apps_rounded,
        label: 'More',
      ),
    ];

    return Row(
      children: [
        for (final feature in features)
          Expanded(
            child: _buildFeatureItem(
              feature,
              compact: compact,
            ),
          ),
      ],
    );
  }

  Widget _buildFeatureItem(
      _Theme2Feature feature, {
        required bool compact,
      }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 39 : 45,
          height: compact ? 39 : 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,

            // Dynamic business color
            color: _lightBrand,

            border: Border.all(
              color: _brand.withValues(alpha: .10),
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              feature.icon,
              size: compact ? 19 : 21,
              color: _darkBrand,
            ),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          feature.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF344054),
            fontSize: compact ? 7.5 : 8.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // BUSINESS NAME
  // ===========================================================================

  Widget _buildBusinessName({
    required bool compact,
  }) {
    final name = businessName?.trim();

    if (name == null || name.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(
        top: compact ? 11 : 14,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    _brand.withValues(alpha: .55),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFF101828),
                fontSize: compact ? 12.5 : 14,
                fontWeight: FontWeight.w700,
                letterSpacing: -.15,
              ),
            ),
          ),

          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _brand.withValues(alpha: .55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
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
            width: compact ? 6 : 7,
          ),

          Text(
            'Powered by ScanAura',
            style: TextStyle(
              color: const Color(0xFF344054),
              fontSize: compact ? 9.5 : 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
    );
  }

  // ===========================================================================
  // BUSINESS LOGO
  // ===========================================================================

  Widget _buildBusinessLogo(
      String url, {
        required double size,
      }) {
    // -------------------------------------------------------------------------
    // IMPORTANT:
    // Completely transparent.
    //
    // There is NO:
    // - white background
    // - circle
    // - border
    // - shadow
    // - extra visual frame
    //
    // The uploaded business logo itself is displayed directly.
    // -------------------------------------------------------------------------

    return SizedBox(
      width: size,
      height: size,
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return _buildFallbackLogo(
            size: size,
          );
        },
      ),
    );
  }

  // ===========================================================================
  // FALLBACK LOGO
  // ===========================================================================

  Widget _buildFallbackLogo({
    required double size,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        scanAuraLogo,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return Icon(
            Icons.business_rounded,
            color: _darkBrand,
            size: size * .48,
          );
        },
      ),
    );
  }

  // ===========================================================================
  // DECORATIVE LEAVES
  // ===========================================================================

  Widget _buildTopLeaves({
    required bool compact,
  }) {
    return SizedBox(
      width: compact ? 75 : 95,
      height: compact ? 110 : 135,
      child: CustomPaint(
        painter: _BotanicalPainter(
          color: _brand,
          direction: BotanicalDirection.topRight,
        ),
      ),
    );
  }

  Widget _buildBottomLeaves({
    required bool compact,
  }) {
    return SizedBox(
      width: compact ? 70 : 88,
      height: compact ? 105 : 125,
      child: CustomPaint(
        painter: _BotanicalPainter(
          color: _brand,
          direction: BotanicalDirection.bottomLeft,
        ),
      ),
    );
  }
}

// =============================================================================
// FEATURE MODEL
// =============================================================================

class _Theme2Feature {
  const _Theme2Feature({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

// =============================================================================
// BOTANICAL DECORATION
// =============================================================================

enum BotanicalDirection {
  topRight,
  bottomLeft,
}

class _BotanicalPainter extends CustomPainter {
  const _BotanicalPainter({
    required this.color,
    required this.direction,
  });

  final Color color;
  final BotanicalDirection direction;

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final leafColor = color.withValues(
      alpha: .28,
    );

    final darkLeafColor = color.withValues(
      alpha: .42,
    );

    final stemPaint = Paint()
      ..color = darkLeafColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;

    final leafPaint = Paint()
      ..color = leafColor
      ..style = PaintingStyle.fill;

    final veinPaint = Paint()
      ..color = darkLeafColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = .7;

    final path = Path();

    if (direction == BotanicalDirection.topRight) {
      path.moveTo(
        size.width * .94,
        size.height * .02,
      );

      path.cubicTo(
        size.width * .72,
        size.height * .20,
        size.width * .74,
        size.height * .48,
        size.width * .28,
        size.height * .94,
      );

      canvas.drawPath(
        path,
        stemPaint,
      );

      _leaf(
        canvas,
        center: Offset(
          size.width * .76,
          size.height * .17,
        ),
        width: size.width * .25,
        height: size.height * .48,
        angle: -.45,
        fill: leafPaint,
        vein: veinPaint,
      );

      _leaf(
        canvas,
        center: Offset(
          size.width * .87,
          size.height * .37,
        ),
        width: size.width * .23,
        height: size.height * .45,
        angle: -.20,
        fill: leafPaint,
        vein: veinPaint,
      );

      _leaf(
        canvas,
        center: Offset(
          size.width * .65,
          size.height * .42,
        ),
        width: size.width * .22,
        height: size.height * .43,
        angle: .25,
        fill: leafPaint,
        vein: veinPaint,
      );

      _leaf(
        canvas,
        center: Offset(
          size.width * .57,
          size.height * .64,
        ),
        width: size.width * .20,
        height: size.height * .40,
        angle: .38,
        fill: leafPaint,
        vein: veinPaint,
      );
    } else {
      path.moveTo(
        size.width * .04,
        size.height * .96,
      );

      path.cubicTo(
        size.width * .26,
        size.height * .74,
        size.width * .22,
        size.height * .40,
        size.width * .68,
        size.height * .10,
      );

      canvas.drawPath(
        path,
        stemPaint,
      );

      _leaf(
        canvas,
        center: Offset(
          size.width * .25,
          size.height * .72,
        ),
        width: size.width * .25,
        height: size.height * .48,
        angle: .45,
        fill: leafPaint,
        vein: veinPaint,
      );

      _leaf(
        canvas,
        center: Offset(
          size.width * .13,
          size.height * .54,
        ),
        width: size.width * .22,
        height: size.height * .43,
        angle: .20,
        fill: leafPaint,
        vein: veinPaint,
      );

      _leaf(
        canvas,
        center: Offset(
          size.width * .37,
          size.height * .48,
        ),
        width: size.width * .21,
        height: size.height * .42,
        angle: -.25,
        fill: leafPaint,
        vein: veinPaint,
      );

      _leaf(
        canvas,
        center: Offset(
          size.width * .46,
          size.height * .28,
        ),
        width: size.width * .19,
        height: size.height * .38,
        angle: -.38,
        fill: leafPaint,
        vein: veinPaint,
      );
    }
  }

  void _leaf(
      Canvas canvas, {
        required Offset center,
        required double width,
        required double height,
        required double angle,
        required Paint fill,
        required Paint vein,
      }) {
    canvas.save();

    canvas.translate(
      center.dx,
      center.dy,
    );

    canvas.rotate(angle);

    final leaf = Path();

    leaf.moveTo(
      0,
      -height / 2,
    );

    leaf.cubicTo(
      width * .62,
      -height * .20,
      width * .56,
      height * .28,
      0,
      height / 2,
    );

    leaf.cubicTo(
      -width * .56,
      height * .28,
      -width * .62,
      -height * .20,
      0,
      -height / 2,
    );

    leaf.close();

    canvas.drawPath(
      leaf,
      fill,
    );

    final middle = Path()
      ..moveTo(
        0,
        -height / 2,
      )
      ..lineTo(
        0,
        height / 2,
      );

    canvas.drawPath(
      middle,
      vein,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(
      covariant _BotanicalPainter oldDelegate,
      ) {
    return oldDelegate.color != color ||
        oldDelegate.direction != direction;
  }
}