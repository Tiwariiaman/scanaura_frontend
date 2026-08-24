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
            businessName!.trim().isNotEmpty;

    final hasBusinessLogo =
        businessLogoUrl != null &&
            businessLogoUrl!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        maxWidth: 430,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(28),
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
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // =====================================================
          // GREEN HEADER
          // =====================================================

          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  26,
                  20,
                  92,
                ),
                color: scanAuraGreen,
                child: Column(
                  children: [
                    // =================================================
                    // SCANAURA TOP LOGO
                    // =================================================

                    LayoutBuilder(
                      builder:
                          (context, constraints) {
                        final compact =
                            constraints.maxWidth <
                                340;

                        return Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                          children: [
                            Container(
                              width:
                              compact
                                  ? 44
                                  : 52,
                              height:
                              compact
                                  ? 44
                                  : 52,
                              decoration:
                              BoxDecoration(
                                color:
                                Colors.white,
                                borderRadius:
                                BorderRadius.circular(
                                  12,
                                ),
                              ),
                              clipBehavior:
                              Clip.antiAlias,
                              child:
                              Image.asset(
                                topLogo,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (
                                    context,
                                    error,
                                    stackTrace,
                                    ) {
                                  return const Icon(
                                    Icons
                                        .qr_code_rounded,
                                    color:
                                    scanAuraGreen,
                                    size: 28,
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
                              child: Text(
                                'ScanAura',
                                maxLines: 1,
                                overflow:
                                TextOverflow
                                    .ellipsis,
                                style:
                                TextStyle(
                                  color:
                                  Colors
                                      .white,
                                  fontSize:
                                  compact
                                      ? 24
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
                        );
                      },
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    // =================================================
                    // TAGLINE
                    // =================================================

                    const Text(
                      'SCAN ~ VIEW ~ PAY',
                      textAlign:
                      TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight:
                        FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    const Text(
                      'Scan to view menu & pay with any UPI app',
                      textAlign:
                      TextAlign.center,
                      style: TextStyle(
                        color:
                        scanAuraLightGreen,
                        fontSize: 15,
                        fontWeight:
                        FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              // =====================================================
              // CURVED TRANSITION
              // =====================================================

              Positioned(
                left: 0,
                right: 0,
                bottom: -1,
                child: ClipPath(
                  clipper:
                  _QrCurveClipper(),
                  child: Container(
                    height: 78,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          // =====================================================
          // QR CONTENT
          // =====================================================

          Padding(
            padding:
            const EdgeInsets.fromLTRB(
              18,
              0,
              18,
              22,
            ),
            child: Column(
              children: [
                // =================================================
                // QR
                // =================================================

                LayoutBuilder(
                  builder:
                      (context, constraints) {
                    final availableWidth =
                        constraints.maxWidth;

                    final qrSize =
                    availableWidth >= 300
                        ? 250.0
                        : (availableWidth -
                        32)
                        .clamp(
                      180.0,
                      250.0,
                    );

                    return Container(
                      padding:
                      const EdgeInsets.all(
                        14,
                      ),
                      decoration:
                      BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(
                          22,
                        ),
                        border: Border.all(
                          color: scanAuraGreen
                              .withValues(
                            alpha: 0.20,
                          ),
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(
                              alpha: 0.07,
                            ),
                            blurRadius: 14,
                            offset:
                            const Offset(
                              0,
                              5,
                            ),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment:
                        Alignment.center,
                        children: [
                          QrImageView(
                            data: qrData,
                            version:
                            QrVersions.auto,
                            size: qrSize,
                            backgroundColor:
                            Colors.white,
                            gapless: true,
                            eyeStyle:
                            const QrEyeStyle(
                              eyeShape:
                              QrEyeShape.square,
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

                          // =========================================
                          // BUSINESS LOGO
                          // =========================================

                          if (hasBusinessLogo)
                            Container(
                              width: 52,
                              height: 52,
                              padding:
                              const EdgeInsets
                                  .all(
                                4,
                              ),
                              decoration:
                              BoxDecoration(
                                color:
                                Colors.white,
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  12,
                                ),
                                border:
                                Border.all(
                                  color:
                                  Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors
                                        .black
                                        .withValues(
                                      alpha: 0.16,
                                    ),
                                    blurRadius: 8,
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
                                    fit: BoxFit.contain,
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(
                  height: 24,
                ),

                // =================================================
                // BUSINESS NAME
                // =================================================

                if (showBusinessName)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: scanAuraGreen,
                          width: 1.4,
                        ),
                        bottom: BorderSide(
                          color: scanAuraGreen,
                          width: 1.4,
                        ),
                      ),
                    ),
                    child: hasBusinessName
                        ? Text(
                      businessName!.trim(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                        : const SizedBox(
                      height: 24,
                    ),
                  ),

                // =================================================
                // PHYSICAL QR HELPER
                // =================================================

                // if (!hasBusinessName &&
                //     showBusinessName)
                //   const Padding(
                //     padding:
                //     EdgeInsets.only(
                //       top: 8,
                //     ),
                //     child: Text(
                //       'Write business name here',
                //       textAlign:
                //       TextAlign.center,
                //       style: TextStyle(
                //         color: darkText,
                //         fontSize: 14,
                //         fontStyle:
                //         FontStyle.italic,
                //       ),
                //     ),
                //   ),

                const SizedBox(
                  height: 22,
                ),

                // =================================================
                // FOOTER
                // =================================================

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      footerLogo,
                      width: 27,
                      height: 27,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return const Icon(
                          Icons
                              .qr_code_rounded,
                          size: 27,
                          color:
                          scanAuraGreen,
                        );
                      },
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    Flexible(
                      child: Text(
                        'Powered by ScanAura',
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style:
                        const TextStyle(
                          color: darkText,
                          fontSize: 15,
                          fontWeight:
                          FontWeight.w600,
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
  }
}

// ================================================================
// CURVED WHITE TRANSITION
// ================================================================

class _QrCurveClipper
    extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, size.height * 0.32);

    path.quadraticBezierTo(
      size.width * 0.50,
      -size.height * 0.35,
      size.width,
      size.height * 0.32,
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
      covariant CustomClipper<Path> oldClipper,
      ) {
    return false;
  }
}