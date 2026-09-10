import 'package:flutter/material.dart';

/// Semantic, presentation-only tokens for the public customer journey.
@immutable
class PublicTheme {
  const PublicTheme._({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.accent,
    required this.onAccent,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.outline,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.glassSurface,
    required this.glassBorder,
    required this.subtleTint,
    required this.success,
    required this.warning,
    required this.error,
  });

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color accent;
  final Color onAccent;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color outline;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color glassSurface;
  final Color glassBorder;
  final Color subtleTint;
  final Color success;
  final Color warning;
  final Color error;

  // Temporary compatibility aliases for public screens during the rollout.
  Color get primarySoft => primaryContainer;
  Color get textPrimary => onSurface;
  Color get primarySurface => subtleTint;
  Color get secondary => accent;
  Color get elevatedSurface => surfaceVariant;
  Color get text => onSurface;
  Color get textSecondary => onSurfaceVariant;
  Color get textTertiary => onSurfaceVariant.withValues(alpha: .72);
  Color get border => outline;
  Color get onSecondary => onAccent;
  Color get gradientStart => primary;
  Color get gradientEnd => accent;

  LinearGradient get heroGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primary, accent],
      );

  /// Derives the complete public palette from one brand color.
  factory PublicTheme.fromPrimaryColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    final normalized = _normalizedPrimary(hsl).toColor();
    final normalizedHsl = HSLColor.fromColor(normalized);
    final onPrimary = _foregroundFor(normalized);
    final container = normalizedHsl.withLightness(.94).withSaturation((normalizedHsl.saturation * .42).clamp(.10, .45).toDouble()).toColor();
    final accent = normalizedHsl.withHue((normalizedHsl.hue + 28) % 360).withSaturation((normalizedHsl.saturation * .72).clamp(.30, .72).toDouble()).withLightness(.52).toColor();
    final surfaceTint = normalizedHsl.withLightness(.975).withSaturation((normalizedHsl.saturation * .16).clamp(.03, .14).toDouble()).toColor();
    return PublicTheme._(
      primary: normalized,
      onPrimary: onPrimary,
      primaryContainer: container,
      onPrimaryContainer: _foregroundFor(container),
      accent: accent,
      onAccent: _foregroundFor(accent),
      background: surfaceTint,
      surface: Colors.white,
      surfaceVariant: const Color(0xFFFCFCFB),
      outline: normalized.withValues(alpha: .16),
      onSurface: const Color(0xFF172025),
      onSurfaceVariant: const Color(0xFF58636A),
      glassSurface: Colors.white.withValues(alpha: .72),
      glassBorder: Colors.white.withValues(alpha: .55),
      subtleTint: normalized.withValues(alpha: .08),
      success: const Color(0xFF287A59),
      warning: const Color(0xFFAE6A19),
      error: const Color(0xFFBF4141),
    );
  }

  ThemeData materialTheme(BuildContext context) {
    final base = Theme.of(context);
    final scheme = ColorScheme.light(
      primary: primary, onPrimary: onPrimary,
      primaryContainer: primaryContainer, onPrimaryContainer: onPrimaryContainer,
      secondary: accent, onSecondary: onAccent,
      secondaryContainer: subtleTint, onSecondaryContainer: onSurface,
      surface: surface, onSurface: onSurface,
      error: error, onError: Colors.white,
      outline: outline, outlineVariant: outline,
    );
    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: base.appBarTheme.copyWith(backgroundColor: background, foregroundColor: onSurface, elevation: 0, surfaceTintColor: Colors.transparent),
      cardTheme: base.cardTheme.copyWith(color: surface, elevation: 0, surfaceTintColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: outline))),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(filled: true, fillColor: surfaceVariant, enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: outline))),
    );
  }

  static HSLColor _normalizedPrimary(HSLColor color) {
    // Protect against unusably pale and near-black source choices.
    final lightness = color.lightness.clamp(.28, .56).toDouble();
    final saturation = color.saturation.clamp(.30, .82).toDouble();
    return color.withLightness(lightness).withSaturation(saturation);
  }

  static Color _foregroundFor(Color color) => color.computeLuminance() > .42 ? const Color(0xFF172025) : Colors.white;
}
