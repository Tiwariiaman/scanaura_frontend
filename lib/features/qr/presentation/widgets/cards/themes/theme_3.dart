import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../qr_card_theme.dart';

class Theme3QrCard extends StatelessWidget {
  const Theme3QrCard({
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

  // ===========================================================================
  // SCANAURA
  // ===========================================================================

  static const String scanAuraWhiteLogo =
      'assets/images/scanaura_logo_white.png';

  static const String scanAuraLogo =
      'assets/images/scanaura_logo.png';

  // ===========================================================================
  // BRAND
  // ===========================================================================

  Color get _brand {
    final raw = brandColor
        ?.trim()
        .replaceFirst('#', '');

    if (raw != null &&
        (raw.length == 6 || raw.length == 8)) {
      final value = int.tryParse(
        raw,
        radix: 16,
      );

      if (value != null) {
        return raw.length == 8
            ? Color(value)
            : Color(0xFF000000 | value);
      }
    }

    return const Color(0xFF16A34A);
  }

  // Darker version of the customer's brand.
  Color get _brandDark {
    return Color.lerp(
      _brand,
      Colors.black,
      .42,
    ) ??
        _brand;
  }

  // Slightly lighter version of the customer's brand.
  Color get _brandLight {
    return Color.lerp(
      _brand,
      Colors.white,
      .18,
    ) ??
        _brand;
  }

  // Very subtle secondary brand tone.
  Color get _brandSoft {
    return Color.lerp(
      _brand,
      Colors.white,
      .72,
    ) ??
        Colors.white;
  }

  // Text color that remains readable on the gradient.
  Color get _onBrand {
    return ThemeData.estimateBrightnessForColor(
      _brandDark,
    ) ==
        Brightness.dark
        ? Colors.white
        : const Color(0xFF111827);
  }

  Color get _mutedOnBrand {
    return _onBrand.withValues(
      alpha: .72,
    );
  }

  // ===========================================================================
  // BUSINESS
  // ===========================================================================

  bool get _isFood =>
      (businessType ?? '')
          .trim()
          .toUpperCase() ==
          'FOOD';

  String get _primaryAction =>
      _isFood ? 'Menu' : 'View';

  IconData get _primaryIcon =>
      _isFood
          ? Icons.restaurant_menu_rounded
          : Icons.visibility_rounded;

  String get _businessTitle {
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
      builder: (
          context,
          constraints,
          ) {
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

        final radius = compact
            ? 22.0
            : 26.0;

        final qrSize = compact
            ? 164.0
            : small
            ? 184.0
            : 202.0;

        return Container(
          width: width,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _brandDark,
                _brand,
                _brandLight,
              ],
              stops: const [
                0.0,
                0.52,
                1.0,
              ],
            ),
            borderRadius: BorderRadius.circular(
              radius,
            ),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: .16,
              ),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _brandDark.withValues(
                  alpha: .30,
                ),
                blurRadius: 30,
                offset: const Offset(
                  0,
                  15,
                ),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 15 : 19,
              compact ? 18 : 22,
              compact ? 15 : 19,
              compact ? 15 : 18,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(
                  compact: compact,
                ),

                SizedBox(
                  height: compact ? 17 : 21,
                ),

                _buildQr(
                  qrSize: qrSize,
                  compact: compact,
                ),

                SizedBox(
                  height: compact ? 15 : 19,
                ),

                _buildFeatures(
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
                  height: compact ? 13 : 17,
                ),

                _buildFooter(
                  compact: compact,
                ),
              ],
            ),
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

    final hasLogo =
        logo != null &&
            logo.isNotEmpty;

