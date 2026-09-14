import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Theme4QrCard extends StatelessWidget {
  const Theme4QrCard({
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

  static const String scanAuraWhiteLogo =
      'assets/images/scanaura_logo_white.png';

  static const String scanAuraLogo =
      'assets/images/scanaura_logo.png';

  // ===========================================================================
  // BRAND
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

    // Neutral premium fallback.
    return const Color(0xFF7C3AED);
  }

  Color get _brandDark {
    return Color.lerp(
      _brand,
      Colors.black,
      .28,
    ) ??
        _brand;
  }

  Color get _brandLight {
    return Color.lerp(
      _brand,
      Colors.white,
      .92,
    ) ??
        Colors.white;
  }

  Color get _brandSoft {
    return Color.lerp(
      _brand,
      Colors.white,
      .84,
    ) ??
        Colors.white;
  }

  Color get _brandVerySoft {
    return Color.lerp(
      _brand,
      Colors.white,
      .96,
    ) ??
        Colors.white;
  }

  // ===========================================================================
  // BUSINESS TYPE
  // ===========================================================================

  bool get _isFood =>
      (businessType ?? '').trim().toUpperCase() == 'FOOD';

  String get _primaryAction =>
      _isFood ? 'Menu' : 'View';

  IconData get _primaryIcon =>
      _isFood
          ? Icons.restaurant_menu_rounded
          : Icons.visibility_rounded;

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
        constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 430.0;

        final width = availableWidth.clamp(
          280.0,
          430.0,
        );

        final compact = width < 340;
        final small = width < 380;

        final qrSize = (width - 116).clamp(
          165.0,
          compact
              ? 190.0
              : small
              ? 205.0
              : 220.0,
        );

        return Container(
          width: width,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: _brandVerySoft,
            borderRadius: BorderRadius.circular(
              compact ? 18 : 22,
            ),
            border: Border.all(
              color: _brand.withValues(alpha: .22),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: _brand.withValues(alpha: .15),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(
                compact: compact,
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
                  height: compact ? 13 : 17,
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

              SizedBox(
                height: compact ? 14 : 18,
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        compact ? 18 : 24,
        compact ? 18 : 23,
        compact ? 18 : 24,
        compact ? 14 : 17,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            _brandVerySoft,
            _brandLight,
          ],
          stops: const [
            0.0,
            0.62,
            1.0,
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            compact ? 18 : 22,
          ),
          topRight: Radius.circular(
            compact ? 18 : 22,
          ),
        ),
      ),
      child: Column(
        children: [
          // -------------------------------------------------------------------
          // BUSINESS LOGO
          //
          // IMPORTANT:
          // No white container.
          // No border.
          // No background.
          // -------------------------------------------------------------------

          _buildBusinessLogo(
            size: compact ? 58 : 68,
          ),

          SizedBox(
            height: compact ? 7 : 9,
          ),

          // -------------------------------------------------------------------
          // BUSINESS NAME
          // -------------------------------------------------------------------

          Text(
            _businessTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF101828),
              fontSize: compact ? 17 : 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -.35,
              height: 1.1,
            ),
          ),

          const SizedBox(height: 5),

          // -------------------------------------------------------------------
          // TAGLINE
          // -------------------------------------------------------------------

          Text(
            'SCAN • CONNECT • EXPLORE',
            style: TextStyle(
              color: _brandDark,
              fontSize: compact ? 8.5 : 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.35,
            ),
          ),

          SizedBox(
            height: compact ? 10 : 13,
          ),

          // -------------------------------------------------------------------
          // BRAND DIVIDER
          // -------------------------------------------------------------------

          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        _brand.withValues(alpha: .65),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: compact ? 11 : 13,
                  color: _brand,
                ),
              ),

              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _brand.withValues(alpha: .65),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _businessTitle {
    final name = businessName?.trim();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    return 'Your Business';
  }

  // ===========================================================================
  // QR
  // ===========================================================================

  Widget _buildQrSection({
    required bool compact,
    required double qrSize,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: compact ? 13 : 17,
        left: compact ? 14 : 20,
        right: compact ? 14 : 20,
      ),
      child: Container(
        padding: compact
            ? const EdgeInsets.all(10)
            : const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            compact ? 13 : 15,
          ),
          border: Border.all(
            color: _brand.withValues(alpha: .60),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: _brand.withValues(alpha: .10),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        // IMPORTANT:
        // No logo is placed inside the QR.
        child: QrImageView(
          data: qrData,
          version: QrVersions.auto,
          size: qrSize,
          backgroundColor: Colors.white,
          gapless: true,
          errorCorrectionLevel: QrErrorCorrectLevel.H,

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

  // ===========================================================================
  // FEATURES
  // ===========================================================================

  Widget _buildFeatureRow({
    required bool compact,
  }) {
    final features = [
      _Feature(
        icon: _primaryIcon,
        label: _primaryAction,
      ),
      const _Feature(
        icon: Icons.star_rounded,
        label: 'Reviews',
      ),
      const _Feature(
        icon: Icons.share_rounded,
        label: 'Social',
      ),
      const _Feature(
        icon: Icons.local_offer_rounded,
        label: 'Offers',
      ),
      const _Feature(
        icon: Icons.apps_rounded,
        label: 'More',
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 9 : 14,
        compact ? 15 : 18,
        compact ? 9 : 14,
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
                      width: compact ? 38 : 43,
                      height: compact ? 38 : 43,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _brandSoft,
                            _brandLight,
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _brand.withValues(alpha: .22),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        feature.icon,
                        size: compact ? 19 : 21,
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
                        color: const Color(0xFF101828),
                        fontSize: compact ? 8 : 8.8,
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

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 21,
      ),
      padding: EdgeInsets.symmetric(
        vertical: compact ? 7 : 9,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            _brand.withValues(alpha: .03),
            _brand.withValues(alpha: .12),
            _brand.withValues(alpha: .03),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: _brand.withValues(alpha: .65),
            width: 1,
          ),
          bottom: BorderSide(
            color: _brand.withValues(alpha: .65),
            width: 1,
          ),
        ),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF101828),
                fontSize: compact ? 13 : 15,
                fontWeight: FontWeight.w800,
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
          width: compact ? 5 : 7,
        ),

        Text(
          'Powered by ScanAura',
          style: TextStyle(
            color: const Color(0xFF101828),
            fontSize: compact ? 10.5 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // BUSINESS LOGO
  // ===========================================================================

  Widget _buildBusinessLogo({
    required double size,
  }) {
    final url = businessLogoUrl?.trim();

    final hasLogo =
        url != null && url.isNotEmpty;

    // IMPORTANT:
    // There is intentionally NO white container here.
    // The actual business logo is rendered directly.
    return SizedBox(
      width: size,
      height: size,
      child: hasLogo
          ? Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return _buildFallbackBusinessLogo(
            size: size,
          );
        },
      )
          : _buildFallbackBusinessLogo(
        size: size,
      ),
    );
  }

  Widget _buildFallbackBusinessLogo({
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _brand,
            _brandDark,
          ],
        ),
        borderRadius: BorderRadius.circular(
          size * .22,
        ),
      ),
      child: Icon(
        Icons.business_rounded,
        color: Colors.white,
        size: size * .45,
      ),
    );
  }
}

// =============================================================================
// FEATURE MODEL
// =============================================================================

class _Feature {
  const _Feature({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}