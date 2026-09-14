import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../../../app/theme/app_colors.dart';

class Theme8QrCard extends StatelessWidget {
  const Theme8QrCard({
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
  // BRAND COLORS
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

  /// Dark version of the customer's brand.
  Color get _brandDark {
    return Color.lerp(
      _brand,
      Colors.black,
      .58,
    ) ??
        _brand;
  }

  /// Medium/deeper version used for borders and secondary elements.
  Color get _brandDeep {
    return Color.lerp(
      _brand,
      Colors.black,
      .28,
    ) ??
        _brand;
  }

  /// Very light version of the customer's brand.
  Color get _brandLight {
    return Color.lerp(
      _brand,
      Colors.white,
      .88,
    ) ??
        Colors.white;
  }

  /// Soft tinted background derived from the brand.
  Color get _brandSoft {
    return Color.lerp(
      Colors.white,
      _brand,
      .075,
    ) ??
        Colors.white;
  }

  /// Slightly stronger tinted background.
  Color get _brandSoftStrong {
    return Color.lerp(
      Colors.white,
      _brand,
      .14,
    ) ??
        Colors.white;
  }

  /// Text color that works against the brand.
  Color get _onBrand {
    return ThemeData.estimateBrightnessForColor(_brand) ==
        Brightness.dark
        ? Colors.white
        : const Color(0xFF111827);
  }

  /// Main dark text.
  Color get _textColor {
    return ThemeData.estimateBrightnessForColor(_brand) ==
        Brightness.dark
        ? const Color(0xFF18201E)
        : const Color(0xFF101828);
  }

  /// Secondary text.
  Color get _mutedText {
    return Color.lerp(
      _textColor,
      Colors.white,
      .35,
    ) ??
        const Color(0xFF596560);
  }

  // ===========================================================================
  // BUSINESS
  // ===========================================================================

  bool get _isFood =>
      (businessType ?? '').trim().toUpperCase() == 'FOOD';

  String get _primaryAction =>
      _isFood ? 'Menu' : 'View';

  String get _businessName {
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

        final width = availableWidth.clamp(
          280.0,
          430.0,
        );

        final compact = width < 340;
        final small = width < 380;

        final radius = compact ? 18.0 : 22.0;

        final qrSize = compact
            ? 168.0
            : small
            ? 188.0
            : 205.0;

        return Container(
          width: width,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: _brandSoft,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: _brand.withValues(alpha: .20),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _brand.withValues(alpha: .16),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: .07),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTopSection(
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
                  height: compact ? 13 : 16,
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
                height: compact ? 15 : 20,
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // TOP SECTION
  // ===========================================================================

  Widget _buildTopSection({
    required bool compact,
  }) {
    final businessLogo = businessLogoUrl?.trim();

    final hasLogo =
        businessLogo != null && businessLogo.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        compact ? 18 : 24,
        compact ? 20 : 25,
        compact ? 18 : 24,
        compact ? 18 : 22,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _brandDark,
            _brand,
            _brandDeep,
          ],
          stops: const [
            0.0,
            0.58,
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
          // -------------------------------------------------------------------

          if (hasLogo)
            _buildBusinessLogo(
              businessLogo,
              size: compact ? 46 : 52,
            )
          else
            _buildFallbackLogo(
              size: compact ? 46 : 52,
            ),

          SizedBox(
            height: compact ? 8 : 10,
          ),

          // -------------------------------------------------------------------
          // BUSINESS NAME
          // -------------------------------------------------------------------

          Text(
            _businessName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _onBrand,
              fontSize: compact ? 17 : 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -.3,
              height: 1.05,
            ),
          ),

          const SizedBox(height: 6),

          // -------------------------------------------------------------------
          // TAGLINE
          // -------------------------------------------------------------------

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'SCAN • CONNECT • EXPLORE',
              style: TextStyle(
                color: _onBrand.withValues(alpha: .90),
                fontSize: compact ? 8 : 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BUSINESS LOGO
  // ===========================================================================

  Widget _buildBusinessLogo(
      String url, {
        required double size,
      }) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          size * .22,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: .85),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .14),
            blurRadius: 9,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return _buildFallbackLogo(
            size: size - 10,
          );
        },
      ),
    );
  }

  Widget _buildFallbackLogo({
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          size * .22,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.storefront_rounded,
        color: _brand,
        size: size * .48,
      ),
    );
  }

  // ===========================================================================
  // QR SECTION
  // ===========================================================================

  Widget _buildQrSection({
    required bool compact,
    required double qrSize,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: compact ? 18 : 22,
        left: compact ? 14 : 18,
        right: compact ? 14 : 18,
      ),
      child: Container(
        padding: EdgeInsets.all(
          compact ? 11 : 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            compact ? 14 : 17,
          ),
          border: Border.all(
            color: _brand.withValues(alpha: .22),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: _brand.withValues(alpha: .12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: .06),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
          // No business logo inside the QR.
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
    final features = <_Theme8Feature>[
      _Theme8Feature(
        icon: _isFood
            ? Icons.restaurant_menu_rounded
            : Icons.visibility_rounded,
        label: _primaryAction,
      ),
      const _Theme8Feature(
        icon: Icons.star_rounded,
        label: 'Reviews',
      ),
      const _Theme8Feature(
        icon: Icons.share_rounded,
        label: 'Social',
      ),
      const _Theme8Feature(
        icon: Icons.local_offer_rounded,
        label: 'Offers',
      ),
      const _Theme8Feature(
        icon: Icons.apps_rounded,
        label: 'More',
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 12 : 17,
        compact ? 15 : 19,
        compact ? 12 : 17,
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
      _Theme8Feature feature, {
        required bool compact,
      }) {
    final size = compact ? 37.0 : 43.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _brand,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _brand.withValues(alpha: .22),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(
            feature.icon,
            color: _onBrand,
            size: compact ? 17 : 19,
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
        horizontal: compact ? 18 : 24,
      ),
      padding: EdgeInsets.symmetric(
        vertical: compact ? 8 : 9,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: _brandSoftStrong,
        borderRadius: BorderRadius.circular(
          compact ? 5 : 6,
        ),
        border: Border.all(
          color: _brand.withValues(alpha: .28),
          width: 1,
        ),
      ),
      child: Text(
        _businessName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _brandDark,
          fontSize: compact ? 13 : 15,
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
            color: _mutedText,
            fontSize: compact ? 10 : 11.5,
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

class _Theme8Feature {
  const _Theme8Feature({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}