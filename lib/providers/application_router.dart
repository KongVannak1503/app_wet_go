import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import your screens
import 'package:wet_go/screens/auth.dart';
import 'package:wet_go/screens/change_password.dart';
import 'package:wet_go/screens/home.dart';
import 'package:wet_go/screens/page_not_found_screen.dart';
import 'package:wet_go/screens/profile.dart';
import 'package:wet_go/screens/register.dart';
import 'package:wet_go/screens/settings.dart';
import 'package:wet_go/main.dart';
import 'package:wet_go/screens/stores.dart';
import 'package:wet_go/screens/user_edit.dart';
import 'package:wet_go/screens/users.dart'; // Import main.dart to access top-level variables

final GoRouter applicationRouter = GoRouter(
  initialLocation: '/auth',
  refreshListenable: authenticatorProvider,
  redirect: (BuildContext context, GoRouterState state) {
    final isAuthenticated = authenticatorProvider.isAuthenticated;
    final loggingIn = state.matchedLocation == '/auth';
    final registering = state.matchedLocation == '/register';

    // If the user is not authenticated and is not on the login or register page,
    // redirect them to the login page.
    if (!isAuthenticated && !loggingIn && !registering) {
      return '/auth';
    }

    // If the user is authenticated and is on the login or register page,
    // redirect them to the home page.
    if (isAuthenticated && (loggingIn || registering)) {
      return '/home';
    }

    // No redirect needed.
    return null;
  },
  routes: <RouteBase>[
    GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(path: '/stores', builder: (context, state) => const StoresScreen()),
    GoRoute(path: '/users', builder: (context, state) => const UsersScreen()),
    GoRoute(
      path: '/users/edit/:id', // 👈 add :id
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return UserEditScreen(dataId: id);
      },
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    // GoRoute(path: '/admin', builder: (context, state) => const AdminScreen()),
    // GoRoute(
    //   path: '/item/:id',
    //   builder: (context, state) {
    //     final id = state.pathParameters['id']!;
    //     return ItemDetailScreen(itemId: id);
    //   },
    // ),
  ],
  errorBuilder: (context, state) => const PageNotFoundScreen(),
);
