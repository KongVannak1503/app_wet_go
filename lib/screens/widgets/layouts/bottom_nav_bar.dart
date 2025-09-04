import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wet_go/l10n/app_localizations.dart';

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
          context.go('/home');
        } else if (index == 1) {
          context.go('/profile');
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
