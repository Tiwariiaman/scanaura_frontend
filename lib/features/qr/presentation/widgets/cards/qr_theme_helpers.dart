import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';

class QrThemeHelpers {
  QrThemeHelpers._();

  // ---------------------------------------------------------------------------
  // BRAND COLOR
  // ---------------------------------------------------------------------------

  static Color parseBrandColor(String? value) {
    final raw = value
        ?.trim()
        .replaceFirst('#', '');

    if (raw != null &&
        (raw.length == 6 || raw.length == 8)) {
      final parsed = int.tryParse(
        raw,
        radix: 16,
      );

      if (parsed != null) {
        return raw.length == 8
            ? Color(parsed)
            : Color(
          0xFF000000 | parsed,
        );
      }
    }

    return AppColors.primary;
  }

  // ---------------------------------------------------------------------------
  // BRAND COLORS
  // ---------------------------------------------------------------------------

  static Color darkBrand(Color brand) {
    return Color.lerp(
      brand,
      Colors.black,
      .24,
    ) ??
        brand;
  }

  static Color lightBrand(Color brand) {
    return Color.lerp(
      brand,
      Colors.white,
      .88,
    ) ??
        Colors.white;
  }

  static Color extraLightBrand(Color brand) {
    return Color.lerp(
      brand,
      Colors.white,
      .95,
    ) ??
        Colors.white;
  }

  // ---------------------------------------------------------------------------
  // GRADIENT
  // ---------------------------------------------------------------------------

  static LinearGradient gradient(Color brand) {
    final dark = darkBrand(brand);

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        brand,
        dark,
      ],
    );
  }

  static LinearGradient reverseGradient(Color brand) {
    final dark = darkBrand(brand);

    return LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        dark,
        brand,
      ],
    );
  }

  static LinearGradient softGradient(Color brand) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        brand.withValues(alpha: .12),
        brand.withValues(alpha: .035),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // CONTRAST
  // ---------------------------------------------------------------------------

  static Color onBrand(Color brand) {
    return ThemeData.estimateBrightnessForColor(
      brand,
    ) ==
        Brightness.dark
        ? Colors.white
        : const Color(0xFF101828);
  }

  // ---------------------------------------------------------------------------
  // BUSINESS TYPE
  // ---------------------------------------------------------------------------

  static bool isFood(String? businessType) {
    return (businessType ?? '')
        .trim()
        .toUpperCase() ==
        'FOOD';
  }

  static String primaryAction(
      String? businessType,
      ) {
    return isFood(businessType)
        ? 'Menu'
        : 'View';
  }

  static IconData primaryIcon(
      String? businessType,
      ) {
    return isFood(businessType)
        ? Icons.restaurant_menu_rounded
        : Icons.visibility_rounded;
  }

  // ---------------------------------------------------------------------------
  // BUSINESS LOGO
  //
  // IMPORTANT:
  // No white container.
  // No border.
  // No circle.
  // No shadow.
  //
  // The actual image is rendered directly.
  // ---------------------------------------------------------------------------

  static Widget businessLogo({
    required String? url,
    required double size,
    Widget? fallback,
  }) {
    final logo = url?.trim();

    if (logo == null || logo.isEmpty) {
      return fallback ??
          SizedBox(
            width: size,
            height: size,
          );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Image.network(
        logo,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          return fallback ??
              SizedBox(
                width: size,
                height: size,
              );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUSINESS NAME
  // ---------------------------------------------------------------------------

  static String businessName(
      String? name,
      ) {
    final value = name?.trim();

    if (value == null || value.isEmpty) {
      return 'Your Business';
    }

    return value;
  }
}