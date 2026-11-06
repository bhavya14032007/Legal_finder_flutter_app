import 'package:flutter/material.dart';

/// Centralized Color Tokens for Legal Helper
///
/// Designed to match the Legal Helper website design tokens:
/// - Midnight as primary dark background (--bg-midnight: #0B0F17)
/// - Surface colors for cards, panels, navigation (--surface-card: #161B26, --surface-elevated: #1E2536)
/// - Violet / Indigo interactive accents (--accent-violet: #6366F1, --accent-indigo: #4F46E5)
/// - Secondary accent cyan / sky (--accent-cyan: #06B6D4)
/// - Semantic colors for risk, scam detection, status tags
/// - Light theme counterparts for seamless theme switching
class AppColors {
  AppColors._();

  // Dark Theme (Modern Legal-Tech Palette)
  // Specified Design Tokens:
  // Primary background: #080D19
  static const Color darkBackground = Color(0xFF080D19);
  // Secondary surface: #151D30
  static const Color darkSurface = Color(0xFF151D30);
  // Card background: #111827
  static const Color darkCard = Color(0xFF111827);
  static const Color darkCardElevated = Color(0xFF151D30);
  // Borders: #26334D
  static const Color darkBorder = Color(0xFF26334D);
  static const Color darkBorderSubtle = Color(0xFF1E283D);

  // Light Theme Palette:
  static const Color lightBackground = Color(0xFFF4F6FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardElevated = Color(0xFFF8FAFC);
  static const Color lightBorder = Color(0xFFE8ECF8);
  static const Color lightBorderSubtle = Color(0xFFF1F5F9);

  // Brand / Interactive Accents:
  // Primary accent: #7955F5
  static const Color primaryAccent = Color(0xFF7955F5);
  static const Color accentViolet = Color(0xFF7955F5);
  static const Color accentIndigo = Color(0xFF6366F1);
  // CSS: --color-accent-violet-light: #818CF8
  static const Color accentVioletLight = Color(0xFF818CF8);
  // CSS: --color-accent-purple: #A855F7
  static const Color accentPurple = Color(0xFFA855F7);
  // CSS: --color-accent-cyan: #06B6D4
  static const Color accentCyan = Color(0xFF06B6D4);

  // Neutral / Typography Text Colors:
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textTertiaryLight = Color(0xFF94A3B8);

  // Semantic & Feedback Colors:
  // CSS: --color-success: #10B981
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0x1A10B981);

  // CSS: --color-warning: #F59E0B
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0x1AF59E0B);

  // CSS: --color-danger: #EF4444
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerBg = Color(0x1AEF4444);

  // CSS: --color-info: #3B82F6
  static const Color info = Color(0xFF3B82F6);
  static const Color infoBg = Color(0x1A3B82F6);

  // Infinite Ribbon Gradient Tokens:
  static const List<Color> ribbonGradient = [
    Color(0x336366F1), // violet with low opacity
    Color(0x33A855F7), // purple with low opacity
    Color(0x3306B6D4), // cyan with low opacity
  ];

  static const List<Color> primaryButtonGradient = [
    Color(0xFF6366F1),
    Color(0xFF4F46E5),
  ];
}

