import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

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

  static const Color scanAuraGreen =
  Color(0xFF00674F);

  static const Color scanAuraLightGreen =
  Color(0xFFBFE8DB);

  static const Color darkText =
  Color(0xFF3F4542);

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
              scanAuraGreen.withValues(
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
                    scanAuraGreen,
                    child: Column(
                      children: [
                        // ==============================================
                        // SCANAURA LOGO
                        // ==============================================

                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                          children: [
                            Container(
                              width:
                              businessLogoSize,
                              height:
                              businessLogoSize,
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
                              ),
                              clipBehavior:
                              Clip.antiAlias,
                              child:
                              Image.asset(
                                topLogo,
                                fit: BoxFit
                                    .cover,
                                errorBuilder:
                                    (
                                    context,
                                    error,
                                    stackTrace,
                                    ) {
                                  return Icon(
                                    Icons
                                        .qr_code_rounded,
                                    color:
                                    scanAuraGreen,
                                    size:
                                    compact
                                        ? 24
                                        : 28,
                                  );
                                },
                              ),
                            ),

                            SizedBox(
                              width:
                              compact
                                  ? 8
                                  : 12,
                            ),

                            Flexible(
                              child:
                              Text(
                                'ScanAura',
                                maxLines: 1,
                                overflow:
                                TextOverflow
                                    .ellipsis,
                                style:
                                TextStyle(
                                  color:
                                  Colors.white,
                                  fontSize:
                                  compact
                                      ? 22
                                      : 28,
                                  fontWeight:
                                  FontWeight
                                      .w700,
                                  letterSpacing:
                                  -0.5,
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

                        Text(
                          'SCAN ~ VIEW ~ PAY',
                          textAlign:
                          TextAlign.center,
                          maxLines: 1,
                          overflow:
                          TextOverflow
                              .ellipsis,
                          style:
                          TextStyle(
                            color:
                            Colors.white,
                            fontSize:
                            taglineFontSize,
                            fontWeight:
                            FontWeight
                                .w800,
                            letterSpacing:
                            0.2,
                          ),
                        ),

                        SizedBox(
                          height:
                          compact
                              ? 8
                              : 10,
                        ),

                        Text(
                          'Scan to view menu & pay with any UPI app',
                          textAlign:
                          TextAlign.center,
                          maxLines:
                          compact
                              ? 2
                              : 2,
                          overflow:
                          TextOverflow
                              .ellipsis,
                          style:
                          TextStyle(
                            color:
                            scanAuraLightGreen,
                            fontSize:
                            descriptionFontSize,
                            fontWeight:
                            FontWeight.w500,
                            height: 1.35,
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
                          scanAuraGreen
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
                              scanAuraGreen,
                              width: 1.4,
                            ),
                            bottom:
                            BorderSide(
                              color:
                              scanAuraGreen,
                              width: 1.4,
                            ),
                          ),
                        ),
                        alignment:
                        Alignment.center,
                        child:
                        hasBusinessName
                            ? Text(
                          businessName!
                              .trim(),
                          textAlign:
                          TextAlign
                              .center,
                          maxLines:
                          compact
                              ? 2
                              : 1,
                          overflow:
                          TextOverflow
                              .ellipsis,
                          style:
                          TextStyle(
                            color:
                            darkText,
                            fontSize:
                            businessNameFontSize,
                            fontWeight:
                            FontWeight
                                .w700,
                            height:
                            1.2,
                          ),
                        )
                            : const SizedBox
                            .shrink(),
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
                              scanAuraGreen,
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
                              darkText,
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