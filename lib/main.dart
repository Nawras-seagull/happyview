import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:happy_view/firebase_options.dart';
import 'package:happy_view/screens/home.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import 'providers/language_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LanguageProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  ); 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final languageProvider = Provider.of<LanguageProvider>(context);

        return MaterialApp(
          title: 'HAPPY VIEW',
          debugShowCheckedModeBanner: false,

          // Set the app's locale
          locale: languageProvider.currentLocale,

          // Define supported locales
          supportedLocales: const [
            Locale('en'), // English
            Locale('ar'), // Arabic
            Locale('tr'), // Turkish
          ],

          // Add localization delegates
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // Handle text direction based on locale
          builder: (context, child) {
            return Directionality(
              textDirection: languageProvider.isRtl()
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: child!,
            );
          },

          theme: ThemeData(
            primarySwatch: Colors.blue,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
            ),
            
          ),

          home: HomeScreen(),
        );
      },
    );
  }
}
