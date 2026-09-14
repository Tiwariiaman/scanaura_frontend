import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../../../app/theme/app_colors.dart';

class Theme1QrCard extends StatelessWidget {
  const Theme1QrCard({
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

  // ------------------------------------------------------------
  // BRAND COLOR
  // ------------------------------------------------------------

  Color get brand {
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

  // ------------------------------------------------------------
  // GRADIENT
  // ------------------------------------------------------------

  LinearGradient get brandGradient {
    final second = Color.lerp(
      brand,
      Colors.black,
      .20,
    )!;

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        brand,
        second,
      ],
    );
  }

  // ------------------------------------------------------------
  // CONTRAST COLOR
  // ------------------------------------------------------------

  Color get onBrand {
    return ThemeData.estimateBrightnessForColor(brand) ==
        Brightness.dark
        ? Colors.white
        : const Color(0xFF111827);
  }

  // ------------------------------------------------------------
  // BUSINESS LOGO
  //
  // IMPORTANT:
  // No white background.
  // No border.
  // No forced square styling.
  // ------------------------------------------------------------

  Widget _businessLogo({
    required double size,
  }) {
    final url = businessLogoUrl?.trim();

    if (url == null || url.isEmpty) {
      return _fallbackLogo(size);
    }

    return SizedBox(
      width: size,
      height: size,
      child: Image.network(
        url,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        errorBuilder: (_, __, ___) {
          return _fallbackLogo(size);
        },
      ),
    );
  }

  Widget _fallbackLogo(double size) {
    return Image.asset(
      scanAuraLogo,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return Icon(
          Icons.business_rounded,
          size: size * .55,
          color: onBrand,
        );
      },
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 430.0;

        final cardWidth = width.clamp(280.0, 430.0);

        final compact = cardWidth < 340;
        final small = cardWidth < 380;

        final qrSize = (cardWidth - 100).clamp(
          180.0,
          compact
              ? 210.0
              : small
              ? 225.0
              : 245.0,
        );

        return Container(
          width: cardWidth,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              compact ? 20 : 26,
            ),
            border: Border.all(
              color: brand.withValues(alpha: .18),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: brand.withValues(alpha: .12),
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
                small: small,
              ),

              _buildQrSection(
                qrSize: qrSize,
                compact: compact,
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
        );
      },
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader({
    required bool compact,
    required bool small,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        compact ? 18 : 24,
        compact ? 20 : 25,
        compact ? 18 : 24,
        compact ? 22 : 27,
      ),
      decoration: BoxDecoration(
        gradient: brandGradient,
      ),
      child: Column(
        children: [
          // ------------------------------------------------------
          // BUSINESS LOGO + BUSINESS NAME
          // ------------------------------------------------------

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _businessLogo(
                size: compact ? 46 : 54,
              ),

              const SizedBox(width: 10),

              Flexible(
                child: Text(
                  businessName?.trim().isNotEmpty == true
                      ? businessName!.trim()
                      : 'Your Business',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: onBrand,
                    fontSize: compact ? 20 : 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.5,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(
            height: compact ? 13 : 16,
          ),

          // ------------------------------------------------------
          // TAGLINE
          // ------------------------------------------------------

          Text(
            'SCAN • CONNECT • EXPLORE',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: onBrand.withValues(alpha: .92),
              fontSize: compact ? 9 : 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Scan to unlock the Aura of this business.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: onBrand.withValues(alpha: .76),
              fontSize: compact ? 10.5 : 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QR SECTION
  //
  // IMPORTANT:
  // There is NO business logo here.
  // ============================================================

  Widget _buildQrSection({
    required double qrSize,
    required bool compact,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: compact ? 20 : 26,
        bottom: compact ? 12 : 16,
      ),
      child: Container(
        padding: EdgeInsets.all(
          compact ? 12 : 15,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            compact ? 17 : 20,
          ),
          border: Border.all(
            color: brand.withValues(alpha: .22),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .06),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),

        // --------------------------------------------------------
        // CLEAN QR ONLY
        // --------------------------------------------------------

        child: QrImageView(
          data: qrData,
          version: QrVersions.auto,
          size: qrSize,
          backgroundColor: Colors.white,
          gapless: true,

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

  // ============================================================
  // FEATURES
  // ============================================================

  Widget _buildFeatureRow({
    required bool compact,
  }) {
    final features = [
      _Feature(
        icon: businessType?.toUpperCase() == 'FOOD'
            ? Icons.restaurant_menu_rounded
            : Icons.visibility_rounded,
        label: businessType?.toUpperCase() == 'FOOD'
            ? 'Menu'
            : 'View',
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
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 15,
        vertical: compact ? 7 : 10,
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
                  children: [
                    Container(
                      width: compact ? 42 : 48,
                      height: compact ? 42 : 48,
                      decoration: BoxDecoration(
                        color: brand.withValues(alpha: .08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: brand.withValues(alpha: .18),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        feature.icon,
                        size: compact ? 20 : 23,
                        color: brand,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      feature.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF101828),
                        fontSize: compact ? 8.5 : 9.5,
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

  // ============================================================
  // BUSINESS NAME
  // ============================================================

  Widget _buildBusinessName({
    required bool compact,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: compact ? 18 : 24,
      ),
      padding: EdgeInsets.symmetric(
        vertical: compact ? 9 : 11,
      ),
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(
            color: brand.withValues(alpha: .55),
            width: 1,
          ),
        ),
      ),
      child: Text(
        businessName?.trim().isNotEmpty == true
            ? businessName!.trim()
            : 'Your Business Name',
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: const Color(0xFF101828),
          fontSize: compact ? 16 : 18,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
      ),
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter({
    required bool compact,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        compact ? 13 : 16,
        16,
        compact ? 17 : 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            scanAuraWhiteLogo,
            width: compact ? 22 : 25,
            height: compact ? 22 : 25,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return Container(
                width: compact ? 22 : 25,
                height: compact ? 22 : 25,
                decoration: BoxDecoration(
                  color: brand,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  Icons.qr_code_rounded,
                  color: Colors.white,
                  size: compact ? 14 : 16,
                ),
              );
            },
          ),

          const SizedBox(width: 7),

          Text(
            'Powered by ScanAura',
            style: TextStyle(
              color: const Color(0xFF101828),
              fontSize: compact ? 11.5 : 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// FEATURE MODEL
// ================================================================

class _Feature {
  const _Feature({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}