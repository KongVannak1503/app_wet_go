import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wet_go/l10n/app_localizations.dart';
import 'package:wet_go/providers/app_route.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 0) {
          context.go(AppRoute.home);
        } else if (index == 1) {
          context.go(AppRoute.profile);
        }
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: loc?.home),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: loc?.profile ?? 'Profile',
        ),
      ],
    );
  }
}
