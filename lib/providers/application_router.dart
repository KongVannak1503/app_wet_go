import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Screens
import 'package:wet_go/screens/auth.dart';
import 'package:wet_go/screens/home.dart';
import 'package:wet_go/screens/qr_code.dart';
import 'package:wet_go/screens/register.dart';
import 'package:wet_go/screens/settings.dart';
import 'package:wet_go/screens/store_update.dart';
import 'package:wet_go/screens/stores.dart';
import 'package:wet_go/screens/store_create.dart';
import 'package:wet_go/screens/users.dart';
import 'package:wet_go/screens/user_edit.dart';
import 'package:wet_go/screens/change_password.dart';
import 'package:wet_go/screens/profile.dart';
import 'package:wet_go/screens/page_not_found_screen.dart';
import 'package:wet_go/providers/app_route.dart';

// Access authenticatorProvider
import '../main.dart';

final GoRouter applicationRouter = GoRouter(
  initialLocation: AppRoute.auth,
  refreshListenable: authenticatorProvider, // 🔹 listens for login/logout
  redirect: (BuildContext context, GoRouterState state) {
    final isAuthenticated = authenticatorProvider.isAuthenticated;
    final loggingIn = state.matchedLocation == AppRoute.auth;
    final registering = state.matchedLocation == AppRoute.register;

    if (!isAuthenticated && !loggingIn && !registering) {
      return AppRoute.auth;
    }

    if (isAuthenticated && (loggingIn || registering)) {
      return AppRoute.home;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: AppRoute.auth,
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: AppRoute.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoute.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoute.settings,
      builder: (context, state) => const SettingsScreen(),
    ),

    GoRoute(
      path: AppRoute.users,
      builder: (context, state) => const UsersScreen(),
    ),
    GoRoute(
      path: AppRoute.userEdit,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return UserEditScreen(dataId: id);
      },
    ),
    GoRoute(
      path: AppRoute.changePassword,
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: AppRoute.profile,
      builder: (context, state) => const ProfileScreen(),
    ),

    // stores
    GoRoute(
      path: AppRoute.stores,
      builder: (context, state) => const StoresScreen(),
    ),
    GoRoute(
      path: AppRoute.storeCreate,
      builder: (context, state) => const StoreCreateScreen(),
    ),
    GoRoute(
      path: AppRoute.storeUpdate,
      builder: (context, state) {
        final store = state.extra as Map<String, dynamic>;
        return StoreUpdateScreen(store: store);
      },
    ),

    // QR
    GoRoute(
      path: AppRoute.qrScanner,
      builder: (context, state) {
        return QrCodeScreen();
      },
    ),
  ],
  errorBuilder: (context, state) => const PageNotFoundScreen(),
);
