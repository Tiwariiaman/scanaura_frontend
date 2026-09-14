import 'package:flutter/material.dart';

import 'qr_card_theme.dart';

import 'themes/theme_1.dart';
import 'themes/theme_2.dart';
import 'themes/theme_3.dart';
import 'themes/theme_4.dart';
import 'themes/theme_5.dart';
import 'themes/theme_6.dart';
import 'themes/theme_7.dart';
import 'themes/theme_8.dart';

class ScanAuraQrCard extends StatelessWidget {
  const ScanAuraQrCard({
    super.key,
    required this.qrData,
    this.businessName,
    this.businessLogoUrl,
    this.businessType,
    this.brandColor,
    this.showBusinessName = true,
    this.theme = QrCardTheme.theme1,
  });

  final String qrData;
  final String? businessName;
  final String? businessLogoUrl;
  final String? businessType;
  final String? brandColor;
  final bool showBusinessName;
  final QrCardTheme theme;

  @override
  Widget build(BuildContext context) {
    switch (theme) {
      case QrCardTheme.theme1:
        return Theme1QrCard(
          qrData: qrData,
          businessName: businessName,
          businessLogoUrl: businessLogoUrl,
          businessType: businessType,
          brandColor: brandColor,
          showBusinessName: showBusinessName,
        );

      case QrCardTheme.theme2:
        return Theme2QrCard(
          qrData: qrData,
          businessName: businessName,
          businessLogoUrl: businessLogoUrl,
          businessType: businessType,
          brandColor: brandColor,
          showBusinessName: showBusinessName,
        );

      case QrCardTheme.theme3:
        return Theme3QrCard(
          qrData: qrData,
          businessName: businessName,
          businessLogoUrl: businessLogoUrl,
          businessType: businessType,
          brandColor: brandColor,
          showBusinessName: showBusinessName,
        );

      case QrCardTheme.theme4:
        return Theme4QrCard(
          qrData: qrData,
          businessName: businessName,
          businessLogoUrl: businessLogoUrl,
          businessType: businessType,
          brandColor: brandColor,
          showBusinessName: showBusinessName,
        );

      case QrCardTheme.theme5:
        return Theme5QrCard(
          qrData: qrData,
          businessName: businessName,
          businessLogoUrl: businessLogoUrl,
          businessType: businessType,
          brandColor: brandColor,
          showBusinessName: showBusinessName,
        );

      case QrCardTheme.theme6:
        return Theme6QrCard(
          qrData: qrData,
          businessName: businessName,
          businessLogoUrl: businessLogoUrl,
          businessType: businessType,
          brandColor: brandColor,
          showBusinessName: showBusinessName,
        );

      case QrCardTheme.theme7:
        return Theme7QrCard(
          qrData: qrData,
          businessName: businessName,
          businessLogoUrl: businessLogoUrl,
          businessType: businessType,
          brandColor: brandColor,
          showBusinessName: showBusinessName,
        );

      case QrCardTheme.theme8:
        return Theme8QrCard(
          qrData: qrData,
          businessName: businessName,
          businessLogoUrl: businessLogoUrl,
          businessType: businessType,
          brandColor: brandColor,
          showBusinessName: showBusinessName,
        );
    }
  }
}