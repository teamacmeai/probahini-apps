import 'package:flutter/material.dart';
import 'package:probahini/providers/tips_provider.dart';
import 'package:probahini/providers/autonomous_coach_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'screens/landing_page.dart';
import 'utils/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => TipsProvider()),
        ChangeNotifierProxyProvider<TipsProvider, AutonomousCoachProvider>(
          create: (context) =>
              AutonomousCoachProvider(context.read<TipsProvider>()),
          update: (context, tipsProvider, previous) =>
              previous ?? AutonomousCoachProvider(tipsProvider),
        ),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            title: 'Menstrual Health Chatbot',
            theme: themeProvider.currentTheme,
            locale: languageProvider.currentLocale,
            supportedLocales: const [Locale('en', 'US'), Locale('bn', 'BD')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            home: LandingPage(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
