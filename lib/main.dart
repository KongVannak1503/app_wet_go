import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart'; // <-- Import Provider
import 'package:wet_go/providers/application_router.dart';
import 'package:wet_go/l10n/app_localizations.dart';
import 'package:wet_go/providers/application_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ApplicationProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color.fromARGB(255, 26, 4, 77);
    final provider = Provider.of<ApplicationProvider>(context);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Wet Go',
      locale: provider.locale, // <-- Use locale from provider
      supportedLocales: const [Locale('en'), Locale('km')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          brightness: Brightness.light,
        ).copyWith(primary: primaryBlue),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          brightness: Brightness.dark,
        ).copyWith(primary: primaryBlue),
      ),
      routerConfig: applicationRouter,
      // home: const AuthScreen(),
    );
  }
}
