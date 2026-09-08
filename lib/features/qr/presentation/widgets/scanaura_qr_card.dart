import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';

class ScanAuraQrCard extends StatelessWidget {
  const ScanAuraQrCard({
    super.key,
    required this.qrData,
    this.businessName,
    this.businessLogoUrl,
    this.showBusinessName = true,
  });

  final String qrData;
  final String? businessName;
  final String? businessLogoUrl;
  final bool showBusinessName;

  // ============================================================
  // SCANAURA ASSETS
  // ============================================================

  static const String topLogo =
      'assets/images/scanaura_logo_white.png';

  static const String footerLogo =
      'assets/images/scanaura_logo.png';

  @override
  Widget build(BuildContext context) {
    final hasBusinessName =
        businessName != null &&
            businessName!
                .trim()
                .isNotEmpty;

    final hasBusinessLogo =
        businessLogoUrl != null &&
            businessLogoUrl!
                .trim()
                .isNotEmpty;

    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        final availableWidth =
            constraints.maxWidth;

        // ========================================================
        // RESPONSIVE CARD WIDTH
        // ========================================================

        final cardWidth =
        availableWidth > 430
            ? 430.0
            : availableWidth;

        final compact =
            cardWidth < 340;

        final small =
            cardWidth < 380;

        final outerHorizontal =
        compact
            ? 12.0
            : small
            ? 14.0
            : 18.0;

        final cardRadius =
        compact ? 22.0 : 28.0;

        final headerTopPadding =
        compact ? 20.0 : 26.0;

        final headerBottomPadding =
        compact ? 76.0 : 92.0;

        final contentHorizontal =
        compact ? 14.0 : 18.0;

        final qrOuterPadding =
        compact ? 10.0 : 14.0;

        final qrOuterRadius =
        compact ? 18.0 : 22.0;

        // Keep the actual QR comfortably
        // scannable while allowing smaller phones.
        final qrSize =
        (cardWidth -
            (contentHorizontal * 2) -
            (qrOuterPadding * 2) -
            8)
            .clamp(
          180.0,
          compact
              ? 220.0
              : small
              ? 235.0
              : 250.0,
        );

        final businessLogoSize =
        compact
            ? 44.0
            : 52.0;

        final footerLogoSize =
        compact ? 24.0 : 27.0;

        final businessNameFontSize =
        compact
            ? 18.0
            : small
            ? 20.0
            : 22.0;

        final taglineFontSize =
        compact
            ? 19.0
            : small
            ? 21.0
            : 23.0;

        final descriptionFontSize =
        compact ? 13.0 : 15.0;

        return Container(
          width: cardWidth,
          constraints:
          const BoxConstraints(
            maxWidth: 430,
          ),
          clipBehavior:
          Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(
              cardRadius,
            ),
            border: Border.all(
              color:
              AppColors.primary.withValues(
                alpha: 0.10,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color:
                Colors.black.withValues(
                  alpha: 0.10,
                ),
                blurRadius:
                compact ? 16 : 24,
                offset:
                const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              // ==================================================
              // GREEN HEADER
              // ==================================================

              Stack(
                clipBehavior:
                Clip.none,
                children: [
                  Container(
                    width:
                    double.infinity,
                    padding:
                    EdgeInsets.fromLTRB(
                      outerHorizontal +
                          6,
                      headerTopPadding,
                      outerHorizontal +
                          6,
                      headerBottomPadding,
                    ),
                    color:
                    AppColors.primary,
                    child: Column(
                      children: [
                        // ==============================================
                        // SCANAURA LOGO
                        // ==============================================

                        // ==============================================
// SCANAURA LOGO — PERMANENT WHITE
// ==============================================

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: businessLogoSize,
                              height: businessLogoSize,
                              child: Image.asset(
                                topLogo,
                                fit: BoxFit.contain,
                                errorBuilder: (
                                    context,
                                    error,
                                    stackTrace,
                                    ) {
                                  // Keep fallback WHITE as well.
                                  return Icon(
                                    Icons.qr_code_rounded,
                                    color: Colors.white,
                                    size: compact ? 24 : 28,
                                  );
                                },
                              ),
                            ),

                            SizedBox(
                              width: compact ? 8 : 12,
                            ),

                            Flexible(
                              child: Text(
                                'ScanAura',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: compact ? 22 : 28,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height:
                          compact
                              ? 18
                              : 22,
                        ),

                        // ==============================================
                        // TAGLINE
                        // ==============================================

                        SizedBox(
                          width: double.infinity,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'SCAN • CONNECT • EXPLORE',
                              maxLines: 1,
                              softWrap: false,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height:
                          compact
                              ? 8
                              : 10,
                        ),

                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: descriptionFontSize,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                            children: const [
                              TextSpan(
                                text: 'Scan',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(text: ' to unlock the '),
                              TextSpan(
                                text: 'Aura',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(text: ' of this business.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==================================================
                  // CURVED TRANSITION
                  // ==================================================

                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: -1,
                    child: ClipPath(
                      clipper:
                      _QrCurveClipper(
                        compact:
                        compact,
                      ),
                      child:
                      Container(
                        height:
                        compact
                            ? 64
                            : 78,
                        color:
                        Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              // ==================================================
              // QR CONTENT
              // ==================================================

              Padding(
                padding:
                EdgeInsets.fromLTRB(
                  contentHorizontal,
                  0,
                  contentHorizontal,
                  compact
                      ? 18
                      : 22,
                ),
                child: Column(
                  children: [
                    // ==============================================
                    // QR
                    // ==============================================

                    Container(
                      padding:
                      EdgeInsets.all(
                        qrOuterPadding,
                      ),
                      decoration:
                      BoxDecoration(
                        color:
                        Colors.white,
                        borderRadius:
                        BorderRadius.circular(
                          qrOuterRadius,
                        ),
                        border:
                        Border.all(
                          color:
                          AppColors.primary
                              .withValues(
                            alpha: 0.20,
                          ),
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                            Colors.black
                                .withValues(
                              alpha: 0.07,
                            ),
                            blurRadius:
                            compact
                                ? 10
                                : 14,
                            offset:
                            const Offset(
                              0,
                              5,
                            ),
                          ),
                        ],
                      ),
                      child:
                      Stack(
                        alignment:
                        Alignment
                            .center,
                        children: [
                          QrImageView(
                            data:
                            qrData,
                            version:
                            QrVersions.auto,
                            size:
                            qrSize,
                            backgroundColor:
                            Colors.white,
                            gapless: true,
                            eyeStyle:
                            const QrEyeStyle(
                              eyeShape:
                              QrEyeShape
                                  .square,
                              color:
                              Colors.black,
                            ),
                            dataModuleStyle:
                            const QrDataModuleStyle(
                              dataModuleShape:
                              QrDataModuleShape
                                  .square,
                              color:
                              Colors.black,
                            ),
                          ),

                          // ============================================
                          // BUSINESS LOGO INSIDE QR
                          // ============================================

                          if (hasBusinessLogo)
                            Container(
                              width:
                              compact
                                  ? 44
                                  : 52,
                              height:
                              compact
                                  ? 44
                                  : 52,
                              padding:
                              const EdgeInsets.all(
                                4,
                              ),
                              decoration:
                              BoxDecoration(
                                color:
                                Colors.white,
                                borderRadius:
                                BorderRadius.circular(
                                  compact
                                      ? 10
                                      : 12,
                                ),
                                border:
                                Border.all(
                                  color:
                                  Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                    Colors.black.withValues(
                                      alpha:
                                      0.16,
                                    ),
                                    blurRadius:
                                    8,
                                  ),
                                ],
                              ),
                              clipBehavior:
                              Clip.antiAlias,
                              child:
                              Image.network(
                                businessLogoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (
                                    context,
                                    error,
                                    stackTrace,
                                    ) {
                                  return Image.asset(
                                    footerLogo,
                                    fit: BoxFit
                                        .contain,
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height:
                      compact
                          ? 18
                          : 24,
                    ),

                    // ==============================================
                    // SCANAURA SERVICE ICONS
                    // ==============================================

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 0 : 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _QrFeatureItem(
                            icon: Icons.restaurant_menu_outlined,
                            label: 'Menu',
                            compact: compact,
                          ),
                          _QrFeatureItem(
                            svgData: _QrBrandIcons.google,
                            label: 'Reviews',
                            compact: compact,
                            semanticsLabel: 'Google Reviews',
                          ),
                          _QrFeatureItem(
                            svgData: _QrBrandIcons.instagram,
                            label: 'Instagram',
                            compact: compact,
                            semanticsLabel: 'Instagram',
                          ),
                          _QrFeatureItem(
                            svgData: _QrBrandIcons.facebook,
                            label: 'Facebook',
                            compact: compact,
                            semanticsLabel: 'Facebook',
                          ),
                          _QrFeatureItem(
                            svgData: _QrBrandIcons.youtube,
                            label: 'YouTube',
                            compact: compact,
                            semanticsLabel: 'YouTube',
                          ),
                          _QrFeatureItem(
                            icon: Icons.apps_outlined,
                            label: 'And More',
                            compact: compact,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height:
                      compact
                          ? 18
                          : 22,
                    ),

                    // ==============================================
                    // BUSINESS NAME
                    // ==============================================

                    if (showBusinessName)
                      Container(
                        width:
                        double.infinity,
                        constraints:
                        const BoxConstraints(
                          minHeight: 46,
                        ),
                        padding:
                        const EdgeInsets
                            .symmetric(
                          vertical: 9,
                          horizontal: 8,
                        ),
                        decoration:
                        const BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color:
                              AppColors.primary,
                              width: 1.4,
                            ),
                            bottom:
                            BorderSide(
                              color:
                              AppColors.primary,
                              width: 1.4,
                            ),
                          ),
                        ),
                        alignment:
                        Alignment.center,
                        child: Text(
                          hasBusinessName
                              ? businessName!.trim()
                              : '',
                          textAlign: TextAlign.center,
                          maxLines: compact ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: businessNameFontSize,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      ),

                    SizedBox(
                      height:
                      compact
                          ? 18
                          : 22,
                    ),

                    // ==============================================
                    // FOOTER
                    // ==============================================

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                      children: [
                        Image.asset(
                          footerLogo,
                          width:
                          footerLogoSize,
                          height:
                          footerLogoSize,
                          fit:
                          BoxFit.contain,
                          errorBuilder:
                              (
                              context,
                              error,
                              stackTrace,
                              ) {
                            return Icon(
                              Icons
                                  .qr_code_rounded,
                              size:
                              footerLogoSize,
                              color:
                              AppColors.primary,
                            );
                          },
                        ),

                        SizedBox(
                          width:
                          compact
                              ? 6
                              : 8,
                        ),

                        Flexible(
                          child:
                          Text(
                            'Powered by ScanAura',
                            maxLines: 1,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            TextStyle(
                              color:
                              AppColors.textPrimary,
                              fontSize:
                              compact
                                  ? 13
                                  : 15,
                              fontWeight:
                              FontWeight
                                  .w600,
                            ),
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
      },
    );
  }
}

// ================================================================
// CURVED WHITE TRANSITION
// ================================================================

class _QrBrandIcons {
  const _QrBrandIcons._();

  static const String google =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">'
      '<path fill="#4285F4" d="M44.5 24.5c0-1.57-.14-3.09-.4-4.5H24v8.51h11.49a9.82 9.82 0 0 1-4.26 6.44v5.36h6.9c4.04-3.72 6.37-9.2 6.37-15.81z"/>'
      '<path fill="#34A853" d="M24 45c5.79 0 10.64-1.92 14.17-5.19l-6.9-5.36c-1.91 1.28-4.35 2.05-7.27 2.05-5.6 0-10.35-3.78-12.05-8.86H4.82v5.54A21.4 21.4 0 0 0 24 45z"/>'
      '<path fill="#FBBC05" d="M11.95 27.64A12.86 12.86 0 0 1 11.3 24c0-1.26.22-2.48.65-3.64v-5.54H4.82A21.38 21.38 0 0 0 2.5 24c0 3.46.83 6.73 2.32 9.18l7.13-5.54z"/>'
      '<path fill="#EA4335" d="M24 9.5c3.15 0 5.98 1.08 8.2 3.2l6.15-6.15C34.63 2.87 29.79 1 24 1 15.63 1 8.4 5.8 4.82 14.82l7.13 5.54C13.65 13.28 18.4 9.5 24 9.5z"/>'
      '</svg>';

  static const String instagram =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">'
      '<defs><linearGradient id="ig" x1="4" y1="44" x2="44" y2="4" gradientUnits="userSpaceOnUse">'
      '<stop stop-color="#FEDA75"/><stop offset=".25" stop-color="#FA7E1E"/><stop offset=".52" stop-color="#D62976"/><stop offset=".78" stop-color="#962FBF"/><stop offset="1" stop-color="#4F5BD5"/>'
      '</linearGradient></defs>'
      '<rect x="2" y="2" width="44" height="44" rx="12" fill="url(#ig)"/>'
      '<rect x="12" y="12" width="24" height="24" rx="7" fill="none" stroke="#fff" stroke-width="3"/>'
      '<circle cx="24" cy="24" r="6" fill="none" stroke="#fff" stroke-width="3"/>'
      '<circle cx="32.5" cy="15.5" r="2.2" fill="#fff"/>'
      '</svg>';

  static const String facebook =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">'
      '<circle cx="24" cy="24" r="22" fill="#0866FF"/>'
      '<path fill="#fff" d="M27.3 38V25.4h4.24l.64-4.9H27.3v-3.13c0-1.42.4-2.39 2.45-2.39h2.62V10.6c-.45-.06-1.99-.2-3.79-.2-3.75 0-6.32 2.29-6.32 6.5v3.6H18v4.9h4.26V38z"/>'
      '</svg>';

  static const String youtube =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">'
      '<rect x="2" y="8" width="44" height="32" rx="9" fill="#FF0000"/>'
      '<path fill="#fff" d="M20 16.5 34 24l-14 7.5z"/>'
      '</svg>';
}

class _QrFeatureItem extends StatelessWidget {
  const _QrFeatureItem({
    required this.label,
    required this.compact,
    this.icon,
    this.svgData,
    this.semanticsLabel,
  }) : assert(
  icon != null || svgData != null,
  'Either icon or svgData must be provided.',
  );

  final IconData? icon;
  final String? svgData;
  final String label;
  final bool compact;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tileSize = compact ? 44.0 : 48.0;
    final iconSize = compact ? 23.0 : 26.0;
    final labelSize = compact ? 8.5 : 9.5;

    final Widget iconWidget = svgData != null
        ? SvgPicture.string(
      svgData!,
      width: iconSize,
      height: iconSize,
      fit: BoxFit.contain,
      semanticsLabel: semanticsLabel,
    )
        : Icon(
      icon,
      size: iconSize,
      color: colorScheme.onSurfaceVariant,
    );

    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: tileSize,
            height: tileSize,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(
                compact ? 12 : 14,
              ),
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: iconWidget,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: labelSize,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _QrCurveClipper
    extends CustomClipper<Path> {
  const _QrCurveClipper({
    required this.compact,
  });

  final bool compact;

  @override
  Path getClip(
      Size size,
      ) {
    final path = Path();

    path.moveTo(
      0,
      size.height *
          (compact
              ? 0.34
              : 0.32),
    );

    path.quadraticBezierTo(
      size.width * 0.50,
      -size.height *
          (compact
              ? 0.28
              : 0.35),
      size.width,
      size.height *
          (compact
              ? 0.34
              : 0.32),
    );

    path.lineTo(
      size.width,
      size.height,
    );

    path.lineTo(
      0,
      size.height,
    );

    path.close();

    return path;
  }

  @override
  bool shouldReclip(
      covariant _QrCurveClipper oldClipper,
      ) {
    return oldClipper.compact !=
        compact;
  }
}