    return Column(
      children: [
        // -----------------------------------------------------------------------
        // BUSINESS LOGO
        // -----------------------------------------------------------------------

        Container(
          width: compact ? 54 : 62,
          height: compact ? 54 : 62,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: .94,
            ),
            borderRadius: BorderRadius.circular(
              compact ? 16 : 18,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: .12,
                ),
                blurRadius: 12,
                offset: const Offset(
                  0,
                  5,
                ),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              compact ? 11 : 13,
            ),
            child: hasLogo
                ? Image.network(
              logo!,
              fit: BoxFit.contain,
              errorBuilder: (
                  _,
                  __,
                  ___,
                  ) {
                return _fallbackBusinessLogo(
                  compact: compact,
                );
              },
            )
                : _fallbackBusinessLogo(
              compact: compact,
            ),
          ),
        ),

        SizedBox(
          height: compact ? 8 : 10,
        ),

        // -----------------------------------------------------------------------
        // BUSINESS NAME
        // -----------------------------------------------------------------------

        Text(
          _businessTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _onBrand,
            fontSize: compact ? 18 : 21,
            fontWeight: FontWeight.w800,
            letterSpacing: -.45,
            height: 1.05,
          ),
        ),

        const SizedBox(
          height: 6,
        ),

        // -----------------------------------------------------------------------
        // TAGLINE
        // -----------------------------------------------------------------------

        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'SCAN • CONNECT • EXPLORE',
            maxLines: 1,
            style: TextStyle(
              color: _mutedOnBrand,
              fontSize: compact ? 8 : 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.55,
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // FALLBACK BUSINESS LOGO
  // ===========================================================================

  Widget _fallbackBusinessLogo({
    required bool compact,
  }) {
    return Container(
      color: _brandSoft.withValues(
        alpha: .35,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.storefront_rounded,
        color: _brandDark,
        size: compact ? 25 : 29,
      ),
    );
  }

  // ===========================================================================
  // QR
  // ===========================================================================

  Widget _buildQr({
    required double qrSize,
    required bool compact,
  }) {
    return Container(
      padding: EdgeInsets.all(
        compact ? 10 : 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          compact ? 18 : 21,
        ),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: .85,
          ),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: .14,
            ),
            blurRadius: 20,
            offset: const Offset(
              0,
              9,
            ),
          ),
          BoxShadow(
            color: _brandDark.withValues(
              alpha: .18,
            ),
            blurRadius: 24,
            offset: const Offset(
              0,
              4,
            ),
          ),
        ],
      ),
      child: QrImageView(
        data: qrData,
        version: QrVersions.auto,
        size: qrSize,
        backgroundColor: Colors.white,
        gapless: true,

        // No business logo inside QR.
        errorCorrectionLevel:
        QrErrorCorrectLevel.H,

        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Colors.black,
        ),

        dataModuleStyle:
        const QrDataModuleStyle(
          dataModuleShape:
          QrDataModuleShape.square,
          color: Colors.black,
        ),
      ),
    );
  }

  // ===========================================================================
  // FEATURES
  // ===========================================================================

  Widget _buildFeatures({
    required bool compact,
  }) {
    final features = <_Theme3Feature>[
      _Theme3Feature(
        icon: _primaryIcon,
        label: _primaryAction,
      ),
      const _Theme3Feature(
        icon: Icons.star_rounded,
        label: 'Reviews',
      ),
      const _Theme3Feature(
        icon: Icons.share_rounded,
        label: 'Social',
      ),
      const _Theme3Feature(
        icon: Icons.local_offer_rounded,
        label: 'Offers',
      ),
      const _Theme3Feature(
        icon: Icons.apps_rounded,
        label: 'More',
      ),
    ];

    return Row(
      children: [
        for (final feature in features)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 2,
              ),
              child: _buildFeatureItem(
                feature,
                compact: compact,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeatureItem(
      _Theme3Feature feature, {
        required bool compact,
      }) {
    final size = compact
        ? 37.0
        : 43.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // -----------------------------------------------------------------------
        // GLASS BUTTON
        // -----------------------------------------------------------------------

        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: .16,
            ),
            borderRadius: BorderRadius.circular(
              compact ? 13 : 15,
            ),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: .24,
              ),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: .08,
                ),
                blurRadius: 8,
                offset: const Offset(
                  0,
                  4,
                ),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(
            feature.icon,
            color: _onBrand,
            size: compact ? 18 : 20,
          ),
        ),

        const SizedBox(
          height: 4,
        ),

        Text(
          feature.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _onBrand.withValues(
              alpha: .88,
            ),
            fontSize: compact ? 7.2 : 8.2,
            fontWeight: FontWeight.w700,
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

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: compact ? 8 : 10,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: .13,
        ),
        borderRadius: BorderRadius.circular(
          compact ? 12 : 14,
        ),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: .20,
          ),
        ),
      ),
      child: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _onBrand,
          fontSize: compact ? 12.5 : 14,
          fontWeight: FontWeight.w800,
          letterSpacing: -.15,
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
            color: _onBrand.withValues(
              alpha: .82,
            ),
            fontSize: compact ? 10 : 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// FEATURE MODEL
// =============================================================================

class _Theme3Feature {
  const _Theme3Feature({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}