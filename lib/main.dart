import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wet_go/l10n/app_localizations.dart';
import 'package:wet_go/providers/application_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wet_go/providers/authenticator_provider.dart';
import 'package:wet_go/repositories/users_repository.dart';
import 'package:wet_go/services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:wet_go/services/dio_interceptor.dart';
import 'package:wet_go/providers/application_router.dart';

// Create a single, top-level instance of services and providers
// to prevent them from being re-created on every widget rebuild.
final dio = Dio();
final usersRepository = UsersRepository(dio);
final authService = AuthService(usersRepository);
final authenticatorProvider = AuthenticatorProvider(authService);
final applicationProvider = ApplicationProvider();

void main() {
  // Add the authentication interceptor to Dio
  dio.interceptors.add(AuthInterceptor(authService));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApplicationProvider()),
        Provider<AuthService>(create: (_) => authService),
        ChangeNotifierProvider<AuthenticatorProvider>(
          create: (_) => authenticatorProvider,
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
    const Color primaryBlue = Color.fromARGB(255, 26, 4, 77);
    final appProvider = Provider.of<ApplicationProvider>(context);

    // Define the color schemes first
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
    ).copyWith(primary: primaryBlue);

    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.dark,
    ).copyWith(primary: primaryBlue);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Wet Go',
      locale: appProvider.locale,
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
        colorScheme: lightColorScheme,
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: lightColorScheme.onPrimary),
          actionsIconTheme: IconThemeData(color: lightColorScheme.onPrimary),
        ),
        textTheme: GoogleFonts.notoSansKhmerTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: darkColorScheme.onPrimary),
          actionsIconTheme: IconThemeData(color: darkColorScheme.onPrimary),
        ),
        textTheme: GoogleFonts.notoSansKhmerTextTheme(),
      ),
      routerConfig: applicationRouter,
    );
  }
}
