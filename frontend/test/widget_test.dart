import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:legal_helper/app.dart';
import 'package:legal_helper/core/constants/app_constants.dart';
import 'package:legal_helper/core/services/storage_service.dart';
import 'package:legal_helper/shared/providers/storage_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Legal Helper app smoke test and main screen navigation', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      AppConstants.prefKeyTheme: 'dark',
      AppConstants.prefKeyLanguage: 'en',
    });

    final storage = await StorageService.init();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
        ],
        child: const LegalHelperApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify main bottom navigation tabs render
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Me'), findsOneWidget);

    // Verify AI Advisor FAB exists
    expect(find.text('+ AI Advisor'), findsOneWidget);

    // Verify Quick-Access tools on Home
    expect(find.text('Quick-Access Tools'), findsOneWidget);
    expect(find.text('Simplifier'), findsOneWidget);
    expect(find.text('Drafting'), findsOneWidget);

    // Tap Explore destination
    await tester.tap(find.text('Explore'));
    await tester.pump(const Duration(milliseconds: 200));

    // Verify Explore screen category headers
    expect(find.text('AI ASSISTANCE'), findsOneWidget);
    expect(find.text('DOCUMENTS'), findsOneWidget);

    // Scroll to check SAFETY & HELP
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('SAFETY & HELP'), findsOneWidget);

    // Tap Saved destination
    await tester.tap(find.text('Saved'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Saved Library'), findsOneWidget);

    // Tap Me destination
    await tester.tap(find.text('Me'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Me & Account Settings'), findsOneWidget);
  });
}
