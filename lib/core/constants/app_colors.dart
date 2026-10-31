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

  // Dark Theme (Midnight Palette) - Web counterpart:
  // CSS: --color-midnight-base: #0B0F17
  static const Color darkBackground = Color(0xFF0B0F17);
  // CSS: --color-midnight-surface: #121824
  static const Color darkSurface = Color(0xFF121824);
  // CSS: --color-surface-card: #161F2E
  static const Color darkCard = Color(0xFF161F2E);
  // CSS: --color-surface-elevated: #1E293B
  static const Color darkCardElevated = Color(0xFF1E293B);
  // CSS: --color-surface-border: #26334D
  static const Color darkBorder = Color(0xFF26334D);
  static const Color darkBorderSubtle = Color(0xFF1E283D);

  // Light Theme Palette:
  // CSS: --color-light-base: #F8FAFC
  static const Color lightBackground = Color(0xFFF8FAFC);
  // CSS: --color-light-surface: #FFFFFF
  static const Color lightSurface = Color(0xFFFFFFFF);
  // CSS: --color-light-card: #FFFFFF
  static const Color lightCard = Color(0xFFFFFFFF);
  // CSS: --color-light-card-elevated: #F1F5F9
  static const Color lightCardElevated = Color(0xFFF1F5F9);
  // CSS: --color-light-border: #E2E8F0
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightBorderSubtle = Color(0xFFEDF2F7);

  // Brand / Interactive Accents:
  // CSS: --color-accent-violet: #6366F1
  static const Color accentViolet = Color(0xFF6366F1);
  // CSS: --color-accent-indigo: #4F46E5
  static const Color accentIndigo = Color(0xFF4F46E5);
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

