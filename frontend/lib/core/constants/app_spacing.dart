import 'package:flutter/material.dart';

/// 8-Point Grid System and Spacing Constants
///
/// Ensures geometric harmony, accessibility touch targets (>= 48dp),
/// and strict compliance with the 8px design grid.
class AppSpacing {
  AppSpacing._();

  // Base 8px scale tokens
  static const double xxs = 4.0;   // 0.5x
  static const double xs = 8.0;    // 1.0x (base unit)
  static const double sm = 12.0;   // 1.5x
  static const double md = 16.0;   // 2.0x
  static const double lg = 24.0;   // 3.0x
  static const double xl = 32.0;   // 4.0x
  static const double xxl = 40.0;  // 5.0x
  static const double xxxl = 48.0; // 6.0x (Accessible touch target)
  static const double massive = 64.0; // 8.0x

  // Corner Radii tokens
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // Reusable EdgeInsets based on 8px grid
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets paddingScreen = EdgeInsets.symmetric(
    horizontal: md,
    vertical: md,
  );

  static const EdgeInsets paddingScreenHorizontal = EdgeInsets.symmetric(
    horizontal: md,
  );

  // Reusable Vertical Spacing Widgets
  static const SizedBox verticalSpaceXxs = SizedBox(height: xxs);
  static const SizedBox verticalSpaceXs = SizedBox(height: xs);
  static const SizedBox verticalSpaceSm = SizedBox(height: sm);
  static const SizedBox verticalSpaceMd = SizedBox(height: md);
  static const SizedBox verticalSpaceLg = SizedBox(height: lg);
  static const SizedBox verticalSpaceXl = SizedBox(height: xl);
  static const SizedBox verticalSpaceXxl = SizedBox(height: xxl);
  static const SizedBox verticalSpaceXxxl = SizedBox(height: xxxl);

  // Reusable Horizontal Spacing Widgets
  static const SizedBox horizontalSpaceXxs = SizedBox(width: xxs);
  static const SizedBox horizontalSpaceXs = SizedBox(width: xs);
  static const SizedBox horizontalSpaceSm = SizedBox(width: sm);
  static const SizedBox horizontalSpaceMd = SizedBox(width: md);
  static const SizedBox horizontalSpaceLg = SizedBox(width: lg);
  static const SizedBox horizontalSpaceXl = SizedBox(width: xl);
}

