import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:happy_view/main.dart';
import 'package:happy_view/providers/language_provider.dart';

void main() {
  testWidgets('App initializes without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });

 /*  testWidgets('HomeScreen displays all categories',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that all categories are displayed
    expect(find.text('animals'), findsOneWidget);
    expect(find.text('nature'), findsOneWidget);
    expect(find.text('space'), findsOneWidget);
    expect(find.text('food-drink'), findsOneWidget);
    expect(find.text('shapes'), findsOneWidget);
    expect(find.text('vehicles'), findsOneWidget);
    expect(find.text('architecture'), findsOneWidget);
  }); */

  /* testWidgets('Navigates to FullscreenImageViewer on image tap',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Simulate tapping on the first image
    await tester.tap(find.byType(Image).first);
    await tester.pumpAndSettle();

    // Verify that FullscreenImageViewer is displayed
    expect(find.byType(FullScreenImageView), findsOneWidget);
  });

  testWidgets('Language changes when selected in settings',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Navigate to SettingsScreen
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Simulate changing the language
    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();

    // Verify that the language has changed (assuming a dropdown or dialog is used)
    expect(find.text('العربية'),
        findsOneWidget); // Replace 'Spanish' with the actual language option
  });

  testWidgets('SettingsScreen displays all options',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Navigate to SettingsScreen
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Verify that all settings options are displayed
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
  });

  testWidgets('LanguageProvider updates and notifies listeners',
      (WidgetTester tester) async {
    final languageProvider = LanguageProvider();
    bool didNotify = false;

    languageProvider.addListener(() {
      didNotify = true;
    });

    // Change language and verify notification
    languageProvider.changeLanguage('ar');
    expect(languageProvider.currentLocale, 'ar');
    expect(didNotify, true);

    // Reset notification flag
    didNotify = false;

    // Change to the same language and verify no notification
    languageProvider.changeLanguage('ar');
    expect(didNotify, false);
  });

  testWidgets('App initializes and displays main widget',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the main widget is displayed
    expect(find.byType(MaterialApp), findsOneWidget);
  }); */
}
