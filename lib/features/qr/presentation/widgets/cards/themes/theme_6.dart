import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../../../app/theme/app_colors.dart';

class Theme6QrCard extends StatelessWidget {
  const Theme6QrCard({
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

  static const String scanAuraLogo = 'assets/images/scanaura_logo.png';

  // ===========================================================================
  // BRAND
  // ===========================================================================

  Color get _brand {
    final raw = brandColor?.trim().replaceFirst('#', '');

    if (raw != null && (raw.length == 6 || raw.length == 8)) {
      final value = int.tryParse(raw, radix: 16);

      if (value != null) {
        return raw.length == 8 ? Color(value) : Color(0xFF000000 | value);
      }
    }

    return AppColors.primary;
  }

  Color get _brandDark {
    return Color.lerp(_brand, Colors.black, .28) ?? _brand;
  }

  Color get _brandSoft {
    return Color.lerp(_brand, Colors.white, .90) ?? Colors.white;
  }

  Color get _brandPale {
    return Color.lerp(_brand, Colors.white, .95) ?? Colors.white;
  }

  Color get _text {
    return const Color(0xFF111614);
  }

  Color get _muted {
    return const Color(0xFF68716E);
  }

  Color get _onBrand {
    return ThemeData.estimateBrightnessForColor(_brand) == Brightness.dark
        ? Colors.white
        : const Color(0xFF101513);
  }

  // ===========================================================================
  // BUSINESS
  // ===========================================================================

  bool get _isFood => (businessType ?? '').trim().toUpperCase() == 'FOOD';

  String get _primaryAction => _isFood ? 'Menu' : 'View';

  IconData get _primaryIcon =>
      _isFood ? Icons.restaurant_menu_rounded : Icons.visibility_rounded;

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

        final width = availableWidth.clamp(280.0, 430.0);

        final compact = width < 340;
        final small = width < 380;

        final qrSize = compact
            ? 166.0
            : small
            ? 184.0
            : 202.0;

        return Container(
          width: width,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8F6),
            borderRadius: BorderRadius.circular(compact ? 20 : 24),
            border: Border.all(color: Colors.black.withValues(alpha: .08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .10),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIdentityHeader(
                compact: compact,
              ),

              SizedBox(height: compact ? 14 : 18),

              _buildQrArea(compact: compact, small: small, qrSize: qrSize),

              SizedBox(height: compact ? 15 : 19),

              _buildActionStrip(compact: compact),

              if (showBusinessName) ...[
                SizedBox(height: compact ? 14 : 17),
                _buildBusinessName(compact: compact),
              ],

              SizedBox(height: compact ? 14 : 18),

              _buildFooter(compact: compact),

              SizedBox(height: compact ? 14 : 18),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
// IDENTITY HEADER
// ===========================================================================

  Widget _buildIdentityHeader({
    required bool compact,
  }) {
    final logo = businessLogoUrl?.trim();
    final hasLogo = logo != null && logo.isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 17 : 21,
        compact ? 15 : 18,
        compact ? 17 : 21,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // -------------------------------------------------------------------
          // BUSINESS LOGO
          // -------------------------------------------------------------------

          _buildBusinessLogo(
            logo: hasLogo ? logo : null,
            compact: compact,
          ),

          SizedBox(
            width: compact ? 9 : 12,
          ),

          // -------------------------------------------------------------------
          // BUSINESS NAME + TAGLINE
          // -------------------------------------------------------------------

          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _businessName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _text,
                    fontSize: compact ? 16 : 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.5,
                    height: 1.05,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'SCAN • CONNECT • EXPLORE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _muted,
                    fontSize: compact ? 7 : 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .55,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            width: compact ? 8 : 11,
          ),

          // -------------------------------------------------------------------
          // LIVE
          // -------------------------------------------------------------------

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 10,
              vertical: compact ? 5 : 6,
            ),
            decoration: BoxDecoration(
              color: _brandPale,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: _brand.withValues(alpha: .18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: compact ? 5 : 6,
                  height: compact ? 5 : 6,
                  decoration: BoxDecoration(
                    color: _brand,
                    shape: BoxShape.circle,
                  ),
                ),

                SizedBox(
                  width: compact ? 5 : 6,
                ),

                Text(
                  'Live',
                  style: TextStyle(
                    color: _brandDark,
                    fontSize: compact ? 7 : 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BUSINESS LOGO
  // ===========================================================================

  Widget _buildBusinessLogo({required String? logo, required bool compact}) {
    final size = compact ? 48.0 : 56.0;

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(compact ? 14 : 16),
        border: Border.all(color: _brand.withValues(alpha: .15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: logo != null
          ? Image.network(
              logo,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return _fallbackLogo();
              },
            )
          : _fallbackLogo(),
    );
  }

  Widget _fallbackLogo() {
    return Icon(Icons.storefront_rounded, color: _brand, size: 27);
  }

  // ===========================================================================
  // QR AREA
  // ===========================================================================

  Widget _buildQrArea({
    required bool compact,
    required bool small,
    required double qrSize,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 18),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Offset brand block.
          Positioned(
            left: compact ? 3 : 7,
            top: compact ? 8 : 11,
            child: Container(
              width: compact ? 92 : 112,
              height: compact ? 92 : 112,
              decoration: BoxDecoration(
                color: _brandSoft,
                borderRadius: BorderRadius.circular(compact ? 18 : 22),
              ),
            ),
          ),

          // Main QR card.
          Container(
            padding: EdgeInsets.all(compact ? 12 : 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(compact ? 19 : 23),
              border: Border.all(color: Colors.black.withValues(alpha: .07)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .09),
                  blurRadius: 20,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: qrSize,
                  backgroundColor: Colors.white,
                  gapless: true,
                  errorCorrectionLevel: QrErrorCorrectLevel.H,

                  // Keep QR pure black & white.
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),

                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: compact ? 7 : 9),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: _brand,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'POINT CAMERA HERE',
                      style: TextStyle(
                        color: _muted,
                        fontSize: compact ? 7 : 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .9,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ACTION STRIP
  // ===========================================================================

  Widget _buildActionStrip({required bool compact}) {
    final actions = <_Theme6Action>[
      _Theme6Action(icon: _primaryIcon, label: _primaryAction),
      const _Theme6Action(icon: Icons.star_rounded, label: 'Reviews'),
      const _Theme6Action(icon: Icons.share_rounded, label: 'Social'),
      const _Theme6Action(icon: Icons.local_offer_rounded, label: 'Offers'),
      const _Theme6Action(icon: Icons.apps_rounded, label: 'More'),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 17,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 5 : 7,
          vertical: compact ? 7 : 9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            compact ? 15 : 18,
          ),
          border: Border.all(
            color: Colors.black.withValues(alpha: .07),
          ),
        ),
        child: Row(
          children: [
            for (final action in actions)
              Expanded(
                child: _buildAction(
                  action,
                  compact: compact,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAction(
      _Theme6Action action, {
        required bool compact,
      }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 34 : 39,
          height: compact ? 34 : 39,
          decoration: BoxDecoration(
            color: _brandPale,
            borderRadius: BorderRadius.circular(
              compact ? 10 : 11,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            action.icon,
            color: _brandDark,
            size: compact ? 16 : 18,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          action.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _text,
            fontSize: compact ? 6.5 : 7.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
  // ===========================================================================
  // BUSINESS NAME
  // ===========================================================================

  Widget _buildBusinessName({required bool compact}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 20 : 27),
      child: Row(
        children: [
          Container(
            width: compact ? 22 : 30,
            height: 2,
            decoration: BoxDecoration(
              color: _brand,
              borderRadius: BorderRadius.circular(5),
            ),
          ),

          SizedBox(width: compact ? 8 : 10),

          Expanded(
            child: Text(
              _businessName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _text,
                fontSize: compact ? 11 : 12.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -.1,
              ),
            ),
          ),

          SizedBox(width: compact ? 8 : 10),

          Container(
            width: compact ? 22 : 30,
            height: 2,
            decoration: BoxDecoration(
              color: _brand,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // FOOTER
  // ===========================================================================

  Widget _buildFooter({required bool compact}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/scanaura_logo_white.png',
          width: compact ? 19 : 22,
          height: compact ? 19 : 22,
          fit: BoxFit.contain,
        ),

        SizedBox(width: compact ? 6 : 8),

        Text(
          'Powered by ScanAura',
          style: TextStyle(
            color: _muted,
            fontSize: compact ? 9.5 : 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// ACTION MODEL
// =============================================================================

class _Theme6Action {
  const _Theme6Action({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
