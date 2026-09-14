import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../../../app/theme/app_colors.dart';


class Theme5QrCard extends StatelessWidget {
  const Theme5QrCard({
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

  static const String scanAuraLogoWhite =
      'assets/images/scanaura_logo_white.png';

  // ------------------------------------------------------------
  // BRAND COLOR
  // ------------------------------------------------------------

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

  Color get _secondaryBrand {
    return Color.lerp(
      _brand,
      const Color(0xFF4F46E5),
      .35,
    ) ??
        const Color(0xFF4F46E5);
  }

  Color get _darkBrand {
    return Color.lerp(
      _brand,
      Colors.black,
      .68,
    ) ??
        const Color(0xFF07111F);
  }

  bool get _isFood =>
      (businessType ?? '').trim().toUpperCase() == 'FOOD';

  String get _primaryAction => _isFood ? 'Menu' : 'View';

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 430.0;

        final cardWidth =
        availableWidth.clamp(280.0, 430.0);

        final compact = cardWidth < 340;
        final small = cardWidth < 380;

        final qrSize = (cardWidth - 112).clamp(
          175.0,
          compact
              ? 205.0
              : small
              ? 220.0
              : 238.0,
        );

        final radius = compact ? 18.0 : 22.0;

        return Container(
          width: cardWidth,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: _brand.withValues(alpha: .22),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: .10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              _buildBackground(
                compact: compact,
              ),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(
                    compact: compact,
                    small: small,
                  ),

                  _buildQrSection(
                    compact: compact,
                    qrSize: qrSize,
                  ),

                  _buildFeatureRow(
                    compact: compact,
                  ),

                  if (showBusinessName) ...[
                    SizedBox(
                      height: compact ? 13 : 16,
                    ),
                    _buildBusinessName(
                      compact: compact,
                    ),
                  ],

                  SizedBox(
                    height: compact ? 14 : 18,
                  ),

                  _buildFooter(
                    compact: compact,
                  ),

                  SizedBox(
                    height: compact ? 14 : 18,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // BACKGROUND
  // ------------------------------------------------------------

  Widget _buildBackground({
    required bool compact,
  }) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _darkBrand,
              Color.lerp(
                _darkBrand,
                _secondaryBrand,
                .35,
              ) ??
                  _secondaryBrand,
              _brand,
            ],
            stops: const [
              0.0,
              0.48,
              1.0,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Top-left flowing shape
            Positioned(
              top: -70,
              left: -65,
              child: _gradientBlob(
                width: compact ? 150 : 190,
                height: compact ? 150 : 190,
                opacity: .88,
                alignment: Alignment.bottomRight,
              ),
            ),

            // Top-right flowing shape
            Positioned(
              top: -50,
              right: -70,
              child: _gradientBlob(
                width: compact ? 165 : 210,
                height: compact ? 150 : 195,
                opacity: .80,
                alignment: Alignment.bottomLeft,
              ),
            ),

            // Middle-right blue wave
            Positioned(
              top: compact ? 175 : 205,
              right: -75,
              child: _gradientBlob(
                width: compact ? 145 : 185,
                height: compact ? 145 : 180,
                opacity: .68,
                alignment: Alignment.centerLeft,
              ),
            ),

            // Bottom-left subtle wave
            Positioned(
              bottom: -70,
              left: -75,
              child: _gradientBlob(
                width: compact ? 160 : 205,
                height: compact ? 150 : 190,
                opacity: .42,
                alignment: Alignment.topRight,
              ),
            ),

            // Soft white overlay behind content
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: .96),
                        Colors.white.withValues(alpha: .90),
                        Colors.white.withValues(alpha: .94),
                      ],
                      stops: const [
                        .08,
                        .55,
                        1.0,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradientBlob({
    required double width,
    required double height,
    required double opacity,
    required Alignment alignment,
  }) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(width * .48),
          gradient: LinearGradient(
            begin: alignment,
            end: -alignment,
            colors: [
              _secondaryBrand,
              _brand,
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader({
    required bool compact,
    required bool small,
  }) {
    final logo = businessLogoUrl?.trim();

    final hasBusinessLogo =
        logo != null && logo.isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 18 : 24,
        compact ? 20 : 26,
        compact ? 18 : 24,
        compact ? 8 : 10,
      ),
      child: Column(
        children: [
          // Business logo
          if (hasBusinessLogo)
            _buildBusinessLogo(
              logo,
              size: compact ? 48 : 58,
            )
          else
            _buildDefaultBusinessLogo(
              size: compact ? 48 : 58,
            ),

          SizedBox(
            height: compact ? 8 : 10,
          ),

          // Business name
          Text(
            _displayBusinessName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF0B2A55),
              fontSize: compact ? 18 : 21,
              fontWeight: FontWeight.w800,
              letterSpacing: -.35,
            ),
          ),

          const SizedBox(height: 4),

          // ScanAura tagline
          Text(
            'SCAN • CONNECT • EXPLORE',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF1D3557),
              fontSize: compact ? 8.5 : 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  String get _displayBusinessName {
    final value = businessName?.trim();

    if (value == null || value.isEmpty) {
      return 'Your Business';
    }

    return value;
  }

  Widget _buildBusinessLogo(
      String url, {
        required double size,
      }) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return _buildDefaultBusinessLogo(
            size: size,
          );
        },
      ),
    );
  }

  Widget _buildDefaultBusinessLogo({
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
            color: _brand,
            size: size * .58,
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // QR
  // ------------------------------------------------------------

  Widget _buildQrSection({
    required bool compact,
    required double qrSize,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: compact ? 8 : 12,
        left: compact ? 20 : 26,
        right: compact ? 20 : 26,
      ),
      child: Container(
        padding: EdgeInsets.all(
          compact ? 10 : 13,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            compact ? 17 : 20,
          ),
          border: Border.all(
            color: _brand.withValues(alpha: .12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: _brand.withValues(alpha: .10),
              blurRadius: 12,
            ),
          ],
        ),
        child: QrImageView(
          data: qrData,
          version: QrVersions.auto,
          size: qrSize,
          backgroundColor: Colors.white,
          gapless: true,

          // IMPORTANT:
          // No business logo is placed inside this QR.
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: Colors.black,
          ),

          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // FEATURES
  // ------------------------------------------------------------

  Widget _buildFeatureRow({
    required bool compact,
  }) {
    final features = <_Theme5Feature>[
      _Theme5Feature(
        icon: _isFood
            ? Icons.restaurant_menu_rounded
            : Icons.visibility_rounded,
        label: _primaryAction,
      ),
      const _Theme5Feature(
        icon: Icons.star_rounded,
        label: 'Reviews',
      ),
      const _Theme5Feature(
        icon: Icons.share_rounded,
        label: 'Social',
      ),
      const _Theme5Feature(
        icon: Icons.local_offer_rounded,
        label: 'Offers',
      ),
      const _Theme5Feature(
        icon: Icons.apps_rounded,
        label: 'More',
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 12 : 18,
        compact ? 15 : 19,
        compact ? 12 : 18,
        0,
      ),
      child: Row(
        children: [
          for (final feature in features)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 2,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: compact ? 43 : 49,
                      height: compact ? 43 : 49,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          compact ? 13 : 15,
                        ),
                        border: Border.all(
                          color: _brand.withValues(alpha: .10),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: .07,
                            ),
                            blurRadius: 9,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        feature.icon,
                        size: compact ? 20 : 23,
                        color: _brand,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      feature.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF19324F),
                        fontSize: compact ? 8 : 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // BUSINESS NAME
  // ------------------------------------------------------------

  Widget _buildBusinessName({
    required bool compact,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 18 : 25,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: _brand.withValues(alpha: .55),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 10 : 14,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: compact ? 155 : 205,
              ),
              child: Text(
                _displayBusinessName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF102A43),
                  fontSize: compact ? 13 : 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.2,
                ),
              ),
            ),
          ),

          Expanded(
            child: Container(
              height: 1,
              color: _brand.withValues(alpha: .55),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // FOOTER
  // ------------------------------------------------------------

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
          width: compact ? 6 : 8,
        ),

        Text(
          'Powered by ScanAura',
          style: TextStyle(
            color: const Color(0xFF19324F),
            fontSize: compact ? 11.5 : 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// FEATURE MODEL
// ------------------------------------------------------------

class _Theme5Feature {
  const _Theme5Feature({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}