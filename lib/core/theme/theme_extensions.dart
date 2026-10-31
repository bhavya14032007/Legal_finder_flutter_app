import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Custom theme extension for Legal Helper specific design tokens
@immutable
class LegalThemeExtension extends ThemeExtension<LegalThemeExtension> {
  final Color cardBackground;
  final Color cardBorder;
  final Color cardBorderSubtle;
  final Color elevatedSurface;
  final Color accentViolet;
  final Color accentIndigo;
  final Color accentCyan;
  final List<Color> ribbonGradient;

  const LegalThemeExtension({
    required this.cardBackground,
    required this.cardBorder,
    required this.cardBorderSubtle,
    required this.elevatedSurface,
    required this.accentViolet,
    required this.accentIndigo,
    required this.accentCyan,
    required this.ribbonGradient,
  });

  static const LegalThemeExtension dark = LegalThemeExtension(
    cardBackground: AppColors.darkCard,
    cardBorder: AppColors.darkBorder,
    cardBorderSubtle: AppColors.darkBorderSubtle,
    elevatedSurface: AppColors.darkCardElevated,
    accentViolet: AppColors.accentViolet,
    accentIndigo: AppColors.accentIndigo,
    accentCyan: AppColors.accentCyan,
    ribbonGradient: AppColors.ribbonGradient,
  );

  static const LegalThemeExtension light = LegalThemeExtension(
    cardBackground: AppColors.lightCard,
    cardBorder: AppColors.lightBorder,
    cardBorderSubtle: AppColors.lightBorderSubtle,
    elevatedSurface: AppColors.lightCardElevated,
    accentViolet: AppColors.accentViolet,
    accentIndigo: AppColors.accentIndigo,
    accentCyan: AppColors.accentCyan,
    ribbonGradient: [
      Color(0x1A6366F1),
      Color(0x1AA855F7),
      Color(0x1A06B6D4),
    ],
  );

  @override
  LegalThemeExtension copyWith({
    Color? cardBackground,
    Color? cardBorder,
    Color? cardBorderSubtle,
    Color? elevatedSurface,
    Color? accentViolet,
    Color? accentIndigo,
    Color? accentCyan,
    List<Color>? ribbonGradient,
  }) {
    return LegalThemeExtension(
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      cardBorderSubtle: cardBorderSubtle ?? this.cardBorderSubtle,
      elevatedSurface: elevatedSurface ?? this.elevatedSurface,
      accentViolet: accentViolet ?? this.accentViolet,
      accentIndigo: accentIndigo ?? this.accentIndigo,
      accentCyan: accentCyan ?? this.accentCyan,
      ribbonGradient: ribbonGradient ?? this.ribbonGradient,
    );
  }

  @override
  LegalThemeExtension lerp(ThemeExtension<LegalThemeExtension>? other, double t) {
    if (other is! LegalThemeExtension) return this;
    return LegalThemeExtension(
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      cardBorderSubtle: Color.lerp(cardBorderSubtle, other.cardBorderSubtle, t)!,
      elevatedSurface: Color.lerp(elevatedSurface, other.elevatedSurface, t)!,
      accentViolet: Color.lerp(accentViolet, other.accentViolet, t)!,
      accentIndigo: Color.lerp(accentIndigo, other.accentIndigo, t)!,
      accentCyan: Color.lerp(accentCyan, other.accentCyan, t)!,
      ribbonGradient: ribbonGradient,
    );
  }
}

/// Helper extension on BuildContext to quickly access theme tokens
extension ThemeContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  LegalThemeExtension get legalTheme =>
      theme.extension<LegalThemeExtension>() ?? LegalThemeExtension.dark;

  /// Check if user has requested reduced motion for accessibility
  bool get reducesMotion => MediaQuery.maybeOf(this)?.disableAnimations ?? false;
}

