import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import your screens
import 'package:wet_go/screens/auth.dart';
import 'package:wet_go/screens/home.dart';
import 'package:wet_go/screens/register.dart';
import 'package:wet_go/screens/settings.dart';

final GoRouter applicationRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      redirect: (BuildContext context, GoRouterState state) => '/auth',
    ),
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
    // GoRoute(
    //   path: '/admin',
    //   builder: (context, state) => const AdminScreen(),
    // ),
    // GoRoute(
    //   path: '/item/:id',
    //   builder: (context, state) {
    //     final id = state.pathParameters['id']!;
    //     return ItemDetailScreen(itemId: id);
    //   },
    // ),
  ],
);
