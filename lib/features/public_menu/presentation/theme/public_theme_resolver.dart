import 'package:flutter/material.dart';

import 'public_theme.dart';

/// Resolves a single public brand color without coupling presentation to APIs.
///
/// The backend business color is the single source of truth for public pages.
class PublicThemeResolver {
  const PublicThemeResolver._();

  static PublicTheme resolve({
    required String businessName,
    String businessType = '',
    String? brandColor,
  }) {
    return PublicTheme.fromPrimaryColor(
      parseColor(brandColor) ?? const Color(0xFF00674F),
    );
  }

  /// Accepts #RRGGBB, #AARRGGBB, RRGGBB, AARRGGBB, or a numeric color value.
  static Color? parseColor(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) return null;
    final hex = raw.startsWith('#') ? raw.substring(1) : raw;
    if (!RegExp(r'^[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$').hasMatch(hex)) return null;
    final parsed = int.tryParse(hex, radix: 16);
    if (parsed == null) return null;
    return Color(hex.length == 6 ? 0xFF000000 | parsed : parsed);
  }

}
