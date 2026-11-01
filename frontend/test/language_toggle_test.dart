import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:legal_helper/app.dart';
import 'package:legal_helper/core/constants/app_constants.dart';
import 'package:legal_helper/core/services/storage_service.dart';
import 'package:legal_helper/shared/providers/locale_provider.dart';
import 'package:legal_helper/shared/providers/storage_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Interface language toggle reactively updates entire app to Hindi and back', (WidgetTester tester) async {
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

    // Initially in English
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Me'), findsOneWidget);
    expect(find.text('+ AI Advisor'), findsOneWidget);
    expect(find.text('Quick-Access Tools'), findsOneWidget);

    // Switch to Hindi directly through localeProvider
    final element = tester.element(find.byType(LegalHelperApp));
    final container = ProviderScope.containerOf(element);
    container.read(localeProvider.notifier).setLocale(const Locale('hi', 'IN'));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify all navigation tabs, FAB and Home screen headers updated to Hindi
    expect(find.text('होम'), findsOneWidget);
    expect(find.text('एक्सप्लोर'), findsOneWidget);
    expect(find.text('सहेजे गए'), findsOneWidget);
    expect(find.text('प्रोफाइल'), findsOneWidget);
    expect(find.text('+ कानूनी सलाहकार'), findsOneWidget);
    expect(find.text('त्वरित-पहुंच उपकरण'), findsOneWidget);

    // Tap Explore tab in Hindi
    await tester.tap(find.text('एक्सप्लोर'));
    await tester.pump(const Duration(milliseconds: 200));

    // Verify Explore screen category headers in Hindi
    expect(find.text('एआई कानूनी सहायता'), findsOneWidget);
    expect(find.text('दस्तावेज़ एवं अनुपालन'), findsOneWidget);

    // Switch back to English
    container.read(localeProvider.notifier).setLocale(const Locale('en', 'US'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify English navigation restored
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Me'), findsOneWidget);
    expect(find.text('+ AI Advisor'), findsOneWidget);
  });
}

