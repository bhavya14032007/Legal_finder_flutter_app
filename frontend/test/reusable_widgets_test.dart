import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:legal_helper/core/constants/app_constants.dart';
import 'package:legal_helper/core/theme/app_theme.dart';
import 'package:legal_helper/core/widgets/disclaimer_banner.dart';
import 'package:legal_helper/core/widgets/infinite_ribbon_motif.dart';
import 'package:legal_helper/core/widgets/legal_button.dart';
import 'package:legal_helper/core/widgets/legal_card.dart';

void main() {
  group('Reusable Core Widgets Tests', () {
    testWidgets('LegalButton renders with proper label and triggers callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: LegalButton(
              text: 'Confirm Action',
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Confirm Action'), findsOneWidget);
      await tester.tap(find.text('Confirm Action'));
      expect(tapped, isTrue);
    });

    testWidgets('LegalButton shows loading spinner when isLoading is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: LegalButton(
              text: 'Submit Request',
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('LegalCard renders child content and responds to tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: LegalCard(
              onTap: () => tapped = true,
              child: const Text('Card Inner Text'),
            ),
          ),
        ),
      );

      expect(find.text('Card Inner Text'), findsOneWidget);
      await tester.tap(find.text('Card Inner Text'));
      expect(tapped, isTrue);
    });

    testWidgets('DisclaimerBanner displays mandatory legal notification', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: DisclaimerBanner(),
          ),
        ),
      );

      expect(find.text(AppConstants.aiDisclaimer), findsOneWidget);
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
    });

    testWidgets('InfiniteRibbonMotif renders properly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: InfiniteRibbonMotif(animated: false),
          ),
        ),
      );

      expect(find.byType(InfiniteRibbonMotif), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
